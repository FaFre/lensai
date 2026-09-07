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

import 'package:exceptions/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/repositories/sync.dart';

part 'app_initialization.g.dart';

@Riverpod(keepAlive: true)
class AppInitializationService extends _$AppInitializationService {
  /// Will de facto restart the app
  Future<void> reinitialize() {
    ref.invalidateSelf();
    return initialize();
  }

  Future<void>? _format;
  Future<void>? _packageInfo;
  Future<Map<BangGroup, Result<void>>>? _bangs;

  /// Discards the prewarmed futures so a retry re-runs the work rather than
  /// re-awaiting a future that already failed.
  void _resetPrewarm() {
    _format = null;
    _packageInfo = null;
    _bangs = null;
  }

  /// Starts the work [initialize] will await, without waiting for it.
  ///
  /// All of it is profile-local — intl date symbols, package info, the bundled
  /// bang import — and none of it touches the engine, so on a cold start it can
  /// run *while* GeckoView comes up rather than queueing behind it. `main` calls
  /// this before it starts the engine and then awaits [initialize] after, so what
  /// changes is only that the two long stretches of a cold start overlap: the
  /// point at which the UI is allowed to mount is still the end of [initialize].
  ///
  /// Idempotent, and safe to skip: [initialize] starts anything not already
  /// running.
  void prewarm() {
    // `ignore()` on the two that can reject: between here and the `await` in
    // [initialize] sits the whole engine bring-up, and a future that completes
    // with an error and no listener is reported to `PlatformDispatcher.onError`
    // as an unhandled error. Without this a failing intl or package-info load
    // would be logged twice — once as "Unhandled Error" during startup, then
    // again as the initialization failure it actually is. `ignore()` only
    // suppresses that report; the later `await` still receives the error.
    //
    // `_bangs` needs none: `syncBundledBangGroups` returns a `Result` per group
    // and does not reject.
    _format ??= _unlistened(ref.read(formatProvider.future));
    _packageInfo ??= _unlistened(ref.read(packageInfoProvider.future));
    _bangs ??= ref
        .read(bangSyncRepositoryProvider.notifier)
        .syncBundledBangGroups();
  }

  /// Marks [future] as having its errors handled, and returns it unchanged.
  ///
  /// `Future.ignore` only suppresses the unhandled-error report; whoever awaits
  /// the future later still receives the error. Also pins the type argument: a
  /// bare `_x ??= ref.read(...)..ignore()` infers `ref.read` from the nullable
  /// field it assigns to, and then `ignore()` is a call on a nullable receiver.
  static Future<T> _unlistened<T>(Future<T> future) => future..ignore();

  /// Awaits one prewarmed step, reporting [stage] while it is outstanding.
  ///
  /// The stage is set here rather than where the work starts, so the label still
  /// tracks what the user is waiting on even when the work itself already ran
  /// during engine startup.
  Future<T> _stage<T>(String stage, Future<T>? Function() work) {
    state = Result.success((
      initialized: false,
      stage: stage,
      errors: List.empty(),
    ));

    return work()!;
  }

  Future<void> initialize() async {
    final result = await Result.fromAsync(() async {
      final errors = <ErrorMessage>[];

      await _stage(
        'Loading Formats...',
        // Bang: `??=` is typed by the nullable field, though it never yields
        // null here.
        () => _format ??= ref.read(formatProvider.future),
      );
      if (!ref.mounted) {
        return (initialized: false, stage: null, errors: errors);
      }

      await _stage(
        'Loading Package Info...',
        () => _packageInfo ??= ref.read(packageInfoProvider.future),
      );
      if (!ref.mounted) {
        return (initialized: false, stage: null, errors: errors);
      }

      final bangSyncResults = await _stage(
        'Synchronizing Bangs...',
        () => _bangs ??= ref
            .read(bangSyncRepositoryProvider.notifier)
            .syncBundledBangGroups(),
      );
      for (final MapEntry(value: result) in bangSyncResults.entries) {
        result.onFailure(errors.add);
      }

      // The secure-storage claim and the account/restart handlers used to be
      // here as well, and `main` does all three again straight after awaiting
      // this. The duplicate cost was real — the claim enumerates secure storage,
      // which decrypts every record — and the copies here were the *ineffective*
      // ones: `ref.read` adds no listener, so a service started that way never
      // reacts again (see `_activateService` in main.dart). `main` holds the
      // ordering constraint they were written for, claiming before it reads the
      // account record.

      return (initialized: true, stage: null, errors: errors);
    });

    if (!ref.mounted) {
      return;
    }

    result.onFailure((_) => _resetPrewarm());

    state = result;
  }

  @override
  Result<({bool initialized, String? stage, List<ErrorMessage> errors})>
  build() {
    return Result.success((
      initialized: false,
      stage: null,
      errors: List.empty(),
    ));
  }
}
