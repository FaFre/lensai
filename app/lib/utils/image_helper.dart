import 'dart:typed_data';
import 'dart:ui';

Future<bool> isImageValid(Uint8List bytes) async {
  try {
    final codec = await instantiateImageCodec(bytes, targetWidth: 32);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image.width > 0;
  } catch (e) {
    return false;
  }
}
