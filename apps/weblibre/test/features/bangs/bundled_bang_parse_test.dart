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
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/services/data_source.dart';

const _assetJson = '''
[
  {"s":"Wikipedia","d":"en.wikipedia.org","t":"w",
   "u":"https://en.wikipedia.org/wiki/Special:Search?search={{{s}}}",
   "c":"Reference","sc":"Encyclopedias"},
  {"s":"GitHub","d":"github.com","t":"gh",
   "u":"https://github.com/search?q={{{s}}}"}
]
''';

void main() {
  group('parseBundledBangs', () {
    test('decodes entries and stamps the group', () {
      final bangs = parseBundledBangs(_assetJson, BangGroup.kagi);

      expect(bangs.map((bang) => bang.trigger), ['w', 'gh']);
      expect(bangs.map((bang) => bang.group), everyElement(BangGroup.kagi));
      expect(bangs.first.domain, 'en.wikipedia.org');
      expect(bangs.first.category, 'Reference');
      expect(bangs.last.category, isNull);
    });

    test('leaves the group alone when none is given', () {
      final bangs = parseBundledBangs(_assetJson, null);

      expect(bangs.map((bang) => bang.group), everyElement(isNull));
    });

    test(
      'runs in a background isolate, which is the point of extracting it',
      () async {
        // The bundled import hands this to `computeWithDatabase`, so it has to
        // be callable with no binding and no services of its own. A plain
        // `Isolate.run` is the same constraint, and it fails loudly here rather
        // than as a startup error on the first launch after an app update.
        final triggers = await Isolate.run(
          () => parseBundledBangs(
            _assetJson,
            BangGroup.kagi,
          ).map((bang) => bang.trigger).toList(),
        );

        expect(triggers, ['w', 'gh']);
      },
    );
  });
}
