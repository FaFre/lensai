import 'dart:async';

import 'package:bang_navigator/core/logger.dart';
import 'package:bang_navigator/domain/entities/received_parameter.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:collection/collection.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:mime/mime.dart' as mime;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;

part 'sharing_intent.g.dart';

final _sharingIntentTransformer =
    StreamTransformer<List<SharedFile>, ReceivedParameter>.fromHandlers(
  handleData: (files, sink) async {
    //For now only one file is supported to share with the app
    final data = files.firstOrNull;

    if (data != null && data.value != null) {
      switch (data.type) {
        case SharedMediaType.TEXT:
        case SharedMediaType.URL:
          if (uri_to_file.isUriSupported(data.value!)) {
            final file = await uri_to_file.toFile(data.value!);
            final mimeType = mime.lookupMimeType(file.path);
            switch (mimeType) {
              case 'application/pdf':
                final content =
                    await PDFDoc.fromFile(file).then((doc) => doc.text);
                sink.add(
                  ReceivedParameter(content, KagiTool.summarizer.name),
                );
              default:
                logger.w('Unhandled mime type: $mimeType');
            }
          } else {
            sink.add(ReceivedParameter(data.value, null));
          }
        default:
          logger.w('Unhandled media type: $data');
      }
    }
  },
);

@riverpod
Raw<Stream<ReceivedParameter>> sharingIntentStream(SharingIntentStreamRef ref) {
  final initialStream = FlutterSharingIntent.instance
      // ignore: discarded_futures
      .getInitialSharing()
      // ignore: discarded_futures
      .then((event) async {
    FlutterSharingIntent.instance.reset();
    return event;
  }).asStream();

  return ConcatStream(
    [initialStream, FlutterSharingIntent.instance.getMediaStream()],
  ).transform(_sharingIntentTransformer);
}
