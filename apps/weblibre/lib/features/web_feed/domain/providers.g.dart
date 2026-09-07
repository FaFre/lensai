// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArticleSearch)
final articleSearchProvider = ArticleSearchFamily._();

final class ArticleSearchProvider
    extends $StreamNotifierProvider<ArticleSearch, List<FeedArticleSummary>> {
  ArticleSearchProvider._({
    required ArticleSearchFamily super.from,
    required Uri? super.argument,
  }) : super(
         retry: null,
         name: r'articleSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$articleSearchHash();

  @override
  String toString() {
    return r'articleSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ArticleSearch create() => ArticleSearch();

  @override
  bool operator ==(Object other) {
    return other is ArticleSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$articleSearchHash() => r'341fba801fe7ea7d01cb637329d27b9ff11d66f0';

final class ArticleSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          ArticleSearch,
          AsyncValue<List<FeedArticleSummary>>,
          List<FeedArticleSummary>,
          Stream<List<FeedArticleSummary>>,
          Uri?
        > {
  ArticleSearchFamily._()
    : super(
        retry: null,
        name: r'articleSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArticleSearchProvider call(Uri? feedId) =>
      ArticleSearchProvider._(argument: feedId, from: this);

  @override
  String toString() => r'articleSearchProvider';
}

abstract class _$ArticleSearch
    extends $StreamNotifier<List<FeedArticleSummary>> {
  late final _$args = ref.$arg as Uri?;
  Uri? get feedId => _$args;

  Stream<List<FeedArticleSummary>> build(Uri? feedId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<FeedArticleSummary>>,
              List<FeedArticleSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<FeedArticleSummary>>,
                List<FeedArticleSummary>
              >,
              AsyncValue<List<FeedArticleSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(feedList)
final feedListProvider = FeedListProvider._();

final class FeedListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedData>>,
          List<FeedData>,
          Stream<List<FeedData>>
        >
    with $FutureModifier<List<FeedData>>, $StreamProvider<List<FeedData>> {
  FeedListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedListHash();

  @$internal
  @override
  $StreamProviderElement<List<FeedData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedData>> create(Ref ref) {
    return feedList(ref);
  }
}

String _$feedListHash() => r'0076186437354768c39fb1d7c8bcfcf7b94c7dd1';

@ProviderFor(feedData)
final feedDataProvider = FeedDataFamily._();

final class FeedDataProvider
    extends
        $FunctionalProvider<AsyncValue<FeedData?>, FeedData?, Stream<FeedData?>>
    with $FutureModifier<FeedData?>, $StreamProvider<FeedData?> {
  FeedDataProvider._({
    required FeedDataFamily super.from,
    required Uri? super.argument,
  }) : super(
         retry: null,
         name: r'feedDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedDataHash();

  @override
  String toString() {
    return r'feedDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<FeedData?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<FeedData?> create(Ref ref) {
    final argument = this.argument as Uri?;
    return feedData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedDataHash() => r'0599a2e3d159ef3abb6c3d2c871f87da2f5e646b';

final class FeedDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<FeedData?>, Uri?> {
  FeedDataFamily._()
    : super(
        retry: null,
        name: r'feedDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedDataProvider call(Uri? feedId) =>
      FeedDataProvider._(argument: feedId, from: this);

  @override
  String toString() => r'feedDataProvider';
}

@ProviderFor(feedArticleList)
final feedArticleListProvider = FeedArticleListFamily._();

final class FeedArticleListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedArticleListEntry>>,
          List<FeedArticleListEntry>,
          Stream<List<FeedArticleListEntry>>
        >
    with
        $FutureModifier<List<FeedArticleListEntry>>,
        $StreamProvider<List<FeedArticleListEntry>> {
  FeedArticleListProvider._({
    required FeedArticleListFamily super.from,
    required Uri? super.argument,
  }) : super(
         retry: null,
         name: r'feedArticleListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedArticleListHash();

  @override
  String toString() {
    return r'feedArticleListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FeedArticleListEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedArticleListEntry>> create(Ref ref) {
    final argument = this.argument as Uri?;
    return feedArticleList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedArticleListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedArticleListHash() => r'8161be00fd61b16b9b9ff7900fafcfb0d36c5657';

final class FeedArticleListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FeedArticleListEntry>>, Uri?> {
  FeedArticleListFamily._()
    : super(
        retry: null,
        name: r'feedArticleListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedArticleListProvider call(Uri? feedId) =>
      FeedArticleListProvider._(argument: feedId, from: this);

  @override
  String toString() => r'feedArticleListProvider';
}

@ProviderFor(FilteredArticleList)
final filteredArticleListProvider = FilteredArticleListFamily._();

final class FilteredArticleListProvider
    extends
        $NotifierProvider<
          FilteredArticleList,
          AsyncValue<List<FeedArticleSummary>>
        > {
  FilteredArticleListProvider._({
    required FilteredArticleListFamily super.from,
    required Uri? super.argument,
  }) : super(
         retry: null,
         name: r'filteredArticleListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredArticleListHash();

  @override
  String toString() {
    return r'filteredArticleListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FilteredArticleList create() => FilteredArticleList();

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
    return other is FilteredArticleListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredArticleListHash() =>
    r'54f0ca33749da334e025adda09547dc72f0c4e98';

final class FilteredArticleListFamily extends $Family
    with
        $ClassFamilyOverride<
          FilteredArticleList,
          AsyncValue<List<FeedArticleSummary>>,
          AsyncValue<List<FeedArticleSummary>>,
          AsyncValue<List<FeedArticleSummary>>,
          Uri?
        > {
  FilteredArticleListFamily._()
    : super(
        retry: null,
        name: r'filteredArticleListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredArticleListProvider call(Uri? feedId) =>
      FilteredArticleListProvider._(argument: feedId, from: this);

  @override
  String toString() => r'filteredArticleListProvider';
}

abstract class _$FilteredArticleList
    extends $Notifier<AsyncValue<List<FeedArticleSummary>>> {
  late final _$args = ref.$arg as Uri?;
  Uri? get feedId => _$args;

  AsyncValue<List<FeedArticleSummary>> build(Uri? feedId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<FeedArticleSummary>>,
              AsyncValue<List<FeedArticleSummary>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<FeedArticleSummary>>,
                AsyncValue<List<FeedArticleSummary>>
              >,
              AsyncValue<List<FeedArticleSummary>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(feedArticle)
final feedArticleProvider = FeedArticleFamily._();

final class FeedArticleProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedArticle?>,
          FeedArticle?,
          Stream<FeedArticle?>
        >
    with $FutureModifier<FeedArticle?>, $StreamProvider<FeedArticle?> {
  FeedArticleProvider._({
    required FeedArticleFamily super.from,
    required (String, {bool updateReadDate}) super.argument,
  }) : super(
         retry: null,
         name: r'feedArticleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedArticleHash();

  @override
  String toString() {
    return r'feedArticleProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<FeedArticle?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<FeedArticle?> create(Ref ref) {
    final argument = this.argument as (String, {bool updateReadDate});
    return feedArticle(
      ref,
      argument.$1,
      updateReadDate: argument.updateReadDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeedArticleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedArticleHash() => r'18b5faf391867b95f4b3bc4f74a6083854b633a5';

final class FeedArticleFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<FeedArticle?>,
          (String, {bool updateReadDate})
        > {
  FeedArticleFamily._()
    : super(
        retry: null,
        name: r'feedArticleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedArticleProvider call(String articleId, {required bool updateReadDate}) =>
      FeedArticleProvider._(
        argument: (articleId, updateReadDate: updateReadDate),
        from: this,
      );

  @override
  String toString() => r'feedArticleProvider';
}

@ProviderFor(unreadArticleCount)
final unreadArticleCountProvider = UnreadArticleCountProvider._();

final class UnreadArticleCountProvider
    extends
        $FunctionalProvider<
          Raw<Stream<Map<String, int>>>,
          Raw<Stream<Map<String, int>>>,
          Raw<Stream<Map<String, int>>>
        >
    with $Provider<Raw<Stream<Map<String, int>>>> {
  UnreadArticleCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadArticleCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadArticleCountHash();

  @$internal
  @override
  $ProviderElement<Raw<Stream<Map<String, int>>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<Map<String, int>>> create(Ref ref) {
    return unreadArticleCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<Map<String, int>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<Map<String, int>>>>(
        value,
      ),
    );
  }
}

String _$unreadArticleCountHash() =>
    r'709518ad229636df0f1095f47e3a6d116b3aa7e6';

@ProviderFor(unreadFeedArticleCount)
final unreadFeedArticleCountProvider = UnreadFeedArticleCountFamily._();

final class UnreadFeedArticleCountProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, Stream<int?>>
    with $FutureModifier<int?>, $StreamProvider<int?> {
  UnreadFeedArticleCountProvider._({
    required UnreadFeedArticleCountFamily super.from,
    required Uri super.argument,
  }) : super(
         retry: null,
         name: r'unreadFeedArticleCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unreadFeedArticleCountHash();

  @override
  String toString() {
    return r'unreadFeedArticleCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int?> create(Ref ref) {
    final argument = this.argument as Uri;
    return unreadFeedArticleCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadFeedArticleCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadFeedArticleCountHash() =>
    r'5e0d8e58b3d1dec978dc07b22367f2cb037b1b15';

final class UnreadFeedArticleCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int?>, Uri> {
  UnreadFeedArticleCountFamily._()
    : super(
        retry: null,
        name: r'unreadFeedArticleCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UnreadFeedArticleCountProvider call(Uri feedId) =>
      UnreadFeedArticleCountProvider._(argument: feedId, from: this);

  @override
  String toString() => r'unreadFeedArticleCountProvider';
}

@ProviderFor(fetchWebFeed)
final fetchWebFeedProvider = FetchWebFeedFamily._();

final class FetchWebFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedParseResult>,
          FeedParseResult,
          FutureOr<FeedParseResult>
        >
    with $FutureModifier<FeedParseResult>, $FutureProvider<FeedParseResult> {
  FetchWebFeedProvider._({
    required FetchWebFeedFamily super.from,
    required Uri super.argument,
  }) : super(
         retry: null,
         name: r'fetchWebFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchWebFeedHash();

  @override
  String toString() {
    return r'fetchWebFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FeedParseResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FeedParseResult> create(Ref ref) {
    final argument = this.argument as Uri;
    return fetchWebFeed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchWebFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchWebFeedHash() => r'73bdf87ad7dbd039c7dc181d80acdf99d96fe1c6';

final class FetchWebFeedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FeedParseResult>, Uri> {
  FetchWebFeedFamily._()
    : super(
        retry: null,
        name: r'fetchWebFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchWebFeedProvider call(Uri url) =>
      FetchWebFeedProvider._(argument: url, from: this);

  @override
  String toString() => r'fetchWebFeedProvider';
}
