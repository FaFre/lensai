// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabDatabaseHash() => r'b886b089ae5fdb9bdcc0982efe5fcbe9bc66486f';

/// See also [tabDatabase].
@ProviderFor(tabDatabase)
final tabDatabaseProvider = Provider<TabDatabase>.internal(
  tabDatabase,
  name: r'tabDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tabDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TabDatabaseRef = ProviderRef<TabDatabase>;
String _$isTabExistingHash() => r'98fc7bf073ba8f73c20df6ba7076672ff497246f';

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

/// See also [isTabExisting].
@ProviderFor(isTabExisting)
const isTabExistingProvider = IsTabExistingFamily();

/// See also [isTabExisting].
class IsTabExistingFamily extends Family<AsyncValue<bool>> {
  /// See also [isTabExisting].
  const IsTabExistingFamily();

  /// See also [isTabExisting].
  IsTabExistingProvider call(
    String tabId,
  ) {
    return IsTabExistingProvider(
      tabId,
    );
  }

  @override
  IsTabExistingProvider getProviderOverride(
    covariant IsTabExistingProvider provider,
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
  String? get name => r'isTabExistingProvider';
}

/// See also [isTabExisting].
class IsTabExistingProvider extends AutoDisposeStreamProvider<bool> {
  /// See also [isTabExisting].
  IsTabExistingProvider(
    String tabId,
  ) : this._internal(
          (ref) => isTabExisting(
            ref as IsTabExistingRef,
            tabId,
          ),
          from: isTabExistingProvider,
          name: r'isTabExistingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isTabExistingHash,
          dependencies: IsTabExistingFamily._dependencies,
          allTransitiveDependencies:
              IsTabExistingFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  IsTabExistingProvider._internal(
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
    Stream<bool> Function(IsTabExistingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsTabExistingProvider._internal(
        (ref) => create(ref as IsTabExistingRef),
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
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _IsTabExistingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsTabExistingProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsTabExistingRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _IsTabExistingProviderElement
    extends AutoDisposeStreamProviderElement<bool> with IsTabExistingRef {
  _IsTabExistingProviderElement(super.provider);

  @override
  String get tabId => (origin as IsTabExistingProvider).tabId;
}

String _$tabDataHash() => r'8b799386305d0c31103bc48a5a467df41d57d065';

/// See also [tabData].
@ProviderFor(tabData)
const tabDataProvider = TabDataFamily();

/// See also [tabData].
class TabDataFamily extends Family<AsyncValue<TabData?>> {
  /// See also [tabData].
  const TabDataFamily();

  /// See also [tabData].
  TabDataProvider call(
    String tabId,
  ) {
    return TabDataProvider(
      tabId,
    );
  }

  @override
  TabDataProvider getProviderOverride(
    covariant TabDataProvider provider,
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
  String? get name => r'tabDataProvider';
}

/// See also [tabData].
class TabDataProvider extends AutoDisposeStreamProvider<TabData?> {
  /// See also [tabData].
  TabDataProvider(
    String tabId,
  ) : this._internal(
          (ref) => tabData(
            ref as TabDataRef,
            tabId,
          ),
          from: tabDataProvider,
          name: r'tabDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tabDataHash,
          dependencies: TabDataFamily._dependencies,
          allTransitiveDependencies: TabDataFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  TabDataProvider._internal(
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
    Stream<TabData?> Function(TabDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TabDataProvider._internal(
        (ref) => create(ref as TabDataRef),
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
  AutoDisposeStreamProviderElement<TabData?> createElement() {
    return _TabDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabDataProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TabDataRef on AutoDisposeStreamProviderRef<TabData?> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _TabDataProviderElement extends AutoDisposeStreamProviderElement<TabData?>
    with TabDataRef {
  _TabDataProviderElement(super.provider);

  @override
  String get tabId => (origin as TabDataProvider).tabId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
