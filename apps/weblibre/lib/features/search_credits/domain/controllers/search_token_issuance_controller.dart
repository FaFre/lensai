/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_client/search_client.dart';
import 'package:uuid/uuid.dart';
import 'package:weblibre/core/rust_lib.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/search_credits/data/token_stash.dart';
import 'package:weblibre/features/search_credits/domain/providers.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_credits_repository.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_token_stash_repository.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'search_token_issuance_controller.g.dart';

sealed class SearchTokenIssuanceState {
  const SearchTokenIssuanceState();
}

class SearchTokenIssuanceIdle extends SearchTokenIssuanceState {
  const SearchTokenIssuanceIdle();
}

class SearchTokenIssuanceRequesting extends SearchTokenIssuanceState {
  final int count;
  final String idempotencyKey;
  const SearchTokenIssuanceRequesting({
    required this.count,
    required this.idempotencyKey,
  });
}

class SearchTokenIssuanceNeedsPurchase extends SearchTokenIssuanceState {
  final int remainingCredits;
  const SearchTokenIssuanceNeedsPurchase({required this.remainingCredits});
}

class SearchTokenIssuanceNeedsReauth extends SearchTokenIssuanceState {
  const SearchTokenIssuanceNeedsReauth();
}

class SearchTokenIssuanceFailed extends SearchTokenIssuanceState {
  final Object error;
  final StackTrace stackTrace;
  const SearchTokenIssuanceFailed(this.error, this.stackTrace);
}

@Riverpod(keepAlive: true)
class SearchTokenIssuanceController extends _$SearchTokenIssuanceController {
  Future<IssuanceResult>? _pending;

  @override
  SearchTokenIssuanceState build() => const SearchTokenIssuanceIdle();

  /// Request `count` tokens. Single-flight — a second call while `Requesting`
  /// returns the same pending future. If a retry follows a failure, the same
  /// idempotency key is reused so the server can replay the prior result.
  Future<IssuanceResult?> issue({required int count}) async {
    final pending = _pending;
    if (pending != null) return pending;

    final authState = ref.read(accountAuthRepositoryProvider).value;
    final client = authState?.client;
    if (authState == null || !authState.isSignedIn || client == null) {
      state = const SearchTokenIssuanceNeedsReauth();
      return null;
    }

    final session = client.auth.currentSession;
    final accessToken = session?.accessToken;
    if (accessToken == null) {
      state = const SearchTokenIssuanceNeedsReauth();
      return null;
    }

    // Always generate a fresh idempotency key per attempt. The SDK
    // re-blinds the token_request on every call — reusing a key with a
    // new blinded request would trigger IdempotencyKeyReusedError on the
    // backend rather than a safe replay. Retries after a failure must
    // therefore start a new reservation from scratch.
    final idempotencyKey = const Uuid().v4();

    state = SearchTokenIssuanceRequesting(
      count: count,
      idempotencyKey: idempotencyKey,
    );

    final future = _runIssuance(
      accessToken: accessToken,
      idempotencyKey: idempotencyKey,
      count: count,
    );
    _pending = future;

    try {
      final result = await future;
      state = const SearchTokenIssuanceIdle();
      unawaited(ref.read(searchCreditsRepositoryProvider.notifier).refresh());
      ref.invalidate(searchTokenStashCountProvider);
      return result;
    } on InsufficientCreditsError catch (e) {
      state = SearchTokenIssuanceNeedsPurchase(
        remainingCredits: e.remainingCredits,
      );
      return null;
    } catch (e, s) {
      state = SearchTokenIssuanceFailed(e, s);
      return null;
    } finally {
      _pending = null;
    }
  }

  Future<IssuanceResult> _runIssuance({
    required String accessToken,
    required String idempotencyKey,
    required int count,
  }) async {
    // The Privacy Pass Rust library is loaded lazily rather than before the
    // first frame; this is the only path that needs it.
    await ensureRustLibInitialized();

    final issuance = ref.read(issuanceClientProvider);
    // Fetch the public key explicitly so we can tag the stash rows that
    // `issueAndStash` will write with the exact key version the issuer
    // signed against — `DriftTokenStash.add` would otherwise have no way
    // to know it. `IssuanceClient` caches the result, so this is free
    // after the first call.
    final key = await issuance.fetchPublicKey();
    final db = ref.read(userDatabaseProvider);
    final stash = DriftTokenStash(
      db.searchTokensDao,
      issuerKeyVersion: key.version,
    );
    return issuance.issueAndStash(
      supabaseAccessToken: accessToken,
      idempotencyKey: idempotencyKey,
      count: count,
      stash: stash,
    );
  }

  void reset() {
    if (_pending != null) return;
    state = const SearchTokenIssuanceIdle();
  }
}

/// Result of an opportunistic token top-up attempt.
enum TokenTopUpOutcome {
  /// New tokens were issued and are now in the stash.
  issued,

  /// User has zero available credits — needs to purchase more.
  noCredits,

  /// Issuance failed (network, auth, server) — see controller state for
  /// the surfaced error.
  issuanceFailed,
}

/// Result of ensuring at least one token is available for a search.
enum TokenAvailabilityOutcome {
  /// A token is available in the local stash.
  available,

  /// The account has no remaining credits to issue tokens from.
  noCredits,

  /// Credits may exist, but token issuance failed and should be retried.
  issuanceFailed,
}

/// Helpers around the token stash + issuance flow. Lives as a plain class
/// rather than a Notifier because the operations are one-shot async calls
/// with no state to publish back to listeners — the relevant state is
/// already in `searchTokenIssuanceControllerProvider` /
/// `searchCreditsRepositoryProvider` / `searchTokenStashCountProvider`.
class SearchTokenAvailability {
  final Ref ref;

  SearchTokenAvailability(this.ref);

  /// Ensure the stash has at least one token, topping up from the server when
  /// possible. Distinguishes real zero-credit balances from retryable issuance
  /// failures so callers can show the right recovery path.
  Future<TokenAvailabilityOutcome> ensureAvailable() async {
    final stash = ref.read(searchTokenStashProvider);
    if (await stash.count() > 0) return TokenAvailabilityOutcome.available;

    final outcome = await topUp();
    switch (outcome) {
      case TokenTopUpOutcome.issued:
        return (await stash.count()) > 0
            ? TokenAvailabilityOutcome.available
            : TokenAvailabilityOutcome.issuanceFailed;
      case TokenTopUpOutcome.noCredits:
        return TokenAvailabilityOutcome.noCredits;
      case TokenTopUpOutcome.issuanceFailed:
        return TokenAvailabilityOutcome.issuanceFailed;
    }
  }

  /// Opportunistically request a fresh batch of tokens (capped at 10 per
  /// the server's batch limit) when the stash runs dry. Used by both the
  /// meta-search submit flow and the sandbox capture flow.
  Future<TokenTopUpOutcome> topUp({int desired = 10}) async {
    final status = await ref.read(searchCreditsRepositoryProvider.future);
    if (status.availableCredits <= 0) return TokenTopUpOutcome.noCredits;

    final requestCount = min(desired, status.availableCredits);
    final result = await ref
        .read(searchTokenIssuanceControllerProvider.notifier)
        .issue(count: requestCount);
    return result != null
        ? TokenTopUpOutcome.issued
        : TokenTopUpOutcome.issuanceFailed;
  }
}

@Riverpod(keepAlive: true)
SearchTokenAvailability searchTokenAvailability(Ref ref) =>
    SearchTokenAvailability(ref);
