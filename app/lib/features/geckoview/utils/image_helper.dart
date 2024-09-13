import 'dart:typed_data';
import 'dart:ui';

Future<Image?> tryDecodeImage(
  Uint8List bytes, {
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling = true,
}) async {
  try {
    final codec = await instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      allowUpscaling: allowUpscaling,
    );

    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;

    if (image.width > 0) {
      return image;
    }
  } catch (e) {
    //swallow
  }

  return null;
}
