import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

class GeckoReaderableService extends ReaderViewController {
  final ReaderViewEvents _events;

  final _appearanceVisibility = BehaviorSubject<bool>();
  final _readerVisibility = BehaviorSubject<bool>();

  Stream<bool> get appearanceVisibility => _appearanceVisibility.stream;

  Future<void> toggleReaderView(bool enable) {
    return _events.onToggleReaderView(enable);
  }

  Future<void> onAppearanceButtonTap() {
    return _events.onAppearanceButtonTap();
  }

  @override
  void appearanceButtonVisibility(bool visible) {
    _appearanceVisibility.add(visible);
  }

  GeckoReaderableService.setUp({
    ReaderViewEvents? readerEvents,
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) : _events = readerEvents ??
            ReaderViewEvents(
              binaryMessenger: binaryMessenger,
              messageChannelSuffix: messageChannelSuffix,
            ) {
    ReaderViewController.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  void dispose() {
    unawaited(_appearanceVisibility.close());
    unawaited(_readerVisibility.close());
  }
}
