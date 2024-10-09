// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unusedRandomTopicColorHash() =>
    r'099730b0d987cc37bcae4ef5c999cbebfa67d7da';

/// See also [unusedRandomTopicColor].
@ProviderFor(unusedRandomTopicColor)
final unusedRandomTopicColorProvider =
    AutoDisposeFutureProvider<Color>.internal(
  unusedRandomTopicColor,
  name: r'unusedRandomTopicColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unusedRandomTopicColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnusedRandomTopicColorRef = AutoDisposeFutureProviderRef<Color>;
String _$topicsWithCountHash() => r'cd9792b0e0af12cd8796a3f0b76b42171a4200e6';

/// See also [topicsWithCount].
@ProviderFor(topicsWithCount)
final topicsWithCountProvider =
    AutoDisposeStreamProvider<List<TopicDataWithCount>>.internal(
  topicsWithCount,
  name: r'topicsWithCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topicsWithCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TopicsWithCountRef
    = AutoDisposeStreamProviderRef<List<TopicDataWithCount>>;
String _$topicTabIdsHash() => r'f7ce2633804421a22df1efc42eb4d19d440d9fd3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [topicTabIds].
@ProviderFor(topicTabIds)
const topicTabIdsProvider = TopicTabIdsFamily();

/// See also [topicTabIds].
class TopicTabIdsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [topicTabIds].
  const TopicTabIdsFamily();

  /// See also [topicTabIds].
  TopicTabIdsProvider call(
    String? topicId,
  ) {
    return TopicTabIdsProvider(
      topicId,
    );
  }

  @override
  TopicTabIdsProvider getProviderOverride(
    covariant TopicTabIdsProvider provider,
  ) {
    return call(
      provider.topicId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'topicTabIdsProvider';
}

/// See also [topicTabIds].
class TopicTabIdsProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [topicTabIds].
  TopicTabIdsProvider(
    String? topicId,
  ) : this._internal(
          (ref) => topicTabIds(
            ref as TopicTabIdsRef,
            topicId,
          ),
          from: topicTabIdsProvider,
          name: r'topicTabIdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$topicTabIdsHash,
          dependencies: TopicTabIdsFamily._dependencies,
          allTransitiveDependencies:
              TopicTabIdsFamily._allTransitiveDependencies,
          topicId: topicId,
        );

  TopicTabIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topicId,
  }) : super.internal();

  final String? topicId;

  @override
  Override overrideWith(
    Stream<List<String>> Function(TopicTabIdsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TopicTabIdsProvider._internal(
        (ref) => create(ref as TopicTabIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topicId: topicId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _TopicTabIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicTabIdsProvider && other.topicId == topicId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topicId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TopicTabIdsRef on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `topicId` of this provider.
  String? get topicId;
}

class _TopicTabIdsProviderElement
    extends AutoDisposeStreamProviderElement<List<String>> with TopicTabIdsRef {
  _TopicTabIdsProviderElement(super.provider);

  @override
  String? get topicId => (origin as TopicTabIdsProvider).topicId;
}

String _$tabTopicIdHash() => r'284164ac3acd9be3ba4e15eba99fc8d97602ee84';

/// See also [tabTopicId].
@ProviderFor(tabTopicId)
const tabTopicIdProvider = TabTopicIdFamily();

/// See also [tabTopicId].
class TabTopicIdFamily extends Family<AsyncValue<String?>> {
  /// See also [tabTopicId].
  const TabTopicIdFamily();

  /// See also [tabTopicId].
  TabTopicIdProvider call(
    String tabId,
  ) {
    return TabTopicIdProvider(
      tabId,
    );
  }

  @override
  TabTopicIdProvider getProviderOverride(
    covariant TabTopicIdProvider provider,
  ) {
    return call(
      provider.tabId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tabTopicIdProvider';
}

/// See also [tabTopicId].
class TabTopicIdProvider extends AutoDisposeStreamProvider<String?> {
  /// See also [tabTopicId].
  TabTopicIdProvider(
    String tabId,
  ) : this._internal(
          (ref) => tabTopicId(
            ref as TabTopicIdRef,
            tabId,
          ),
          from: tabTopicIdProvider,
          name: r'tabTopicIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tabTopicIdHash,
          dependencies: TabTopicIdFamily._dependencies,
          allTransitiveDependencies:
              TabTopicIdFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  TabTopicIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String tabId;

  @override
  Override overrideWith(
    Stream<String?> Function(TabTopicIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TabTopicIdProvider._internal(
        (ref) => create(ref as TabTopicIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tabId: tabId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<String?> createElement() {
    return _TabTopicIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabTopicIdProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TabTopicIdRef on AutoDisposeStreamProviderRef<String?> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _TabTopicIdProviderElement
    extends AutoDisposeStreamProviderElement<String?> with TabTopicIdRef {
  _TabTopicIdProviderElement(super.provider);

  @override
  String get tabId => (origin as TabTopicIdProvider).tabId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
