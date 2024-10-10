import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';

part 'settings.g.dart';

@CopyWith()
class Settings with FastEquatable {
  final String? kagiSession;
  final bool showEarlyAccessFeatures;
  final bool incognitoMode;
  final bool enableJavascript;
  final bool launchUrlExternal;
  final bool blockHttpProtocol;
  final ThemeMode themeMode;
  final KagiTool? quickAction;
  final bool quickActionVoiceInput;
  final bool enableReadability;

  Settings({
    required this.kagiSession,
    required this.showEarlyAccessFeatures,
    required this.incognitoMode,
    required this.enableJavascript,
    required this.launchUrlExternal,
    required this.blockHttpProtocol,
    required this.themeMode,
    required this.quickAction,
    required this.quickActionVoiceInput,
    required this.enableReadability,
  });

  Settings.withDefaults({
    this.kagiSession,
    bool? showEarlyAccessFeatures,
    bool? incognitoMode,
    bool? enableJavascript,
    bool? launchUrlExternal,
    bool? enableContentBlocking,
    bool? blockHttpProtocol,
    ThemeMode? themeMode,
    this.quickAction,
    bool? quickActionVoiceInput,
    bool? enableReadability,
  })  : showEarlyAccessFeatures = showEarlyAccessFeatures ?? true,
        incognitoMode = incognitoMode ?? true,
        enableJavascript = enableJavascript ?? true,
        launchUrlExternal = launchUrlExternal ?? false,
        blockHttpProtocol = blockHttpProtocol ?? false,
        themeMode = themeMode ?? ThemeMode.dark,
        quickActionVoiceInput = quickActionVoiceInput ?? false,
        enableReadability = enableReadability ?? true;

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        kagiSession,
        showEarlyAccessFeatures,
        incognitoMode,
        enableJavascript,
        launchUrlExternal,
        blockHttpProtocol,
        themeMode,
        quickAction,
        quickActionVoiceInput,
        enableReadability,
      ];
}
