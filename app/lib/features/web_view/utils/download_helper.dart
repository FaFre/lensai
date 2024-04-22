//https://stackoverflow.com/a/67994693/20878798

import 'package:universal_io/io.dart';

final _utf8FilenameRegex = RegExp(
  r"filename\*=UTF-8''([\w%\-\.]+)(?:; ?|$)",
  caseSensitive: false,
);

final _asciiFilenameRegex = RegExp(
  r"""^filename=(["']?)(.*?[^\\])\1(?:; ?|$)""",
  caseSensitive: false,
);

String? getDispositionFileName(String contentDisposition) {
  if (_utf8FilenameRegex.hasMatch(contentDisposition)) {
    final file = Uri.decodeComponent(
      _utf8FilenameRegex.firstMatch(contentDisposition)!.group(1)!,
    );

    return File(file).uri.pathSegments.last;
  } else {
    // Prevent ReDos attacks by anchoring the ascii regex to string start and
    // slicing off everything before 'filename='
    final filenameStart = contentDisposition.toLowerCase().indexOf('filename=');
    if (filenameStart >= 0) {
      final partialDisposition = contentDisposition.substring(filenameStart);
      final matches = _asciiFilenameRegex.firstMatch(partialDisposition);
      if (matches != null && matches.group(2) != null) {
        final file = matches.group(2);
        if (file != null) {
          return File(file).uri.pathSegments.last;
        }
      }
    }
  }

  return null;
}
