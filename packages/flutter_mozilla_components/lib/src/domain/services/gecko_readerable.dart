import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

class GeckoReaderableService extends ReaderViewController {
  final ReaderViewEvents _events;

  final _appearanceVisibility = StreamController<bool>.broadcast();
  final _readerVisibility = StreamController<bool>.broadcast();

  Stream<bool> get appearanceVisibility => _appearanceVisibility.stream;
  Stream<bool> get readerVisibility => _readerVisibility.stream;

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

  @override
  void readerViewButtonVisibility(bool visible) {
    _readerVisibility.add(visible);
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
