import 'package:fast_equatable/fast_equatable.dart';
import 'package:lensai/features/search_browser/domain/entities/modes.dart';

// ignore: missing_override_of_must_be_overridden
sealed class Sheet with FastEquatable {}

class CreateTab extends Sheet {
  final String? content;
  final KagiTool? preferredTool;

  bool get hasParameters => content != null || preferredTool != null;

  CreateTab({this.content, this.preferredTool});

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [content, preferredTool];
}

class ViewTabs extends Sheet {
  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [];
}
