import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_icon_picker_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

void main() {
  testWidgets('uses the shared drag handle and still selects a searched icon', (
    tester,
  ) async {
    IconData? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContainerIconPickerSheet(
            selectedColor: Colors.blue,
            selectedIcon: MdiIcons.home,
            onSelected: (icon) => selected = icon,
          ),
        ),
      ),
    );

    expect(find.byType(SheetDragHandle), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'account-heart');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('account-heart'));

    expect(selected, MdiIcons.accountHeart);
    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
