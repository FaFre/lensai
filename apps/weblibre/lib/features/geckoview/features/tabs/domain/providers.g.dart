// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watchContainersWithCount)
final watchContainersWithCountProvider = WatchContainersWithCountProvider._();

final class WatchContainersWithCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContainerDataWithCount>>,
          List<ContainerDataWithCount>,
          Stream<List<ContainerDataWithCount>>
        >
    with
        $FutureModifier<List<ContainerDataWithCount>>,
        $StreamProvider<List<ContainerDataWithCount>> {
  WatchContainersWithCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchContainersWithCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchContainersWithCountHash();

  @$internal
  @override
  $StreamProviderElement<List<ContainerDataWithCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ContainerDataWithCount>> create(Ref ref) {
    return watchContainersWithCount(ref);
  }
}

String _$watchContainersWithCountHash() =>
    r'50d8e9b39cb589b0b5f50d79cbe20b8d10d7a504';

/// The destinations a container-cycling gesture steps through, in the order
/// the container chips render them: the unassigned pseudo-container (`null`)
/// first, then the containers themselves.
///
/// Synced tabs and the group-suggestions chip are deliberately left out — they
/// are not containers, and landing on them mid-swipe would be a dead end.

@ProviderFor(containerCycleOrder)
final containerCycleOrderProvider = ContainerCycleOrderProvider._();

/// The destinations a container-cycling gesture steps through, in the order
/// the container chips render them: the unassigned pseudo-container (`null`)
/// first, then the containers themselves.
///
/// Synced tabs and the group-suggestions chip are deliberately left out — they
/// are not containers, and landing on them mid-swipe would be a dead end.

final class ContainerCycleOrderProvider
    extends
        $FunctionalProvider<
          List<ContainerData?>,
          List<ContainerData?>,
          List<ContainerData?>
        >
    with $Provider<List<ContainerData?>> {
  /// The destinations a container-cycling gesture steps through, in the order
  /// the container chips render them: the unassigned pseudo-container (`null`)
  /// first, then the containers themselves.
  ///
  /// Synced tabs and the group-suggestions chip are deliberately left out — they
  /// are not containers, and landing on them mid-swipe would be a dead end.
  ContainerCycleOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerCycleOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerCycleOrderHash();

  @$internal
  @override
  $ProviderElement<List<ContainerData?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ContainerData?> create(Ref ref) {
    return containerCycleOrder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ContainerData?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ContainerData?>>(value),
    );
  }
}

String _$containerCycleOrderHash() =>
    r'dd732a8717b1ebe7055776d2b7800e587f552438';

@ProviderFor(matchSortedContainersWithCount)
final matchSortedContainersWithCountProvider =
    MatchSortedContainersWithCountFamily._();

