import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

// Typedefs for record types
typedef HistoryEvent = ({String tabId, HistoryState history});
typedef ReaderableEvent = ({String tabId, ReaderableState readerable});
typedef SecurityInfoEvent = ({String tabId, SecurityInfoState securityInfo});
typedef IconEvent = ({String tabId, Uint8List? bytes});
typedef ThumbnailEvent = ({String tabId, Uint8List? bytes});

class GeckoEventService extends GeckoStateEvents {
  // Stream controllers
  final _tabListController = StreamController<List<String>>.broadcast();
  final _selectedTabController = StreamController<String?>.broadcast();
  final _tabContentController = StreamController<TabContentState>.broadcast();
  final _historyController = StreamController<HistoryEvent>.broadcast();
  final _readerableController = StreamController<ReaderableEvent>.broadcast();
  final _securityInfoController =
      StreamController<SecurityInfoEvent>.broadcast();
  final _iconController = StreamController<IconEvent>.broadcast();
  final _thumbnailController = StreamController<ThumbnailEvent>.broadcast();

  // Event streams
  Stream<List<String>> get tabListEvents => _tabListController.stream;
  Stream<String?> get selectedTabEvents => _selectedTabController.stream;
  Stream<TabContentState> get tabContentEvents => _tabContentController.stream;
  Stream<HistoryEvent> get historyEvents => _historyController.stream;
  Stream<ReaderableEvent> get readerableEvents => _readerableController.stream;
  Stream<SecurityInfoEvent> get securityInfoEvents =>
      _securityInfoController.stream;
  Stream<IconEvent> get iconEvents => _iconController.stream;
  Stream<ThumbnailEvent> get thumbnailEvents => _thumbnailController.stream;

  // Overridden methods
  @override
  void onTabListChange(List<String?> tabIds) {
    _tabListController.add(tabIds.nonNulls.toList());
  }

  @override
  void onSelectedTabChange(String? id) {
    _selectedTabController.add(id);
  }

  @override
  void onTabContentStateChange(TabContentState state) {
    _tabContentController.add(state);
  }

  @override
  void onHistoryStateChange(String id, HistoryState state) {
    _historyController.add((tabId: id, history: state));
  }

  @override
  void onReaderableStateChange(String id, ReaderableState state) {
    _readerableController.add((tabId: id, readerable: state));
  }

  @override
  void onSecurityInfoStateChange(String id, SecurityInfoState state) {
    _securityInfoController.add((tabId: id, securityInfo: state));
  }

  @override
  void onIconChange(String id, Uint8List? bytes) {
    _iconController.add((tabId: id, bytes: bytes));
  }

  @override
  void onThumbnailChange(String id, Uint8List? bytes) {
    _thumbnailController.add((tabId: id, bytes: bytes));
  }

  GeckoEventService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoStateEvents.setUp(this);
  }

  void dispose() {
    _tabListController.close();
    _selectedTabController.close();
    _tabContentController.close();
    _historyController.close();
    _readerableController.close();
    _securityInfoController.close();
    _iconController.close();
    _thumbnailController.close();
  }
}
