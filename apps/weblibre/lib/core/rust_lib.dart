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
import 'package:privacypass_client/privacypass_client.dart';
import 'package:weblibre/core/logger.dart';

Future<void>? _ready;

/// Loads the Privacy Pass Rust library, once per process.
///
/// Only the search-credit token flow needs it — `search_client`'s issuance
/// client — and that cannot run until the user has signed in and opened web
/// search. `main` used to `await` this before `runApp`, putting a `dlopen` and
/// the flutter_rust_bridge handshake in front of the first frame for a library
/// nothing had asked for yet. Now `main` starts it and moves on, and the one
/// caller that needs it awaits this future.
///
/// Idempotent while it succeeds or is still resolving: every caller gets the
/// same future.
///
/// A *failure* is not cached. `await`ing this before `runApp` used to make a
/// broken load fatal and obvious; moving it off the startup path must not turn
/// it into a permanent silent one, where the cached rejected future kills search
/// credits for the life of the process with no way back. Clearing the slot means
/// the next issuance attempt tries the load again — and the error still reaches
/// that caller, which is where it can be reported.
Future<void> ensureRustLibInitialized() {
  return _ready ??= RustLib.init().onError<Object>((error, stackTrace) {
    _ready = null;
    logger.e(
      'Failed to initialize the Privacy Pass library',
      error: error,
      stackTrace: stackTrace,
    );

    Error.throwWithStackTrace(error, stackTrace);
  });
}
