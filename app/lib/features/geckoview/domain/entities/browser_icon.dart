import 'dart:typed_data';
import 'dart:ui';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/domain/entities/equatable_image.dart';
import 'package:lensai/extensions/image.dart';
import 'package:lensai/features/geckoview/utils/image_helper.dart';

class BrowserIcon with FastEquatable {
  final EquatableImage image;

  final Color? dominantColor;
  final IconSource source;

  static Future<BrowserIcon> fromBytes(
    Uint8List bytes, {
    required Color? dominantColor,
    required IconSource source,
  }) async {
    final image =
        await tryDecodeImage(bytes).then((image) => image!.toEquatable());

    return BrowserIcon._(
      image: image,
      dominantColor: dominantColor,
      source: source,
    );
  }

  BrowserIcon._({
    required this.image,
    required this.dominantColor,
    required this.source,
  });

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        image,
        dominantColor,
        source,
      ];
}
