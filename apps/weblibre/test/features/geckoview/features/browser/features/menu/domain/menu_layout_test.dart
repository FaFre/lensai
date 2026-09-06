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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';

MenuSectionEntry _section(
  MenuSectionType type, {
  bool visible = true,
  List<MenuItemEntry> items = const [],
}) => MenuSectionEntry(type: type, visible: visible, items: items);

MenuItemEntry _item(MenuItemType type, {bool visible = true}) =>
    MenuItemEntry(type: type, visible: visible);

List<MenuSectionType> _sectionTypes(List<MenuSectionEntry> entries) =>
    entries.map((entry) => entry.type).toList();

List<MenuItemType> _itemTypes(
  List<MenuSectionEntry> entries,
  MenuSectionType section,
) => entries
    .firstWhere((entry) => entry.type == section)
    .items
    .map((item) => item.type)
    .toList();

void main() {
  group('menuLayoutDefaults', () {
    test('offers every section exactly once', () {
      final offered = menuLayoutDefaults
          .map((section) => section.type)
          .toList();

      expect(offered.toSet(), MenuSectionType.values.toSet());
      expect(offered.length, MenuSectionType.values.length);
    });

    test('places every item in exactly one section', () {
      List<MenuItemType> flatten(List<MenuItemDefault> items) => [
        for (final item in items) ...[item.type, ...flatten(item.items)],
      ];

      final placed = [
        for (final section in menuLayoutDefaults) ...flatten(section.items),
      ];

      // A [MenuItemType] that no section claims can never be rendered, and one
      // claimed twice would be arrangeable in two places at once.
      expect(placed.toSet(), MenuItemType.values.toSet());
      expect(placed.length, MenuItemType.values.length);
    });

    test('starts every section and item switched on', () {
      // The shipped menu is the layout users see before they touch anything,
      // so nothing may default to hidden without the sheet changing too.
      bool allOn(List<MenuItemDefault> items) =>
          items.every((item) => item.visible && allOn(item.items));

      expect(menuLayoutDefaults.every((section) => section.visible), isTrue);
      expect(
        menuLayoutDefaults.every((section) => allOn(section.items)),
        isTrue,
      );
    });
  });

  group('mergeMenuLayoutWithDefaults', () {
    test('uses the defaults verbatim when nothing is persisted', () {
      final merged = mergeMenuLayoutWithDefaults(null);

      expect(
        _sectionTypes(merged),
        menuLayoutDefaults.map((section) => section.type).toList(),
      );
      expect(
        _itemTypes(merged, MenuSectionType.tabActions),
        menuLayoutDefaults
            .firstWhere((section) => section.type == MenuSectionType.tabActions)
            .items
            .map((item) => item.type)
            .toList(),
      );
    });

    test('preserves a reordered section list and its visibility', () {
      const defaults = <MenuSectionDefault>[
        MenuSectionDefault(MenuSectionType.quickToggles),
        MenuSectionDefault(MenuSectionType.quickLinks),
        MenuSectionDefault(MenuSectionType.profile),
      ];
      final persisted = [
        _section(MenuSectionType.quickLinks),
        _section(MenuSectionType.profile, visible: false),
        _section(MenuSectionType.quickToggles),
      ];

      final merged = mergeMenuLayoutWithDefaults(persisted, defaults);

      expect(_sectionTypes(merged), _sectionTypes(persisted));
      expect(
        merged.firstWhere((s) => s.type == MenuSectionType.profile).visible,
        isFalse,
      );
    });

    test('preserves a reordered item list inside a section', () {
      const defaults = <MenuSectionDefault>[
        MenuSectionDefault(
          MenuSectionType.quickLinks,
          items: [
            MenuItemDefault(MenuItemType.history),
            MenuItemDefault(MenuItemType.bookmarks),
            MenuItemDefault(MenuItemType.downloads),
          ],
        ),
      ];
      final persisted = [
        _section(
          MenuSectionType.quickLinks,
          items: [
            _item(MenuItemType.downloads),
            _item(MenuItemType.history),
            _item(MenuItemType.bookmarks, visible: false),
          ],
        ),
      ];

      final merged = mergeMenuLayoutWithDefaults(persisted, defaults);

      expect(_itemTypes(merged, MenuSectionType.quickLinks), [
        MenuItemType.downloads,
        MenuItemType.history,
        MenuItemType.bookmarks,
      ]);
      expect(merged.single.visibleItemTypes, [
        MenuItemType.downloads,
        MenuItemType.history,
      ]);
    });

    test('drops sections and items that are no longer offered', () {
      const defaults = <MenuSectionDefault>[
        MenuSectionDefault(
          MenuSectionType.quickLinks,
          items: [MenuItemDefault(MenuItemType.history)],
        ),
      ];
      final persisted = [
        _section(
          MenuSectionType.quickLinks,
          items: [_item(MenuItemType.history), _item(MenuItemType.bangs)],
        ),
        _section(MenuSectionType.connection),
      ];

      final merged = mergeMenuLayoutWithDefaults(persisted, defaults);

      expect(_sectionTypes(merged), [MenuSectionType.quickLinks]);
      expect(_itemTypes(merged, MenuSectionType.quickLinks), [
        MenuItemType.history,
      ]);
    });

    test('inserts a newly offered section at its designed position', () {
      const defaults = <MenuSectionDefault>[
        MenuSectionDefault(MenuSectionType.quickToggles),
        MenuSectionDefault(MenuSectionType.pageActions, visible: false),
        MenuSectionDefault(MenuSectionType.quickLinks),
      ];
      // Saved before pageActions existed, and reordered since.
      final persisted = [
        _section(MenuSectionType.quickLinks),
        _section(MenuSectionType.quickToggles),
      ];

      final merged = mergeMenuLayoutWithDefaults(persisted, defaults);

      // Second, as the defaults ask — not appended to the bottom of the
      // user's list.
      expect(_sectionTypes(merged), [
        MenuSectionType.quickLinks,
        MenuSectionType.pageActions,
        MenuSectionType.quickToggles,
      ]);
      // And off, because that is how it is offered: adding a section must not
      // change the menu of someone who already arranged theirs.
      expect(
        merged.firstWhere((s) => s.type == MenuSectionType.pageActions).visible,
        isFalse,
      );
    });

    test('inserts a newly offered item at its designed position', () {
      const defaults = <MenuSectionDefault>[
        MenuSectionDefault(
          MenuSectionType.pageActions,
          items: [
            MenuItemDefault(MenuItemType.addBookmark),
            MenuItemDefault(MenuItemType.findInPage),
            MenuItemDefault(MenuItemType.translatePage, visible: false),
          ],
        ),
      ];
      final persisted = [
        _section(
          MenuSectionType.pageActions,
          items: [
            _item(MenuItemType.findInPage),
            _item(MenuItemType.addBookmark),
          ],
        ),
      ];

      final merged = mergeMenuLayoutWithDefaults(persisted, defaults);

      expect(_itemTypes(merged, MenuSectionType.pageActions), [
        MenuItemType.findInPage,
        MenuItemType.addBookmark,
        MenuItemType.translatePage,
      ]);
      expect(merged.single.visibleItemTypes, [
        MenuItemType.findInPage,
        MenuItemType.addBookmark,
      ]);
    });

    test('preserves a reordered list of the rows a row reveals', () {
      const defaults = [
        MenuSectionDefault(
          MenuSectionType.tabActions,
          items: [
            MenuItemDefault(
              MenuItemType.share,
              items: [
                MenuItemDefault(MenuItemType.copyAddress),
                MenuItemDefault(MenuItemType.shareLink),
                MenuItemDefault(MenuItemType.showQrCode),
              ],
            ),
          ],
        ),
      ];
      final persisted = [
        _section(
          MenuSectionType.tabActions,
          items: [
            MenuItemEntry(
              type: MenuItemType.share,
              visible: true,
              items: [
                _item(MenuItemType.showQrCode),
                _item(MenuItemType.copyAddress),
                _item(MenuItemType.shareLink, visible: false),
              ],
            ),
          ],
        ),
      ];

      final merged = mergeMenuLayoutWithDefaults(persisted, defaults);
      final share = merged.single.items.single;

      expect(share.items.map((item) => item.type), [
        MenuItemType.showQrCode,
        MenuItemType.copyAddress,
        MenuItemType.shareLink,
      ]);
      expect(share.visibleItems.map((item) => item.type), [
        MenuItemType.showQrCode,
        MenuItemType.copyAddress,
      ]);
    });

    test('fills in the rows of a row persisted before it had any', () {
      const defaults = [
        MenuSectionDefault(
          MenuSectionType.tabActions,
          items: [
            MenuItemDefault(
              MenuItemType.export,
              items: [
                MenuItemDefault(MenuItemType.exportAsPdf),
                MenuItemDefault(MenuItemType.printPage),
              ],
            ),
          ],
        ),
      ];
      // Saved by a build where Export was a leaf.
      final persisted = [
        _section(
          MenuSectionType.tabActions,
          items: [_item(MenuItemType.export)],
        ),
      ];

      final merged = mergeMenuLayoutWithDefaults(persisted, defaults);

      expect(merged.single.items.single.items.map((item) => item.type), [
        MenuItemType.exportAsPdf,
        MenuItemType.printPage,
      ]);
    });

    test('gives a section persisted without items the offered ones', () {
      const defaults = <MenuSectionDefault>[
        MenuSectionDefault(
          MenuSectionType.about,
          items: [MenuItemDefault(MenuItemType.about)],
        ),
      ];

      final merged = mergeMenuLayoutWithDefaults([
        _section(MenuSectionType.about),
      ], defaults);

      expect(_itemTypes(merged, MenuSectionType.about), [MenuItemType.about]);
    });
  });

  group('menuItemEntriesFromJson', () {
    test('drops entries that no longer decode', () {
      final decoded = menuItemEntriesFromJson([
        {'type': 'history', 'visible': true},
        {'type': 'a_retired_item', 'visible': true},
        {'type': 'bookmarks', 'visible': false},
      ]);

      // One retired item must not cost the user the rest of the section.
      expect(decoded.map((item) => item.type), [
        MenuItemType.history,
        MenuItemType.bookmarks,
      ]);
      expect(decoded.last.visible, isFalse);
    });

    test('keeps the rows nested under a row', () {
      final decoded = menuItemEntriesFromJson([
        {
          'type': 'share',
          'visible': true,
          'items': [
            {'type': 'showQrCode', 'visible': true},
            {'type': 'a_retired_row', 'visible': true},
          ],
        },
      ]);

      expect(decoded.single.items.map((item) => item.type), [
        MenuItemType.showQrCode,
      ]);
    });

    test('reads anything that is not a list as no arrangement', () {
      expect(menuItemEntriesFromJson(null), isEmpty);
      expect(menuItemEntriesFromJson('items'), isEmpty);
    });
  });
}
