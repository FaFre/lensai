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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';

/// The 800x600 test surface, so sizes and pixel offsets can be read off each
/// other: a sheet at extent 0.5 is 300px tall and starts halfway down.
const _viewportHeight = 600.0;
const _chromeHeight = 60.0;

/// Mirrors the shape every sheet in the app has: a drag handle or header with
/// no scrollable of its own, above the sheet's list.
class _Harness extends StatelessWidget {
  final DraggableScrollableController? sheetController;
  final ValueChanged<ScrollController> onContentController;
  final ValueChanged<double> onExtent;

  /// When given, the first row of the sheet's list is a list of its own.
  final ScrollController? nestedController;

  /// Mounts a second list on the sheet's controller, the way an
  /// [AnimatedSwitcher] does while it cross-fades two panels of one sheet.
  final bool duplicateContent;

  const _Harness({
    required this.sheetController,
    required this.onContentController,
    required this.onExtent,
    this.nestedController,
    this.duplicateContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // Aligned the way the browser positions its sheets: `expand: false`
        // alone leaves the sheet shrink-wrapped at the top of the body.
        body: Align(
          alignment: Alignment.bottomCenter,
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              onExtent(notification.extent);
              return false;
            },
            child: PointerScrollableSheet(
              controller: sheetController,
              expand: false,
              initialChildSize: 0.5,
              minChildSize: 0.1,
              builder: (context, scrollController) {
                onContentController(scrollController);

                return Material(
                  child: Column(
                    children: [
                      Container(
                        height: _chromeHeight,
                        color: const Color(0xFF000000),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 20,
                          itemBuilder: (context, index) => SizedBox(
                            height: 100,
                            child: index == 0 && nestedController != null
                                ? ListView.builder(
                                    controller: nestedController,
                                    itemCount: 5,
                                    itemBuilder: (context, index) => SizedBox(
                                      height: 100,
                                      child: Text('nested $index'),
                                    ),
                                  )
                                : Text('item $index'),
                          ),
                        ),
                      ),
                      if (duplicateContent)
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: 20,
                            itemBuilder: (context, index) => SizedBox(
                              height: 100,
                              child: Text('other $index'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

extension on WidgetTester {
  /// Sends a single wheel notch of [dy] logical pixels at [y].
  Future<void> wheel(double y, double dy) async {
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await sendEventToBinding(pointer.hover(Offset(400, y)));
    await sendEventToBinding(pointer.scroll(Offset(0, dy)));
    await pump();
  }
}

void main() {
  late DraggableScrollableController sheetController;
  late ScrollController contentController;
  var extent = 0.5;

  Future<void> pumpSheet(
    WidgetTester tester, {
    ScrollController? nestedController,
    bool withController = true,
    bool duplicateContent = false,
  }) async {
    extent = 0.5;
    sheetController = DraggableScrollableController();
    addTearDown(sheetController.dispose);

    await tester.pumpWidget(
      _Harness(
        sheetController: withController ? sheetController : null,
        onContentController: (controller) => contentController = controller,
        onExtent: (value) => extent = value,
        nestedController: nestedController,
        duplicateContent: duplicateContent,
      ),
    );
  }

  /// The top of the sheet, i.e. where its chrome sits.
  double chromeCenter() => _viewportHeight * (1 - extent) + _chromeHeight / 2;

  testWidgets('a notch up over the list collapses the sheet once it is at the '
      'top', (tester) async {
    await pumpSheet(tester);

    await tester.wheel(_viewportHeight - 50, -120);

    // 300px tall, 120px less: 180/600.
    expect(sheetController.size, closeTo(0.3, 0.001));
    expect(contentController.position.pixels, 0.0);
  });

  testWidgets('a notch down over the list leaves the sheet alone', (
    tester,
  ) async {
    await pumpSheet(tester);

    await tester.wheel(_viewportHeight - 50, 120);

    // The list under the cursor claimed the notch; moving the sheet as well
    // would have travelled twice as far as the wheel asked for.
    expect(sheetController.size, closeTo(0.5, 0.001));
    expect(contentController.position.pixels, greaterThan(0.0));
  });

  testWidgets('the list is what collapses first, not the sheet', (
    tester,
  ) async {
    await pumpSheet(tester);

    await tester.wheel(_viewportHeight - 50, 240);
    expect(contentController.position.pixels, greaterThan(0.0));

    await tester.wheel(_viewportHeight - 50, -120);

    expect(sheetController.size, closeTo(0.5, 0.001));
    expect(contentController.position.pixels, 120.0);
  });

  testWidgets('a nested scrollable keeps the notch to itself', (tester) async {
    final nestedController = ScrollController();
    addTearDown(nestedController.dispose);

    await pumpSheet(tester, nestedController: nestedController);

    // Over the first row of the sheet's list, which is a list of its own.
    const overNested = _viewportHeight - 200;

    await tester.wheel(overNested, 120);
    expect(nestedController.position.pixels, 120.0);
    expect(contentController.position.pixels, 0.0);
    expect(sheetController.size, closeTo(0.5, 0.001));

    // Back up. The sheet's own list is still at its top, so a sheet that
    // decided from that list alone would collapse on the same notch that
    // scrolls the nested one.
    await tester.wheel(overNested, -120);
    expect(nestedController.position.pixels, 0.0);
    expect(sheetController.size, closeTo(0.5, 0.001));
  });

  testWidgets('a notch over the chrome resizes the sheet in both directions', (
    tester,
  ) async {
    await pumpSheet(tester);

    await tester.wheel(chromeCenter(), 120);
    expect(sheetController.size, closeTo(0.7, 0.001));

    await tester.wheel(chromeCenter(), -240);
    expect(sheetController.size, closeTo(0.3, 0.001));
    expect(contentController.position.pixels, 0.0);
  });

  testWidgets('a notch over the chrome reaches the list once the sheet is '
      'fully expanded', (tester) async {
    await pumpSheet(tester);

    sheetController.jumpTo(1.0);
    await tester.pump();

    await tester.wheel(chromeCenter(), 120);

    expect(sheetController.size, 1.0);
    expect(contentController.position.pixels, 120.0);
  });

  testWidgets('the sheet stops at its minimum extent', (tester) async {
    await pumpSheet(tester);

    await tester.wheel(chromeCenter(), -600);

    expect(sheetController.size, closeTo(0.1, 0.001));
  });

  testWidgets('a notch is dropped while two lists share the controller', (
    tester,
  ) async {
    await pumpSheet(tester, duplicateContent: true);

    // Both `ScrollController.position` and the sheet's own `jumpTo` throw while
    // a controller has more than one position attached, so the notch has to go
    // nowhere rather than half-way.
    await tester.wheel(chromeCenter(), 120);

    expect(tester.takeException(), isNull);
    expect(sheetController.size, closeTo(0.5, 0.001));
  });

  testWidgets('a sheet given no controller resizes on its own', (tester) async {
    await pumpSheet(tester, withController: false);

    await tester.wheel(chromeCenter(), 120);

    expect(extent, closeTo(0.7, 0.001));
  });
}
