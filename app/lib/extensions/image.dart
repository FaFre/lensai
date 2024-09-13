import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:lensai/domain/entities/equatable_image.dart';

extension ImageHash on Image {
  Future<String?> calculateHash() async {
    final bytes = await toByteData();
    if (bytes != null) {
      final digest = sha1.convert(bytes.buffer.asUint8List());
      return digest.toString();
    }

    return null;
  }

  Future<EquatableImage> toEquatable() {
    return EquatableImage.calculate(this);
  }
}
