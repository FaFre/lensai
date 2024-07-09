import 'package:bang_navigator/features/content_block/data/models/host.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';

part 'settings.g.dart';

@CopyWith()
class Settings with FastEquatable {
  final String? kagiSession;
  final bool showEarlyAccessFeatures;
  final bool incognitoMode;
  final bool enableJavascript;
  final bool launchUrlExternal;
  final bool enableContentBlocking;
  final bool blockHttpProtocol;
  final Set<HostSource> enableHostList;
  final ThemeMode themeMode;
  final KagiTool? quickAction;
  final bool quickActionVoiceInput;

  Settings({
    required this.kagiSession,
    required this.showEarlyAccessFeatures,
    required this.incognitoMode,
    required this.enableJavascript,
    required this.launchUrlExternal,
    required this.enableContentBlocking,
    required this.blockHttpProtocol,
    required this.enableHostList,
    required this.themeMode,
    required this.quickAction,
    required this.quickActionVoiceInput,
  });

  Settings.withDefaults({
    this.kagiSession,
    bool? showEarlyAccessFeatures,
    bool? incognitoMode,
    bool? enableJavascript,
    bool? launchUrlExternal,
    bool? enableContentBlocking,
    bool? blockHttpProtocol,
    Set<HostSource>? enableHostList,
    ThemeMode? themeMode,
    this.quickAction,
    bool? quickActionVoiceInput,
  })  : showEarlyAccessFeatures = showEarlyAccessFeatures ?? true,
        incognitoMode = incognitoMode ?? true,
        enableJavascript = enableJavascript ?? true,
        launchUrlExternal = launchUrlExternal ?? false,
        enableContentBlocking = enableContentBlocking ?? true,
        blockHttpProtocol = blockHttpProtocol ?? false,
        enableHostList = enableHostList ?? {HostSource.stevenBlackUnified},
        themeMode = themeMode ?? ThemeMode.dark,
        quickActionVoiceInput = quickActionVoiceInput ?? false;

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        kagiSession,
        showEarlyAccessFeatures,
        incognitoMode,
        enableJavascript,
        launchUrlExternal,
        enableContentBlocking,
        blockHttpProtocol,
        enableHostList,
        themeMode,
        quickAction,
        quickActionVoiceInput,
      ];
}
