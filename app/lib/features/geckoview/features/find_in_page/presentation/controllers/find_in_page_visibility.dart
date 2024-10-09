import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'find_in_page_visibility.g.dart';

@Riverpod()
class FindInPageVisibilityController extends _$FindInPageVisibilityController {
  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }

  @override
  bool build() {
    return false;
  }
}
