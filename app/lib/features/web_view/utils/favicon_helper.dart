import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Favicon? choseFavicon(Iterable<Favicon>? favicons, [Favicon? currentIcon]) {
  var selectedIcon = currentIcon;

  if (favicons != null) {
    for (final icon in favicons) {
      if (selectedIcon == null) {
        selectedIcon = icon;
      } else {
        if ((selectedIcon.width == null &&
                !selectedIcon.url.toString().endsWith("favicon.ico")) ||
            (icon.width != null &&
                selectedIcon.width != null &&
                icon.width! > selectedIcon.width!)) {
          selectedIcon = icon;
        }
      }
    }
  }

  return selectedIcon;
}
