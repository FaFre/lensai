// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventServiceHash() => r'5aa357fdf0d217677a9a66ecb50417ac18929cad';

/// See also [eventService].
@ProviderFor(eventService)
final eventServiceProvider = Provider<GeckoEventService>.internal(
  eventService,
  name: r'eventServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$eventServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EventServiceRef = ProviderRef<GeckoEventService>;
String _$tabStateHash() => r'6985f5472625a9cf44c8bbc61e61b7577eb60e71';

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

/// See also [tabState].
@ProviderFor(tabState)
const tabStateProvider = TabStateFamily();

/// See also [tabState].
class TabStateFamily extends Family<TabState?> {
  /// See also [tabState].
  const TabStateFamily();

  /// See also [tabState].
  TabStateProvider call(
    String? tabId,
  ) {
    return TabStateProvider(
      tabId,
    );
  }

  @override
  TabStateProvider getProviderOverride(
    covariant TabStateProvider provider,
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
  String? get name => r'tabStateProvider';
}

/// See also [tabState].
class TabStateProvider extends AutoDisposeProvider<TabState?> {
  /// See also [tabState].
  TabStateProvider(
    String? tabId,
  ) : this._internal(
          (ref) => tabState(
            ref as TabStateRef,
            tabId,
          ),
          from: tabStateProvider,
          name: r'tabStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tabStateHash,
          dependencies: TabStateFamily._dependencies,
          allTransitiveDependencies: TabStateFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  TabStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String? tabId;

  @override
  Override overrideWith(
    TabState? Function(TabStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TabStateProvider._internal(
        (ref) => create(ref as TabStateRef),
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
  AutoDisposeProviderElement<TabState?> createElement() {
    return _TabStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabStateProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TabStateRef on AutoDisposeProviderRef<TabState?> {
  /// The parameter `tabId` of this provider.
  String? get tabId;
}

class _TabStateProviderElement extends AutoDisposeProviderElement<TabState?>
    with TabStateRef {
  _TabStateProviderElement(super.provider);

  @override
  String? get tabId => (origin as TabStateProvider).tabId;
}

String _$selectedTabStateHash() => r'd5240ade9010f5c9f00d7a4f419e1b776f75fac1';

/// See also [selectedTabState].
@ProviderFor(selectedTabState)
final selectedTabStateProvider = AutoDisposeProvider<TabState?>.internal(
  selectedTabState,
  name: r'selectedTabStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTabStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SelectedTabStateRef = AutoDisposeProviderRef<TabState?>;
String _$selectedTabSessionNotifierHash() =>
    r'1b0fe1afa87c0b09fc8407ceb91946fffaef5214';

/// See also [selectedTabSessionNotifier].
@ProviderFor(selectedTabSessionNotifier)
final selectedTabSessionNotifierProvider =
    AutoDisposeProvider<TabSession>.internal(
  selectedTabSessionNotifier,
  name: r'selectedTabSessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTabSessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SelectedTabSessionNotifierRef = AutoDisposeProviderRef<TabSession>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
