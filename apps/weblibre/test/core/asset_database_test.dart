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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/asset_database.dart';

const _assetPath = 'assets/fake/db.sqlite';

/// A page-aligned payload, because that is the case the size check got wrong:
/// two different SQLite databases of the same page count have the same length.
Uint8List _page(int fill) => Uint8List.fromList(List.filled(4096, fill));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File target;
  late File stamp;
  late Uint8List asset;
  var loads = 0;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('asset_db_test');
    target = File('${dir.path}/db.sqlite');
    stamp = File('${target.path}.asset');
    asset = _page(0xAA);
    loads = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = const StringCodec().decodeMessage(message);
          if (key != _assetPath) return null;
          loads++;
          return ByteData.view(asset.buffer);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    dir.deleteSync(recursive: true);
  });

  Future<void> install() =>
      installAssetDatabase(assetPath: _assetPath, target: target);

  test('installs on first run', () async {
    await install();

    expect(target.readAsBytesSync(), asset);
    expect(stamp.existsSync(), isTrue);
  });

  test('does not rewrite when the asset is unchanged', () async {
    await install();

    // Deliberately corrupt the installed copy while leaving the stamp alone.
    // Nothing does this in production — it is here because a rewrite is
    // otherwise indistinguishable from a skip (mtime has one-second granularity
    // on some filesystems, so comparing timestamps can pass vacuously). If the
    // second install rewrites, these bytes come back.
    final sentinel = Uint8List.fromList(List.filled(4096, 0x11));
    target.writeAsBytesSync(sentinel);

    await install();

    expect(
      target.readAsBytesSync(),
      sentinel,
      reason: 'The database was rewritten though the asset had not changed.',
    );
  });

  test('reinstalls when the asset changes but keeps its size', () async {
    await install();

    // The regression the size check let through: an app update ships new data,
    // and SQLite page alignment keeps the file exactly as long as before.
    asset = _page(0xBB);
    expect(asset.length, target.lengthSync());

    await install();

    expect(
      target.readAsBytesSync(),
      asset,
      reason:
          'Same length, different content — this is exactly the update a '
          'size-only check would ignore forever.',
    );
  });

  test('reinstalls when the copy was interrupted before the stamp', () async {
    await install();

    // What a process killed between the two writes leaves behind.
    stamp.deleteSync();
    target.writeAsBytesSync(Uint8List.fromList([1, 2, 3]));

    await install();

    expect(target.readAsBytesSync(), asset);
    expect(stamp.existsSync(), isTrue);
  });

  test('reinstalls when the stamp names a different asset', () async {
    await install();
    stamp.writeAsStringSync('not-the-digest');

    await install();

    expect(stamp.readAsStringSync(), isNot('not-the-digest'));
  });

  test('never reads the installed database back', () async {
    await install();
    await install();
    await install();

    // Three installs, three asset loads, and no digest of the file on disk —
    // the check costs one asset read, not two 1 MB reads.
    expect(loads, 3);
  });
}
