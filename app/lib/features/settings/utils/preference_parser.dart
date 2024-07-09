import 'package:bang_navigator/features/content_block/data/models/host.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

Set<HostSource>? parseHostSources(List<String>? input) => input
    ?.map(
      (list) =>
          HostSource.values.firstWhereOrNull((source) => source.name == list),
    )
    .whereNotNull()
    .toSet();

ThemeMode? parseThemeMode(int? index) {
  if (index != null && index < ThemeMode.values.length) {
    return ThemeMode.values[index];
  }

  return null;
}

KagiTool? parseKagiTool(int? index) {
  if (index != null && index < ThemeMode.values.length) {
    return KagiTool.values[index];
  }

  return null;
}
