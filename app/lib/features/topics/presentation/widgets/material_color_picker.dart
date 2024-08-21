// The Color Picker which contains Material Design Color Palette.
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lensai/features/topics/utils/color_palette.dart';

class MaterialPicker extends StatefulWidget {
  const MaterialPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.onPrimaryChanged,
    this.enableLabel = false,
    this.portraitOnly = false,
  });

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color>? onPrimaryChanged;
  final bool enableLabel;
  final bool portraitOnly;

  @override
  State<StatefulWidget> createState() => _MaterialPickerState();
}

class _MaterialPickerState extends State<MaterialPicker> {
  List<Color> _currentColorType = [Colors.red, Colors.redAccent];
  Color _currentShading = Colors.transparent;

  @override
  void initState() {
    for (final colors in colorTypes) {
      shadingTypes(colors).forEach((Map<Color, String> color) {
        if (widget.pickerColor.value == color.keys.first.value) {
          return setState(() {
            _currentColorType = colors;
            _currentShading = color.keys.first;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait ||
            widget.portraitOnly;

    Widget colorList() {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Container(
          margin: isPortrait
              ? const EdgeInsets.only(right: 10)
              : const EdgeInsets.only(bottom: 10),
          width: isPortrait ? 60 : null,
          height: isPortrait ? null : 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: (Theme.of(context).brightness == Brightness.light)
                    ? (Theme.of(context).brightness == Brightness.light)
                        ? Colors.grey[300]!
                        : Colors.black38
                    : Colors.black38,
                blurRadius: 10,
              ),
            ],
            border: isPortrait
                ? Border(
                    right: BorderSide(
                      color: (Theme.of(context).brightness == Brightness.light)
                          ? Colors.grey[300]!
                          : Colors.black38,
                    ),
                  )
                : Border(
                    top: BorderSide(
                      color: (Theme.of(context).brightness == Brightness.light)
                          ? Colors.grey[300]!
                          : Colors.black38,
                    ),
                  ),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
            child: FadingScroll(
              fadingSize: 25,
              builder: (context, controller) {
                return ListView(
                  controller: controller,
                  scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
                  children: [
                    if (isPortrait)
                      const Padding(padding: EdgeInsets.only(top: 7))
                    else
                      const Padding(padding: EdgeInsets.only(left: 7)),
                    ...colorTypes.map((List<Color> colors) {
                      final Color colorType = colors[0];
                      return GestureDetector(
                        onTap: () {
                          if (widget.onPrimaryChanged != null) {
                            widget.onPrimaryChanged!.call(colorType);
                          }
                          setState(() => _currentColorType = colors);
                        },
                        child: Container(
                          color: const Color(0x00000000),
                          padding: isPortrait
                              ? const EdgeInsets.fromLTRB(0, 7, 0, 7)
                              : const EdgeInsets.fromLTRB(7, 0, 7, 0),
                          child: Align(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: colorType,
                                shape: BoxShape.circle,
                                boxShadow: _currentColorType == colors
                                    ? [
                                        if (colorType ==
                                            Theme.of(context).cardColor)
                                          BoxShadow(
                                            color:
                                                (Theme.of(context).brightness ==
                                                        Brightness.light)
                                                    ? Colors.grey[300]!
                                                    : Colors.black38,
                                            blurRadius: 10,
                                          )
                                        else
                                          BoxShadow(
                                            color: colorType,
                                            blurRadius: 10,
                                          ),
                                      ]
                                    : null,
                                border: colorType == Theme.of(context).cardColor
                                    ? Border.all(
                                        color: (Theme.of(context).brightness ==
                                                Brightness.light)
                                            ? Colors.grey[300]!
                                            : Colors.black38,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (isPortrait)
                      const Padding(padding: EdgeInsets.only(top: 5))
                    else
                      const Padding(padding: EdgeInsets.only(left: 5)),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    Widget shadingList() {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context)
            .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
              children: [
                if (isPortrait)
                  const Padding(padding: EdgeInsets.only(top: 15))
                else
                  const Padding(padding: EdgeInsets.only(left: 15)),
                ...shadingTypes(_currentColorType)
                    .map((Map<Color, String> colors) {
                  final Color color = colors.keys.first;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentShading = color);
                      widget.onColorChanged(color);
                    },
                    child: Container(
                      color: const Color(0x00000000),
                      margin: isPortrait
                          ? const EdgeInsets.only(right: 10)
                          : const EdgeInsets.only(bottom: 10),
                      padding: isPortrait
                          ? const EdgeInsets.fromLTRB(0, 7, 0, 7)
                          : const EdgeInsets.fromLTRB(7, 0, 7, 0),
                      child: Align(
                        child: AnimatedContainer(
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(milliseconds: 500),
                          width: isPortrait
                              ? (_currentShading == color ? 250 : 230)
                              : (_currentShading == color ? 50 : 30),
                          height: isPortrait ? 50 : 220,
                          decoration: BoxDecoration(
                            color: color,
                            boxShadow: _currentShading == color
                                ? [
                                    if ((color == Colors.white) ||
                                        (color == Colors.black))
                                      BoxShadow(
                                        color: (Theme.of(context).brightness ==
                                                Brightness.light)
                                            ? Colors.grey[300]!
                                            : Colors.black38,
                                        blurRadius: 10,
                                      )
                                    else
                                      BoxShadow(
                                        color: color,
                                        blurRadius: 10,
                                      ),
                                  ]
                                : null,
                            border: (color == Colors.white) ||
                                    (color == Colors.black)
                                ? Border.all(
                                    color: (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? Colors.grey[300]!
                                        : Colors.black38,
                                  )
                                : null,
                          ),
                          child: widget.enableLabel
                              ? isPortrait
                                  ? Row(
                                      children: [
                                        Text(
                                          '  ${colors.values.first}',
                                          style: TextStyle(
                                            color: useWhiteForeground(color)
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '#${color.toString().replaceFirst('Color(0xff', '').replaceFirst(')', '').toUpperCase()}  ',
                                              style: TextStyle(
                                                color: useWhiteForeground(color)
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      opacity: _currentShading == color ? 1 : 0,
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 16),
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          colors.values.first,
                                          style: TextStyle(
                                            color: useWhiteForeground(color)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          softWrap: false,
                                        ),
                                      ),
                                    )
                              : const SizedBox(),
                        ),
                      ),
                    ),
                  );
                }),
                if (isPortrait)
                  const Padding(padding: EdgeInsets.only(top: 15))
                else
                  const Padding(padding: EdgeInsets.only(left: 15)),
              ],
            );
          },
        ),
      );
    }

    if (isPortrait) {
      return SizedBox(
        width: 350,
        height: 500,
        child: Row(
          children: <Widget>[
            colorList(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: shadingList(),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 500,
        height: 300,
        child: Column(
          children: <Widget>[
            colorList(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: shadingList(),
              ),
            ),
          ],
        ),
      );
    }
  }
}
