import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';

part 'settings.g.dart';

@CopyWith()
class Settings with FastEquatable {
  final String? kagiSession;
  final bool incognitoMode;
  final bool enableJavascript;
  final bool launchUrlExternal;

  Settings({
    required this.kagiSession,
    required this.incognitoMode,
    required this.enableJavascript,
    required this.launchUrlExternal,
  });

  Settings.withDefaults({
    required this.kagiSession,
    bool? incognitoMode,
    bool? enableJavascript,
    bool? launchUrlExternal,
  })  : incognitoMode = incognitoMode ?? true,
        enableJavascript = enableJavascript ?? true,
        launchUrlExternal = launchUrlExternal ?? false;

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        kagiSession,
        incognitoMode,
        enableJavascript,
        launchUrlExternal,
      ];
}
