import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

// Typedefs for record types
typedef HistoryEvent = ({String tabId, HistoryState history});
typedef ReaderableEvent = ({String tabId, ReaderableState readerable});
typedef SecurityInfoEvent = ({String tabId, SecurityInfoState securityInfo});
typedef IconEvent = ({String tabId, Uint8List? bytes});
typedef ThumbnailEvent = ({String tabId, Uint8List? bytes});
typedef FindResultsEvent = ({String tabId, List<FindResultState> results});

class GeckoEventService extends GeckoStateEvents {
  final _lastEventTimes = <Subject, Map<dynamic, int>>{};

  // Stream controllers
  final _viewStateSubject = BehaviorSubject.seeded(false);
  final _engineStateSubject = BehaviorSubject.seeded(false);
  final _tabListSubject = BehaviorSubject<List<String>>();
  final _selectedTabSubject = BehaviorSubject<String?>();

  final _tabContentSubject = ReplaySubject<TabContentState>();
  final _historySubject = ReplaySubject<HistoryEvent>();
  final _securityInfoSubject = ReplaySubject<SecurityInfoEvent>();
  final _readerableSubject = ReplaySubject<ReaderableEvent>();

  final _iconSubject = PublishSubject<IconEvent>();
  final _thumbnailSubject = PublishSubject<ThumbnailEvent>();
  final _findResultsSubject = PublishSubject<FindResultsEvent>();

  final _tabAddedSubject = PublishSubject<String>();

  // Event streams
  ValueStream<bool> get viewReadyStateEvents => _viewStateSubject.stream;
  ValueStream<bool> get engineReadyStateEvents => _engineStateSubject.stream;
  ValueStream<List<String>> get tabListEvents => _tabListSubject.stream;
  ValueStream<String?> get selectedTabEvents => _selectedTabSubject.stream;

  Stream<TabContentState> get tabContentEvents => _tabContentSubject.stream;
  Stream<HistoryEvent> get historyEvents => _historySubject.stream;
  Stream<ReaderableEvent> get readerableEvents => _readerableSubject.stream;
  Stream<SecurityInfoEvent> get securityInfoEvents =>
      _securityInfoSubject.stream;
  Stream<IconEvent> get iconEvents => _iconSubject.stream;
  Stream<ThumbnailEvent> get thumbnailEvents => _thumbnailSubject.stream;
  Stream<FindResultsEvent> get findResultsEvent => _findResultsSubject.stream;

  Stream<String> get tabAddedStream => _tabAddedSubject.stream;

  void _addWhenMoreRecent<T>(
    Subject<T> subject,
    int timestamp,
    dynamic identifier,
    T value,
  ) {
    _lastEventTimes[subject] ??= {};

    if ((_lastEventTimes[subject]?[identifier] ?? 0) < timestamp) {
      _lastEventTimes[subject]![identifier] = timestamp;
      subject.add(value);
    }
  }

  @override
  void onViewReadyStateChange(int timestamp, bool state) {
    _addWhenMoreRecent(_viewStateSubject, timestamp, null, state);
  }

  @override
  void onEngineReadyStateChange(int timestamp, bool state) {
    _addWhenMoreRecent(_engineStateSubject, timestamp, null, state);
  }

  // Overridden methods
  @override
  void onTabListChange(int timestamp, List<String?> tabIds) {
    _addWhenMoreRecent(
      _tabListSubject,
      timestamp,
      null,
      tabIds.nonNulls.toList(),
    );
  }

  @override
  void onSelectedTabChange(int timestamp, String? id) {
    _addWhenMoreRecent(_selectedTabSubject, timestamp, id, id);
  }

  @override
  void onTabContentStateChange(int timestamp, TabContentState state) {
    _addWhenMoreRecent(_tabContentSubject, timestamp, state.id, state);
  }

  @override
  void onHistoryStateChange(int timestamp, String id, HistoryState state) {
    _addWhenMoreRecent(
      _historySubject,
      timestamp,
      id,
      (tabId: id, history: state),
    );
  }

  @override
  void onReaderableStateChange(
    int timestamp,
    String id,
    ReaderableState state,
  ) {
    _addWhenMoreRecent(
      _readerableSubject,
      timestamp,
      id,
      (tabId: id, readerable: state),
    );
  }

  @override
  void onSecurityInfoStateChange(
    int timestamp,
    String id,
    SecurityInfoState state,
  ) {
    _addWhenMoreRecent(
      _securityInfoSubject,
      timestamp,
      id,
      (tabId: id, securityInfo: state),
    );
  }

  @override
  void onIconChange(int timestamp, String id, Uint8List? bytes) {
    _addWhenMoreRecent(_iconSubject, timestamp, id, (tabId: id, bytes: bytes));
  }

  @override
  void onThumbnailChange(int timestamp, String id, Uint8List? bytes) {
    _addWhenMoreRecent(
      _thumbnailSubject,
      timestamp,
      id,
      (tabId: id, bytes: bytes),
    );
  }

  @override
  void onFindResults(int timestamp, String id, List<FindResultState?> results) {
    _addWhenMoreRecent(
      _findResultsSubject,
      timestamp,
      id,
      (tabId: id, results: results.nonNulls.toList()),
    );
  }

  @override
  void onTabAdded(int timestamp, String tabId) {
    _addWhenMoreRecent(
      _tabAddedSubject,
      timestamp,
      null,
      tabId,
    );
  }

  GeckoEventService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoStateEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  void dispose() {
    unawaited(_tabListSubject.close());
    unawaited(_selectedTabSubject.close());
    unawaited(_tabContentSubject.close());
    unawaited(_historySubject.close());
    unawaited(_readerableSubject.close());
    unawaited(_securityInfoSubject.close());
    unawaited(_iconSubject.close());
    unawaited(_thumbnailSubject.close());
    unawaited(_findResultsSubject.close());
    unawaited(_tabAddedSubject.close());
  }
}
