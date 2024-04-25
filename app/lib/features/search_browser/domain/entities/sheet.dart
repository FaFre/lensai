import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';

sealed class Sheet {}

class CreateTab extends Sheet {
  final String? content;
  final KagiTool? preferredTool;

  bool get hasParameters => content != null || preferredTool != null;

  CreateTab({this.content, this.preferredTool});
}

class ViewTabs extends Sheet {}
