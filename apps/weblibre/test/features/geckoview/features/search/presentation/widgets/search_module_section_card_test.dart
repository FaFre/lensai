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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';

/// The persisted order without its storage: [SearchModuleOrder.build] normally
/// goes through `persist()` and a database this test has no use for.
class _FixedOrder extends SearchModuleOrder {
  @override
  List<ModuleOrderEntry> build(ModuleSurface surface) => [
    ModuleOrderEntry(type: SearchModuleType.quote, visible: true),
  ];
}

void main() {
  // The scope is built inside `pumpWidget` rather than returned from here: a
  // `ProviderScope` handed to it directly is the root one, and only a *scoped*
  // scope has to declare `dependencies` for the providers it overrides.
  Future<void> pumpHarness(WidgetTester tester, {required bool card}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchModuleOrderProvider(
            ModuleSurface.search,
          ).overrideWith(_FixedOrder.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SearchModuleSection(
                  title: 'A thought for the road',
                  moduleType: SearchModuleType.quote,
                  totalCount: 0,
                  showPagination: false,
                  card: card,
                  // Without a ModuleSurfaceScope the section behaves like the
                  // search screen, which is the surface that pins its headers.
                  surface: ModuleSurface.search,
                  headerLeading: const Icon(Icons.format_quote),
                  contentSliverBuilder:
                      ({required isCollapsed, required visibleCount}) => [
                        if (!isCollapsed)
                          const SliverToBoxAdapter(child: Text('body')),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a card never pins its header', (tester) async {
    await pumpHarness(tester, card: true);

    expect(find.byType(DecoratedSliver), findsOneWidget);
    // A pinned header would detach from the decoration painted across the
    // section's own extent and float over whatever follows.
    expect(find.byType(SliverPinnedHeader), findsNothing);
  });

  testWidgets('a plain section still pins on a pinning surface', (
    tester,
  ) async {
    await pumpHarness(tester, card: false);

    expect(find.byType(SliverPinnedHeader), findsOneWidget);
    expect(find.byType(DecoratedSliver), findsNothing);
  });

  testWidgets('a card keeps the title, the mark and the body', (tester) async {
    await pumpHarness(tester, card: true);

    // Sentence case, not the list surfaces' uppercase micro-label.
    expect(find.text('A thought for the road'), findsOneWidget);
    expect(find.byIcon(Icons.format_quote), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('a card still collapses from its header', (tester) async {
    await pumpHarness(tester, card: true);

    expect(find.text('body'), findsOneWidget);

    await tester.tap(find.text('A thought for the road'));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsNothing);
    // The card itself survives so there is something to expand again.
    expect(find.byType(DecoratedSliver), findsOneWidget);
  });
}
