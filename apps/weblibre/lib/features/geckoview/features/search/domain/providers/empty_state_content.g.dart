// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empty_state_content.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchEmptyHistoryHighlights)
final searchEmptyHistoryHighlightsProvider =
    SearchEmptyHistoryHighlightsFamily._();

final class SearchEmptyHistoryHighlightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryHighlight>>,
          List<HistoryHighlight>,
          FutureOr<List<HistoryHighlight>>
        >
    with
        $FutureModifier<List<HistoryHighlight>>,
        $FutureProvider<List<HistoryHighlight>> {
  SearchEmptyHistoryHighlightsProvider._({
    required SearchEmptyHistoryHighlightsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyHistoryHighlightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyHistoryHighlightsHash();

  @override
  String toString() {
    return r'searchEmptyHistoryHighlightsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HistoryHighlight>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryHighlight>> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyHistoryHighlights(ref, count: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyHistoryHighlightsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyHistoryHighlightsHash() =>
    r'f12206cb05c5c03ecdc2b84e3ffd20706aa4c986';

final class SearchEmptyHistoryHighlightsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HistoryHighlight>>, int> {
  SearchEmptyHistoryHighlightsFamily._()
    : super(
        retry: null,
        name: r'searchEmptyHistoryHighlightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyHistoryHighlightsProvider call({int count = 25}) =>
      SearchEmptyHistoryHighlightsProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyHistoryHighlightsProvider';
}

@ProviderFor(searchEmptyRecentHistory)
final searchEmptyRecentHistoryProvider = SearchEmptyRecentHistoryFamily._();

final class SearchEmptyRecentHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitInfo>>,
          List<VisitInfo>,
          FutureOr<List<VisitInfo>>
        >
    with $FutureModifier<List<VisitInfo>>, $FutureProvider<List<VisitInfo>> {
  SearchEmptyRecentHistoryProvider._({
    required SearchEmptyRecentHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyRecentHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyRecentHistoryHash();

  @override
  String toString() {
    return r'searchEmptyRecentHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VisitInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VisitInfo>> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyRecentHistory(ref, count: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyRecentHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyRecentHistoryHash() =>
    r'bd7b9a67edfb1751d6d5cf6a8392516911796cb0';

final class SearchEmptyRecentHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VisitInfo>>, int> {
  SearchEmptyRecentHistoryFamily._()
    : super(
        retry: null,
        name: r'searchEmptyRecentHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyRecentHistoryProvider call({int count = 25}) =>
      SearchEmptyRecentHistoryProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyRecentHistoryProvider';
}

@ProviderFor(searchEmptyRecentFeedArticles)
final searchEmptyRecentFeedArticlesProvider =
    SearchEmptyRecentFeedArticlesFamily._();

final class SearchEmptyRecentFeedArticlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedArticleSummary>>,
          AsyncValue<List<FeedArticleSummary>>,
          AsyncValue<List<FeedArticleSummary>>
        >
    with $Provider<AsyncValue<List<FeedArticleSummary>>> {
  SearchEmptyRecentFeedArticlesProvider._({
    required SearchEmptyRecentFeedArticlesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyRecentFeedArticlesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyRecentFeedArticlesHash();

  @override
  String toString() {
    return r'searchEmptyRecentFeedArticlesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<FeedArticleSummary>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<FeedArticleSummary>> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyRecentFeedArticles(ref, count: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<FeedArticleSummary>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<FeedArticleSummary>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyRecentFeedArticlesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyRecentFeedArticlesHash() =>
    r'd9ddafc69ce226342bc63126dd6e1fd9d82d2d9a';

final class SearchEmptyRecentFeedArticlesFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<FeedArticleSummary>>, int> {
  SearchEmptyRecentFeedArticlesFamily._()
    : super(
        retry: null,
        name: r'searchEmptyRecentFeedArticlesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyRecentFeedArticlesProvider call({int count = 25}) =>
      SearchEmptyRecentFeedArticlesProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyRecentFeedArticlesProvider';
}

@ProviderFor(searchEmptyRecentTabs)
final searchEmptyRecentTabsProvider = SearchEmptyRecentTabsFamily._();

final class SearchEmptyRecentTabsProvider
    extends
        $FunctionalProvider<
          List<TabStateWithContainer>,
          List<TabStateWithContainer>,
          List<TabStateWithContainer>
        >
    with $Provider<List<TabStateWithContainer>> {
  SearchEmptyRecentTabsProvider._({
    required SearchEmptyRecentTabsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyRecentTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyRecentTabsHash();

  @override
  String toString() {
    return r'searchEmptyRecentTabsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TabStateWithContainer>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TabStateWithContainer> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyRecentTabs(ref, count: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TabStateWithContainer> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TabStateWithContainer>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyRecentTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyRecentTabsHash() =>
    r'6000970dd261f243326900555967956508b84660';

final class SearchEmptyRecentTabsFamily extends $Family
    with $FunctionalFamilyOverride<List<TabStateWithContainer>, int> {
  SearchEmptyRecentTabsFamily._()
    : super(
        retry: null,
        name: r'searchEmptyRecentTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyRecentTabsProvider call({int count = 25}) =>
      SearchEmptyRecentTabsProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyRecentTabsProvider';
}
