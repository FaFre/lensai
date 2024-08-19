import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:lensai/extensions/web_uri_favicon.dart';

class FaviconImage extends StatelessWidget {
  final double size;
  final Icon _iconPlaceholder;

  final Favicon? favicon;
  final Uri url;

  FaviconImage({
    required this.url,
    required this.favicon,
    this.size = 16,
    super.key,
  }) : _iconPlaceholder = Icon(
          MdiIcons.webBox,
          size: size,
        );

  @override
  Widget build(BuildContext context) {
    if (favicon != null) {
      return FadeInImage(
        placeholder: NetworkImage(
          url.genericFavicon().toString(),
        ),
        image: NetworkImage(favicon!.url.toString()),
        placeholderErrorBuilder: (_, __, ___) => _iconPlaceholder,
        imageErrorBuilder: (_, __, ___) => Image.network(
          url.genericFavicon().toString(),
          errorBuilder: (_, __, ___) => _iconPlaceholder,
          height: size,
          width: size,
        ),
        height: size,
        width: size,
      );
    } else {
      return Image.network(
        url.genericFavicon().toString(),
        errorBuilder: (_, __, ___) => _iconPlaceholder,
        height: size,
        width: size,
      );
    }
  }
}
