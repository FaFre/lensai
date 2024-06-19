// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lastSyncOfSourceHash() => r'0f96dc6c5ffc44654734bd4be187fd0c4d34a310';

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

/// See also [lastSyncOfSource].
@ProviderFor(lastSyncOfSource)
const lastSyncOfSourceProvider = LastSyncOfSourceFamily();

/// See also [lastSyncOfSource].
class LastSyncOfSourceFamily extends Family<AsyncValue<DateTime?>> {
  /// See also [lastSyncOfSource].
  const LastSyncOfSourceFamily();

  /// See also [lastSyncOfSource].
  LastSyncOfSourceProvider call(
    HostSource source,
  ) {
    return LastSyncOfSourceProvider(
      source,
    );
  }

  @override
  LastSyncOfSourceProvider getProviderOverride(
    covariant LastSyncOfSourceProvider provider,
  ) {
    return call(
      provider.source,
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
  String? get name => r'lastSyncOfSourceProvider';
}

/// See also [lastSyncOfSource].
class LastSyncOfSourceProvider extends AutoDisposeStreamProvider<DateTime?> {
  /// See also [lastSyncOfSource].
  LastSyncOfSourceProvider(
    HostSource source,
  ) : this._internal(
          (ref) => lastSyncOfSource(
            ref as LastSyncOfSourceRef,
            source,
          ),
          from: lastSyncOfSourceProvider,
          name: r'lastSyncOfSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lastSyncOfSourceHash,
          dependencies: LastSyncOfSourceFamily._dependencies,
          allTransitiveDependencies:
              LastSyncOfSourceFamily._allTransitiveDependencies,
          source: source,
        );

  LastSyncOfSourceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.source,
  }) : super.internal();

  final HostSource source;

  @override
  Override overrideWith(
    Stream<DateTime?> Function(LastSyncOfSourceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LastSyncOfSourceProvider._internal(
        (ref) => create(ref as LastSyncOfSourceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        source: source,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DateTime?> createElement() {
    return _LastSyncOfSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LastSyncOfSourceProvider && other.source == source;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, source.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LastSyncOfSourceRef on AutoDisposeStreamProviderRef<DateTime?> {
  /// The parameter `source` of this provider.
  HostSource get source;
}

class _LastSyncOfSourceProviderElement
    extends AutoDisposeStreamProviderElement<DateTime?>
    with LastSyncOfSourceRef {
  _LastSyncOfSourceProviderElement(super.provider);

  @override
  HostSource get source => (origin as LastSyncOfSourceProvider).source;
}

String _$hostCountOfSourceHash() => r'3bd118037e5762fd5134838ac12ed6d0d2283e76';

/// See also [hostCountOfSource].
@ProviderFor(hostCountOfSource)
const hostCountOfSourceProvider = HostCountOfSourceFamily();

/// See also [hostCountOfSource].
class HostCountOfSourceFamily extends Family<AsyncValue<int>> {
  /// See also [hostCountOfSource].
  const HostCountOfSourceFamily();

  /// See also [hostCountOfSource].
  HostCountOfSourceProvider call(
    HostSource source,
  ) {
    return HostCountOfSourceProvider(
      source,
    );
  }

  @override
  HostCountOfSourceProvider getProviderOverride(
    covariant HostCountOfSourceProvider provider,
  ) {
    return call(
      provider.source,
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
  String? get name => r'hostCountOfSourceProvider';
}

/// See also [hostCountOfSource].
class HostCountOfSourceProvider extends AutoDisposeStreamProvider<int> {
  /// See also [hostCountOfSource].
  HostCountOfSourceProvider(
    HostSource source,
  ) : this._internal(
          (ref) => hostCountOfSource(
            ref as HostCountOfSourceRef,
            source,
          ),
          from: hostCountOfSourceProvider,
          name: r'hostCountOfSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hostCountOfSourceHash,
          dependencies: HostCountOfSourceFamily._dependencies,
          allTransitiveDependencies:
              HostCountOfSourceFamily._allTransitiveDependencies,
          source: source,
        );

  HostCountOfSourceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.source,
  }) : super.internal();

  final HostSource source;

  @override
  Override overrideWith(
    Stream<int> Function(HostCountOfSourceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HostCountOfSourceProvider._internal(
        (ref) => create(ref as HostCountOfSourceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        source: source,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _HostCountOfSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HostCountOfSourceProvider && other.source == source;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, source.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HostCountOfSourceRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `source` of this provider.
  HostSource get source;
}

class _HostCountOfSourceProviderElement
    extends AutoDisposeStreamProviderElement<int> with HostCountOfSourceRef {
  _HostCountOfSourceProviderElement(super.provider);

  @override
  HostSource get source => (origin as HostCountOfSourceProvider).source;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
