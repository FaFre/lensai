import 'dart:ui';

import 'package:lensai/extensions/image.dart';

class EquatableImage {
  final Image value;
  final String? _imageHash;

  EquatableImage(
    this.value, {
    required String? hash,
  }) : _imageHash = hash;

  static Future<EquatableImage> calculate(Image image) async {
    final imageHash = await image.calculateHash();

    return EquatableImage(image, hash: imageHash);
  }

  @override
  int get hashCode => _imageHash.hashCode;

  @override
  bool operator ==(Object other) {
    return other is EquatableImage && other._imageHash == _imageHash;
  }
}
