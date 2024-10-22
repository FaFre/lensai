// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabStateHash() => r'9fd7990804643fac180dd4fd50803bc7c9fa2827';

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

String _$selectedTabStateHash() => r'22172913554e14e67f692eff0777ea015175906e';

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
String _$tabStatesHash() => r'dcd293279a901eeaab7728979e39e5ca3bee8c66';

/// See also [TabStates].
@ProviderFor(TabStates)
final tabStatesProvider =
    NotifierProvider<TabStates, Map<String, TabState>>.internal(
  TabStates.new,
  name: r'tabStatesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tabStatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TabStates = Notifier<Map<String, TabState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
