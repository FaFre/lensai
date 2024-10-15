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
  // Stream controllers
  final _fragmentStateSubject = BehaviorSubject.seeded(false);
  final _tabListSubject = BehaviorSubject<List<String>>();
  final _selectedTabSubject = BehaviorSubject<String?>();
  final _tabContentSubject = BehaviorSubject<TabContentState>();
  final _historySubject = BehaviorSubject<HistoryEvent>();
  final _readerableSubject = BehaviorSubject<ReaderableEvent>();
  final _securityInfoSubject = BehaviorSubject<SecurityInfoEvent>();
  final _iconSubject = BehaviorSubject<IconEvent>();
  final _thumbnailSubject = BehaviorSubject<ThumbnailEvent>();
  final _findResultsSubject = BehaviorSubject<FindResultsEvent>();

  // Event streams
  Stream<bool> get fragmentReadyStateEvents => _fragmentStateSubject.stream;
  Stream<List<String>> get tabListEvents => _tabListSubject.stream;
  Stream<String?> get selectedTabEvents => _selectedTabSubject.stream;
  Stream<TabContentState> get tabContentEvents => _tabContentSubject.stream;
  Stream<HistoryEvent> get historyEvents => _historySubject.stream;
  Stream<ReaderableEvent> get readerableEvents => _readerableSubject.stream;
  Stream<SecurityInfoEvent> get securityInfoEvents =>
      _securityInfoSubject.stream;
  Stream<IconEvent> get iconEvents => _iconSubject.stream;
  Stream<ThumbnailEvent> get thumbnailEvents => _thumbnailSubject.stream;
  Stream<FindResultsEvent> get findResultsEvent => _findResultsSubject.stream;

  @override
  void onFragmentReadyStateChange(bool state) {
    _fragmentStateSubject.add(state);
  }

  // Overridden methods
  @override
  void onTabListChange(List<String?> tabIds) {
    _tabListSubject.add(tabIds.nonNulls.toList());
  }

  @override
  void onSelectedTabChange(String? id) {
    _selectedTabSubject.add(id);
  }

  @override
  void onTabContentStateChange(TabContentState state) {
    _tabContentSubject.add(state);
  }

  @override
  void onHistoryStateChange(String id, HistoryState state) {
    _historySubject.add((tabId: id, history: state));
  }

  @override
  void onReaderableStateChange(String id, ReaderableState state) {
    _readerableSubject.add((tabId: id, readerable: state));
  }

  @override
  void onSecurityInfoStateChange(String id, SecurityInfoState state) {
    _securityInfoSubject.add((tabId: id, securityInfo: state));
  }

  @override
  void onIconChange(String id, Uint8List? bytes) {
    _iconSubject.add((tabId: id, bytes: bytes));
  }

  @override
  void onThumbnailChange(String id, Uint8List? bytes) {
    _thumbnailSubject.add((tabId: id, bytes: bytes));
  }

  @override
  void onFindResults(String id, List<FindResultState?> results) {
    _findResultsSubject.add((tabId: id, results: results.nonNulls.toList()));
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
  }
}
