// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabSessionHash() => r'25afbead5c1110ca865e48a5009da70eb20d3a28';

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

abstract class _$TabSession extends BuildlessAutoDisposeNotifier<void> {
  late final String? tabId;

  void build(
    String? tabId,
  );
}

/// See also [TabSession].
@ProviderFor(TabSession)
const tabSessionProvider = TabSessionFamily();

/// See also [TabSession].
class TabSessionFamily extends Family<void> {
  /// See also [TabSession].
  const TabSessionFamily();

  /// See also [TabSession].
  TabSessionProvider call(
    String? tabId,
  ) {
    return TabSessionProvider(
      tabId,
    );
  }

  @override
  TabSessionProvider getProviderOverride(
    covariant TabSessionProvider provider,
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
  String? get name => r'tabSessionProvider';
}

/// See also [TabSession].
class TabSessionProvider
    extends AutoDisposeNotifierProviderImpl<TabSession, void> {
  /// See also [TabSession].
  TabSessionProvider(
    String? tabId,
  ) : this._internal(
          () => TabSession()..tabId = tabId,
          from: tabSessionProvider,
          name: r'tabSessionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tabSessionHash,
          dependencies: TabSessionFamily._dependencies,
          allTransitiveDependencies:
              TabSessionFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  TabSessionProvider._internal(
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
  void runNotifierBuild(
    covariant TabSession notifier,
  ) {
    return notifier.build(
      tabId,
    );
  }

  @override
  Override overrideWith(TabSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: TabSessionProvider._internal(
        () => create()..tabId = tabId,
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
  AutoDisposeNotifierProviderElement<TabSession, void> createElement() {
    return _TabSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabSessionProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TabSessionRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `tabId` of this provider.
  String? get tabId;
}

class _TabSessionProviderElement
    extends AutoDisposeNotifierProviderElement<TabSession, void>
    with TabSessionRef {
  _TabSessionProviderElement(super.provider);

  @override
  String? get tabId => (origin as TabSessionProvider).tabId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