final class MatchSortedContainersWithCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContainerDataWithCount>>,
          AsyncValue<List<ContainerDataWithCount>>,
          AsyncValue<List<ContainerDataWithCount>>
        >
    with $Provider<AsyncValue<List<ContainerDataWithCount>>> {
  MatchSortedContainersWithCountProvider._({
    required MatchSortedContainersWithCountFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'matchSortedContainersWithCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matchSortedContainersWithCountHash();

  @override
  String toString() {
    return r'matchSortedContainersWithCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ContainerDataWithCount>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ContainerDataWithCount>> create(Ref ref) {
    final argument = this.argument as String?;
    return matchSortedContainersWithCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ContainerDataWithCount>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<ContainerDataWithCount>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MatchSortedContainersWithCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matchSortedContainersWithCountHash() =>
    r'e66ca1d96a735155f582975ae05a90503e615882';

final class MatchSortedContainersWithCountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<ContainerDataWithCount>>,
          String?
        > {
  MatchSortedContainersWithCountFamily._()
    : super(
        retry: null,
        name: r'matchSortedContainersWithCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatchSortedContainersWithCountProvider call(String? searchText) =>
      MatchSortedContainersWithCountProvider._(
        argument: searchText,
        from: this,
      );

  @override
  String toString() => r'matchSortedContainersWithCountProvider';
}

@ProviderFor(watchContainerTabIds)
final watchContainerTabIdsProvider = WatchContainerTabIdsFamily._();

final class WatchContainerTabIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  WatchContainerTabIdsProvider._({
    required WatchContainerTabIdsFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerTabIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerTabIdsHash();

  @override
  String toString() {
    return r'watchContainerTabIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return watchContainerTabIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerTabIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerTabIdsHash() =>
    r'25f73fe16fad7ec0121b2bee99ecbd8b6bf47791';

final class WatchContainerTabIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, ContainerFilter> {
  WatchContainerTabIdsFamily._()
    : super(
        retry: null,
        name: r'watchContainerTabIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerTabIdsProvider call(ContainerFilter containerFilter) =>
      WatchContainerTabIdsProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'watchContainerTabIdsProvider';
}

@ProviderFor(watchTabsFifo)
final watchTabsFifoProvider = WatchTabsFifoProvider._();

final class WatchTabsFifoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabSummary>>,
          List<TabSummary>,
          Stream<List<TabSummary>>
        >
    with $FutureModifier<List<TabSummary>>, $StreamProvider<List<TabSummary>> {
  WatchTabsFifoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTabsFifoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTabsFifoHash();

  @$internal
  @override
  $StreamProviderElement<List<TabSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabSummary>> create(Ref ref) {
    return watchTabsFifo(ref);
  }
}

String _$watchTabsFifoHash() => r'ce84a120f37fe08a1cc193c561e64acd44c949cd';

@ProviderFor(containerTabCount)
final containerTabCountProvider = ContainerTabCountFamily._();

final class ContainerTabCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  ContainerTabCountProvider._({
    required ContainerTabCountFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'containerTabCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTabCountHash();

  @override
  String toString() {
    return r'containerTabCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return containerTabCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTabCountHash() => r'df4008a9c589936c8a0699b082ab23087ae9b85f';

final class ContainerTabCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, ContainerFilter> {
  ContainerTabCountFamily._()
    : super(
        retry: null,
        name: r'containerTabCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTabCountProvider call(ContainerFilter containerFilter) =>
      ContainerTabCountProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'containerTabCountProvider';
}

@ProviderFor(watchTabTrees)
final watchTabTreesProvider = WatchTabTreesFamily._();

final class WatchTabTreesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabTreesResult>>,
          List<TabTreesResult>,
          Stream<List<TabTreesResult>>
        >
    with
        $FutureModifier<List<TabTreesResult>>,
        $StreamProvider<List<TabTreesResult>> {
  WatchTabTreesProvider._({
    required WatchTabTreesFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'watchTabTreesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabTreesHash();

  @override
  String toString() {
    return r'watchTabTreesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TabTreesResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabTreesResult>> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return watchTabTrees(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabTreesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabTreesHash() => r'7565b7c2d8e8128a0a49241200d64f2cf5ece0ca';

final class WatchTabTreesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TabTreesResult>>,
          ContainerFilter
        > {
  WatchTabTreesFamily._()
    : super(
        retry: null,
        name: r'watchTabTreesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabTreesProvider call(ContainerFilter containerFilter) =>
      WatchTabTreesProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'watchTabTreesProvider';
}

@ProviderFor(watchTabsWithRootAndDepth)
final watchTabsWithRootAndDepthProvider = WatchTabsWithRootAndDepthFamily._();

final class WatchTabsWithRootAndDepthProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabsWithRootAndDepthResult>>,
          List<TabsWithRootAndDepthResult>,
          Stream<List<TabsWithRootAndDepthResult>>
        >
    with
        $FutureModifier<List<TabsWithRootAndDepthResult>>,
        $StreamProvider<List<TabsWithRootAndDepthResult>> {
  WatchTabsWithRootAndDepthProvider._({
    required WatchTabsWithRootAndDepthFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'watchTabsWithRootAndDepthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabsWithRootAndDepthHash();

  @override
  String toString() {
    return r'watchTabsWithRootAndDepthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TabsWithRootAndDepthResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabsWithRootAndDepthResult>> create(Ref ref) {
    final argument = this.argument as String?;
    return watchTabsWithRootAndDepth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabsWithRootAndDepthProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabsWithRootAndDepthHash() =>
    r'dd485f4f60924e90f1f338237401dc95ca7e123f';

final class WatchTabsWithRootAndDepthFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TabsWithRootAndDepthResult>>,
          String?
        > {
  WatchTabsWithRootAndDepthFamily._()
    : super(
        retry: null,
        name: r'watchTabsWithRootAndDepthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabsWithRootAndDepthProvider call(String? containerId) =>
      WatchTabsWithRootAndDepthProvider._(argument: containerId, from: this);

  @override
  String toString() => r'watchTabsWithRootAndDepthProvider';
}

/// One tab's row, watched — without its page text.
///
/// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
/// for as long as the tab menu or the parent picker is open, and both consumers
/// read only `parentId` and `containerId`. The wide row would drag that tab's
/// stored content (and the `content_hash` UDF) through on every tick.

@ProviderFor(watchTabDbData)
final watchTabDbDataProvider = WatchTabDbDataFamily._();

/// One tab's row, watched — without its page text.
///
/// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
/// for as long as the tab menu or the parent picker is open, and both consumers
/// read only `parentId` and `containerId`. The wide row would drag that tab's
/// stored content (and the `content_hash` UDF) through on every tick.

final class WatchTabDbDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<TabSummary?>,
          TabSummary?,
          Stream<TabSummary?>
        >
    with $FutureModifier<TabSummary?>, $StreamProvider<TabSummary?> {
  /// One tab's row, watched — without its page text.
  ///
  /// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
  /// for as long as the tab menu or the parent picker is open, and both consumers
  /// read only `parentId` and `containerId`. The wide row would drag that tab's
  /// stored content (and the `content_hash` UDF) through on every tick.
  WatchTabDbDataProvider._({
    required WatchTabDbDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchTabDbDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabDbDataHash();

  @override
  String toString() {
    return r'watchTabDbDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TabSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TabSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return watchTabDbData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabDbDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabDbDataHash() => r'3e3c7221b4ef73616f995c362f823128e88984e2';

/// One tab's row, watched — without its page text.
///
/// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
/// for as long as the tab menu or the parent picker is open, and both consumers
/// read only `parentId` and `containerId`. The wide row would drag that tab's
/// stored content (and the `content_hash` UDF) through on every tick.

final class WatchTabDbDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TabSummary?>, String> {
  WatchTabDbDataFamily._()
    : super(
        retry: null,
        name: r'watchTabDbDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One tab's row, watched — without its page text.
  ///
  /// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
  /// for as long as the tab menu or the parent picker is open, and both consumers
  /// read only `parentId` and `containerId`. The wide row would drag that tab's
  /// stored content (and the `content_hash` UDF) through on every tick.

  WatchTabDbDataProvider call(String tabId) =>
      WatchTabDbDataProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchTabDbDataProvider';
}

@ProviderFor(watchTabDescendants)
final watchTabDescendantsProvider = WatchTabDescendantsFamily._();

final class WatchTabDescendantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String?>>,
          Map<String, String?>,
          Stream<Map<String, String?>>
        >
    with
        $FutureModifier<Map<String, String?>>,
        $StreamProvider<Map<String, String?>> {
  WatchTabDescendantsProvider._({
    required WatchTabDescendantsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchTabDescendantsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabDescendantsHash();

  @override
  String toString() {
    return r'watchTabDescendantsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String?>> create(Ref ref) {
    final argument = this.argument as String;
    return watchTabDescendants(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabDescendantsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabDescendantsHash() =>
    r'8b20353888a851191d835784e24d7d4a6e898b72';

final class WatchTabDescendantsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, String?>>, String> {
  WatchTabDescendantsFamily._()
    : super(
        retry: null,
        name: r'watchTabDescendantsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabDescendantsProvider call(String tabId) =>
      WatchTabDescendantsProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchTabDescendantsProvider';
}

@ProviderFor(watchContainerTabsData)
final watchContainerTabsDataProvider = WatchContainerTabsDataFamily._();

final class WatchContainerTabsDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabSummary>>,
          List<TabSummary>,
          Stream<List<TabSummary>>
        >
    with $FutureModifier<List<TabSummary>>, $StreamProvider<List<TabSummary>> {
  WatchContainerTabsDataProvider._({
    required WatchContainerTabsDataFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerTabsDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerTabsDataHash();

  @override
  String toString() {
    return r'watchContainerTabsDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TabSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabSummary>> create(Ref ref) {
    final argument = this.argument as String?;
    return watchContainerTabsData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerTabsDataProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerTabsDataHash() =>
    r'23f2867b1805333256176f42f9af37071593c3d2';

final class WatchContainerTabsDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TabSummary>>, String?> {
  WatchContainerTabsDataFamily._()
    : super(
        retry: null,
        name: r'watchContainerTabsDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerTabsDataProvider call(String? containerId) =>
      WatchContainerTabsDataProvider._(argument: containerId, from: this);

  @override
  String toString() => r'watchContainerTabsDataProvider';
}

@ProviderFor(watchPinnedTabIds)
final watchPinnedTabIdsProvider = WatchPinnedTabIdsProvider._();

final class WatchPinnedTabIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  WatchPinnedTabIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchPinnedTabIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchPinnedTabIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return watchPinnedTabIds(ref);
  }
}

String _$watchPinnedTabIdsHash() => r'5623faf1a4d90185c718654f4172092e28dd1e54';

@ProviderFor(watchTabTimestamps)
final watchTabTimestampsProvider = WatchTabTimestampsProvider._();

final class WatchTabTimestampsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, DateTime>>,
          Map<String, DateTime>,
          Stream<Map<String, DateTime>>
        >
    with
        $FutureModifier<Map<String, DateTime>>,
        $StreamProvider<Map<String, DateTime>> {
  WatchTabTimestampsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTabTimestampsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTabTimestampsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, DateTime>> create(Ref ref) {
    return watchTabTimestamps(ref);
  }
}

String _$watchTabTimestampsHash() =>
    r'8b3eea3dded71795f80c607117978bbec1de7cff';

@ProviderFor(watchTabOrderKeys)
final watchTabOrderKeysProvider = WatchTabOrderKeysProvider._();

final class WatchTabOrderKeysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          Stream<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $StreamProvider<Map<String, String>> {
  WatchTabOrderKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTabOrderKeysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTabOrderKeysHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String>> create(Ref ref) {
    return watchTabOrderKeys(ref);
  }
}

String _$watchTabOrderKeysHash() => r'675ef0d1b1c5445face8d6ab727507ca1a5e2c44';

@ProviderFor(watchContainerData)
final watchContainerDataProvider = WatchContainerDataFamily._();

final class WatchContainerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContainerData?>,
          ContainerData?,
          Stream<ContainerData?>
        >
    with $FutureModifier<ContainerData?>, $StreamProvider<ContainerData?> {
  WatchContainerDataProvider._({
    required WatchContainerDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerDataHash();

  @override
  String toString() {
    return r'watchContainerDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ContainerData?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ContainerData?> create(Ref ref) {
    final argument = this.argument as String;
    return watchContainerData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerDataHash() =>
    r'abd0e964a6444ed9be5da649a0f6a77bbbb54042';

final class WatchContainerDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ContainerData?>, String> {
  WatchContainerDataFamily._()
    : super(
        retry: null,
        name: r'watchContainerDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerDataProvider call(String containerId) =>
      WatchContainerDataProvider._(argument: containerId, from: this);

  @override
  String toString() => r'watchContainerDataProvider';
}

@ProviderFor(watchContainerTabId)
final watchContainerTabIdProvider = WatchContainerTabIdFamily._();

final class WatchContainerTabIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  WatchContainerTabIdProvider._({
    required WatchContainerTabIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerTabIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerTabIdHash();

  @override
  String toString() {
    return r'watchContainerTabIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as String;
    return watchContainerTabId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerTabIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerTabIdHash() =>
    r'c2cb263d4633fae436e7b3b216ab46d93ef49d4f';

final class WatchContainerTabIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, String> {
  WatchContainerTabIdFamily._()
    : super(
        retry: null,
        name: r'watchContainerTabIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerTabIdProvider call(String tabId) =>
      WatchContainerTabIdProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchContainerTabIdProvider';
}

@ProviderFor(watchTabContainerData)
final watchTabContainerDataProvider = WatchTabContainerDataFamily._();

final class WatchTabContainerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContainerData?>,
          ContainerData?,
          Stream<ContainerData?>
        >
    with $FutureModifier<ContainerData?>, $StreamProvider<ContainerData?> {
  WatchTabContainerDataProvider._({
    required WatchTabContainerDataFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'watchTabContainerDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabContainerDataHash();

  @override
  String toString() {
    return r'watchTabContainerDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ContainerData?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ContainerData?> create(Ref ref) {
    final argument = this.argument as String?;
    return watchTabContainerData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabContainerDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabContainerDataHash() =>
    r'7fe7d139555f6bbf3165ac67a3641bec9b1af966';

final class WatchTabContainerDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ContainerData?>, String?> {
  WatchTabContainerDataFamily._()
    : super(
        retry: null,
        name: r'watchTabContainerDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabContainerDataProvider call(String? tabId) =>
      WatchTabContainerDataProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchTabContainerDataProvider';
}

@ProviderFor(watchTabsContainerId)
final watchTabsContainerIdProvider = WatchTabsContainerIdFamily._();

final class WatchTabsContainerIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String?>>,
          Map<String, String?>,
          Stream<Map<String, String?>>
        >
    with
        $FutureModifier<Map<String, String?>>,
        $StreamProvider<Map<String, String?>> {
  WatchTabsContainerIdProvider._({
    required WatchTabsContainerIdFamily super.from,
    required EquatableValue<List<String>> super.argument,
  }) : super(
         retry: null,
         name: r'watchTabsContainerIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabsContainerIdHash();

  @override
  String toString() {
    return r'watchTabsContainerIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String?>> create(Ref ref) {
    final argument = this.argument as EquatableValue<List<String>>;
    return watchTabsContainerId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabsContainerIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabsContainerIdHash() =>
    r'75a915a0fd93cbb33a32f0aa521dbd61f1814c75';

final class WatchTabsContainerIdFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<String, String?>>,
          EquatableValue<List<String>>
        > {
  WatchTabsContainerIdFamily._()
    : super(
        retry: null,
        name: r'watchTabsContainerIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabsContainerIdProvider call(EquatableValue<List<String>> tabIds) =>
      WatchTabsContainerIdProvider._(argument: tabIds, from: this);

  @override
  String toString() => r'watchTabsContainerIdProvider';
}

@ProviderFor(watchAllAssignedSites)
final watchAllAssignedSitesProvider = WatchAllAssignedSitesProvider._();

final class WatchAllAssignedSitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SiteAssignment>>,
          List<SiteAssignment>,
          Stream<List<SiteAssignment>>
        >
    with
        $FutureModifier<List<SiteAssignment>>,
        $StreamProvider<List<SiteAssignment>> {
  WatchAllAssignedSitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllAssignedSitesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllAssignedSitesHash();

  @$internal
  @override
  $StreamProviderElement<List<SiteAssignment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SiteAssignment>> create(Ref ref) {
    return watchAllAssignedSites(ref);
  }
}

String _$watchAllAssignedSitesHash() =>
    r'5f658b5733ee20192eb86d3aeb79aa9678dafba8';

/// Strict-mode enforcement map: each Gecko cookie-store context that must be
/// enforced (a strict container's base context, plus the isolation contexts of
/// its isolated tabs) mapped to the base contextualIdentities its site
/// assignments are keyed on. Replicated to the container-proxy extension by
/// ProxySettingsReplication.

@ProviderFor(watchStrictContextAssignments)
final watchStrictContextAssignmentsProvider =
    WatchStrictContextAssignmentsProvider._();

/// Strict-mode enforcement map: each Gecko cookie-store context that must be
/// enforced (a strict container's base context, plus the isolation contexts of
/// its isolated tabs) mapped to the base contextualIdentities its site
/// assignments are keyed on. Replicated to the container-proxy extension by
/// ProxySettingsReplication.

final class WatchStrictContextAssignmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<String>>>,
          Map<String, List<String>>,
          Stream<Map<String, List<String>>>
        >
    with
        $FutureModifier<Map<String, List<String>>>,
        $StreamProvider<Map<String, List<String>>> {
  /// Strict-mode enforcement map: each Gecko cookie-store context that must be
  /// enforced (a strict container's base context, plus the isolation contexts of
  /// its isolated tabs) mapped to the base contextualIdentities its site
  /// assignments are keyed on. Replicated to the container-proxy extension by
  /// ProxySettingsReplication.
  WatchStrictContextAssignmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchStrictContextAssignmentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchStrictContextAssignmentsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, List<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, List<String>>> create(Ref ref) {
    return watchStrictContextAssignments(ref);
  }
}

String _$watchStrictContextAssignmentsHash() =>
    r'01a92529a90baf955c96c35180a50ec21ff913a8';

/// Watches distinct (isolationContextId, containerId) pairs for isolated tabs
/// assigned to containers. Used by ProxySettingsReplication to manage proxy
/// aliases for isolated contexts.
///
/// Returns a map from isolation context ID to the set of container IDs it
/// appears in. An isolation context needs an explicit routing alias if any
/// associated container has a proxy connection or bypasses global routing.

@ProviderFor(watchIsolatedContextContainerMap)
final watchIsolatedContextContainerMapProvider =
    WatchIsolatedContextContainerMapProvider._();

/// Watches distinct (isolationContextId, containerId) pairs for isolated tabs
/// assigned to containers. Used by ProxySettingsReplication to manage proxy
/// aliases for isolated contexts.
///
/// Returns a map from isolation context ID to the set of container IDs it
/// appears in. An isolation context needs an explicit routing alias if any
/// associated container has a proxy connection or bypasses global routing.

final class WatchIsolatedContextContainerMapProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Set<String>>>,
          Map<String, Set<String>>,
          Stream<Map<String, Set<String>>>
        >
    with
        $FutureModifier<Map<String, Set<String>>>,
        $StreamProvider<Map<String, Set<String>>> {
  /// Watches distinct (isolationContextId, containerId) pairs for isolated tabs
  /// assigned to containers. Used by ProxySettingsReplication to manage proxy
  /// aliases for isolated contexts.
  ///
  /// Returns a map from isolation context ID to the set of container IDs it
  /// appears in. An isolation context needs an explicit routing alias if any
  /// associated container has a proxy connection or bypasses global routing.
  WatchIsolatedContextContainerMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchIsolatedContextContainerMapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchIsolatedContextContainerMapHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, Set<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Set<String>>> create(Ref ref) {
    return watchIsolatedContextContainerMap(ref);
  }
}

String _$watchIsolatedContextContainerMapHash() =>
    r'6275a6c508777c306e2ababca83e2792d6d5efe1';

@ProviderFor(watchIsCurrentSiteAssignedToContainer)
final watchIsCurrentSiteAssignedToContainerProvider =
    WatchIsCurrentSiteAssignedToContainerProvider._();

final class WatchIsCurrentSiteAssignedToContainerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  WatchIsCurrentSiteAssignedToContainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchIsCurrentSiteAssignedToContainerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$watchIsCurrentSiteAssignedToContainerHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return watchIsCurrentSiteAssignedToContainer(ref);
  }
}

String _$watchIsCurrentSiteAssignedToContainerHash() =>
    r'b4e39fecacc84f53adfd1d6368a70a84db181661';
