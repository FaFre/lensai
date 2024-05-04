import 'dart:async';

import 'package:bang_navigator/domain/entities/received_parameter.dart';
import 'package:collection/collection.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'sharing_intent.g.dart';

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
  )
      .map(
        (event) => event
            .where(
              (shared) =>
                  shared.type == SharedMediaType.TEXT ||
                  shared.type == SharedMediaType.URL,
            )
            .map((shared) => shared.value)
            .whereNotNull()
            .firstOrNull,
      )
      .whereNotNull()
      .map((content) => ReceivedParameter(content, null));
}
