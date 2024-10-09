// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_in_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$findInPageRepositoryHash() =>
    r'a307a7169cfc559a687483962bd595d808c159bf';

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

abstract class _$FindInPageRepository
    extends BuildlessAutoDisposeNotifier<void> {
  late final String? tabId;

  void build(
    String? tabId,
  );
}

/// See also [FindInPageRepository].
@ProviderFor(FindInPageRepository)
const findInPageRepositoryProvider = FindInPageRepositoryFamily();

/// See also [FindInPageRepository].
class FindInPageRepositoryFamily extends Family<void> {
  /// See also [FindInPageRepository].
  const FindInPageRepositoryFamily();

  /// See also [FindInPageRepository].
  FindInPageRepositoryProvider call(
    String? tabId,
  ) {
    return FindInPageRepositoryProvider(
      tabId,
    );
  }

  @override
  FindInPageRepositoryProvider getProviderOverride(
    covariant FindInPageRepositoryProvider provider,
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
  String? get name => r'findInPageRepositoryProvider';
}

/// See also [FindInPageRepository].
class FindInPageRepositoryProvider
    extends AutoDisposeNotifierProviderImpl<FindInPageRepository, void> {
  /// See also [FindInPageRepository].
  FindInPageRepositoryProvider(
    String? tabId,
  ) : this._internal(
          () => FindInPageRepository()..tabId = tabId,
          from: findInPageRepositoryProvider,
          name: r'findInPageRepositoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$findInPageRepositoryHash,
          dependencies: FindInPageRepositoryFamily._dependencies,
          allTransitiveDependencies:
              FindInPageRepositoryFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  FindInPageRepositoryProvider._internal(
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
    covariant FindInPageRepository notifier,
  ) {
    return notifier.build(
      tabId,
    );
  }

  @override
  Override overrideWith(FindInPageRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: FindInPageRepositoryProvider._internal(
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
  AutoDisposeNotifierProviderElement<FindInPageRepository, void>
      createElement() {
    return _FindInPageRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FindInPageRepositoryProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FindInPageRepositoryRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `tabId` of this provider.
  String? get tabId;
}

class _FindInPageRepositoryProviderElement
    extends AutoDisposeNotifierProviderElement<FindInPageRepository, void>
    with FindInPageRepositoryRef {
  _FindInPageRepositoryProviderElement(super.provider);

  @override
  String? get tabId => (origin as FindInPageRepositoryProvider).tabId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
