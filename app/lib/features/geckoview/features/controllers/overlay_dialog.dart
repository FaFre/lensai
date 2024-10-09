import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overlay_dialog.g.dart';

@Riverpod()
class OverlayDialogController extends _$OverlayDialogController {
  @override
  Widget? build() {
    return null;
  }

  void show(Widget dialog) {
    state = dialog;
  }

  void dismiss() {
    state = null;
  }
}
