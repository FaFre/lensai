import 'package:fast_equatable/fast_equatable.dart';

class HistoryItem with FastEquatable {
  final Uri url;
  final String title;

  HistoryItem({required this.url, required this.title});

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [url, title];
}

class HistoryState with FastEquatable {
  final List<HistoryItem> items;
  final int currentIndex;

  final bool canGoBack;
  final bool canGoForward;

  HistoryState({
    required this.items,
    required this.currentIndex,
    required this.canGoBack,
    required this.canGoForward,
  });

  factory HistoryState.$default() => HistoryState(
        items: const [],
        currentIndex: 0,
        canGoBack: false,
        canGoForward: false,
      );

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters =>
      [items, currentIndex, canGoBack, canGoForward];
}
