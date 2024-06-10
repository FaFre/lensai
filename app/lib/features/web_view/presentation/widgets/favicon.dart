import 'package:bang_navigator/domain/entities/web_page_info.dart';
import 'package:bang_navigator/extensions/web_uri_favicon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class FaviconImage extends StatelessWidget {
  final double size;
  final Icon _iconPlaceholder;

  final WebPageInfo webPageInfo;

  FaviconImage({
    required this.webPageInfo,
    this.size = 16,
    super.key,
  }) : _iconPlaceholder = Icon(
          MdiIcons.webBox,
          size: size,
        );

  @override
  Widget build(BuildContext context) {
    if (webPageInfo.favicon != null) {
      return FadeInImage(
        placeholder: NetworkImage(
          webPageInfo.url.genericFavicon().toString(),
        ),
        image: NetworkImage(webPageInfo.favicon!.url.toString()),
        placeholderErrorBuilder: (_, __, ___) => _iconPlaceholder,
        imageErrorBuilder: (_, __, ___) => _iconPlaceholder,
        height: size,
        width: size,
      );
    } else {
      return Image.network(
        webPageInfo.url.genericFavicon().toString(),
        errorBuilder: (_, __, ___) => _iconPlaceholder,
        height: size,
        width: size,
      );
    }
  }
}
