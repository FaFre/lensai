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
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:weblibre/core/logger.dart';
import 'package:xxh3/xxh3.dart';

/// Suffix of the file recording which asset version is installed.
///
/// Public because the backup contract has to know about it: the databases it
/// stamps are declared excluded from an archive, and an exclusion that named
/// only the database would let the stamp travel without it.
const assetStampSuffix = '.asset';

/// Installs a read-only database that ships as an asset, if the installed copy
/// is not already the one this build carries.
///
/// The bundled file is the only writer: these databases are generated at build
/// time and never modified at runtime, so a copy is owed exactly once per
/// shipped version. Both call sites used to copy unconditionally on every
/// process start — `sites.db` is ~1 MB and `quotes.db` ~190 KB, written with
/// `flush: true`, so every launch that touched the omnibar or the home surface
/// paid an fsync for bytes that were already there.
///
/// "Already installed" is decided by a digest of the asset, recorded in a
/// sidecar next to the database when the copy completes. Size alone is not
/// enough and was wrong here: a SQLite file is page-aligned, so a regenerated
/// `sites.db` with different rows very plausibly lands on exactly the same byte
/// count, and an app update shipping new data would then be ignored forever.
///
/// The digest covers the *asset*, never the installed file, so nothing reads the
/// database back off disk. Writing the sidecar only after the database write has
/// returned is also what makes a partial copy self-correcting: a launch killed
/// mid-write leaves the old sidecar (or none), so the next start reinstalls.
Future<File> installAssetDatabase({
  required String assetPath,
  required File target,
}) async {
  final blob = await rootBundle.load(assetPath);
  final bytes = blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes);

  // xxh3 rather than a cryptographic hash: this answers "is this the same build
  // artefact", not "did someone tamper with it" — the file is inside the APK
  // either way — and it runs at GB/s, where sha256 over 1 MB would put real
  // milliseconds back into the path this is meant to make cheap.
  final digest = xxh3(bytes).toRadixString(16);
  final stamp = File('${target.path}$assetStampSuffix');

  if (target.existsSync() && stamp.existsSync()) {
    final installed = await stamp.readAsString().catchError((_) => '');
    if (installed.trim() == digest) {
      return target;
    }
  }

  await target.parent.create(recursive: true);

  // The stamp is cleared first, so a crash between the two writes leaves the
  // database unclaimed rather than claimed by a digest it does not match.
  if (stamp.existsSync()) {
    await stamp.delete();
  }

  await target.writeAsBytes(bytes, flush: true);
  await stamp.writeAsString(digest, flush: true);

  logger.i(
    'Installed asset database $assetPath '
    '(${blob.lengthInBytes}B, $digest)',
  );

  return target;
}
