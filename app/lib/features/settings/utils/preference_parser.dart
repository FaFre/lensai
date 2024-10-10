import 'package:flutter/material.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';

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
