import 'dart:math';

import 'package:flutter/material.dart';

final _rnd = Random();

/// Check if is good condition to use white foreground color by passing
/// the background color, and optional bias.
///
/// Reference:
///
/// Old: https://www.w3.org/TR/WCAG20-TECHS/G18.html
///
/// New: https://github.com/mchome/flutter_statusbarcolor/issues/40
bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
  // Old:
  // return 1.05 / (color.computeLuminance() + 0.05) > 4.5;

  // New:
  final v = sqrt(
    pow(backgroundColor.red, 2) * 0.299 +
        pow(backgroundColor.green, 2) * 0.587 +
        pow(backgroundColor.blue, 2) * 0.114,
  ).round();
  return v < (130 + bias);
}

const List<List<Color>> colorTypes = [
  [Colors.red, Colors.redAccent],
  [Colors.pink, Colors.pinkAccent],
  [Colors.purple, Colors.purpleAccent],
  [Colors.deepPurple, Colors.deepPurpleAccent],
  [Colors.indigo, Colors.indigoAccent],
  [Colors.blue, Colors.blueAccent],
  [Colors.lightBlue, Colors.lightBlueAccent],
  [Colors.cyan, Colors.cyanAccent],
  [Colors.teal, Colors.tealAccent],
  [Colors.green, Colors.greenAccent],
  [Colors.lightGreen, Colors.lightGreenAccent],
  [Colors.lime, Colors.limeAccent],
  [Colors.yellow, Colors.yellowAccent],
  [Colors.amber, Colors.amberAccent],
  [Colors.orange, Colors.orangeAccent],
  [Colors.deepOrange, Colors.deepOrangeAccent],
  [Colors.brown],
  [Colors.grey],
  [Colors.blueGrey],
  [Colors.black],
];

List<Map<Color, String>> shadingTypes(List<Color> colors) {
  final List<Map<Color, String>> result = [];

  for (final Color colorType in colors) {
    if (colorType == Colors.grey) {
      result.addAll(
        [50, 100, 200, 300, 350, 400, 500, 600, 700, 800, 850, 900]
            .map((int shade) => {Colors.grey[shade]!: shade.toString()})
            .toList(),
      );
    } else if (colorType == Colors.black || colorType == Colors.white) {
      result.addAll([
        {Colors.black: ''},
        {Colors.white: ''},
      ]);
    } else if (colorType is MaterialAccentColor) {
      result.addAll(
        [100, 200, 400, 700]
            .map((int shade) => {colorType[shade]!: 'A$shade'})
            .toList(),
      );
    } else if (colorType is MaterialColor) {
      result.addAll(
        [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
            .map((int shade) => {colorType[shade]!: shade.toString()})
            .toList(),
      );
    } else {
      result.add({const Color(0x00000000): ''});
    }
  }

  return result;
}

Color randomColorShade(List<Color> colors) {
  final color = colors[_rnd.nextInt(colors.length)];
  final shades = shadingTypes([color]);

  return shades[_rnd.nextInt(shades.length)].keys.first;
}
