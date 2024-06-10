// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bangHash() => r'e3d44af52e27831b568f292d38b447a443acec95';

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

/// See also [bang].
@ProviderFor(bang)
const bangProvider = BangFamily();

/// See also [bang].
class BangFamily extends Family<AsyncValue<BangData?>> {
  /// See also [bang].
  const BangFamily();

  /// See also [bang].
  BangProvider call(
    String? trigger,
  ) {
    return BangProvider(
      trigger,
    );
  }

  @override
  BangProvider getProviderOverride(
    covariant BangProvider provider,
  ) {
    return call(
      provider.trigger,
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
  String? get name => r'bangProvider';
}

/// See also [bang].
class BangProvider extends AutoDisposeStreamProvider<BangData?> {
  /// See also [bang].
  BangProvider(
    String? trigger,
  ) : this._internal(
          (ref) => bang(
            ref as BangRef,
            trigger,
          ),
          from: bangProvider,
          name: r'bangProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$bangHash,
          dependencies: BangFamily._dependencies,
          allTransitiveDependencies: BangFamily._allTransitiveDependencies,
          trigger: trigger,
        );

  BangProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trigger,
  }) : super.internal();

  final String? trigger;

  @override
  Override overrideWith(
    Stream<BangData?> Function(BangRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BangProvider._internal(
        (ref) => create(ref as BangRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trigger: trigger,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<BangData?> createElement() {
    return _BangProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BangProvider && other.trigger == trigger;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trigger.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BangRef on AutoDisposeStreamProviderRef<BangData?> {
  /// The parameter `trigger` of this provider.
  String? get trigger;
}

class _BangProviderElement extends AutoDisposeStreamProviderElement<BangData?>
    with BangRef {
  _BangProviderElement(super.provider);

  @override
  String? get trigger => (origin as BangProvider).trigger;
}

String _$kagiSearchBangHash() => r'ec830f26cf1d23e1e75747e1523cb1868e77d40b';

/// See also [kagiSearchBang].
@ProviderFor(kagiSearchBang)
final kagiSearchBangProvider = StreamProvider<BangData?>.internal(
  kagiSearchBang,
  name: r'kagiSearchBangProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kagiSearchBangHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef KagiSearchBangRef = StreamProviderRef<BangData?>;
String _$allBangsHash() => r'212201f81e21fd0c1b5fb192359fb6ff8269a2a6';

/// See also [allBangs].
@ProviderFor(allBangs)
final allBangsProvider = AutoDisposeStreamProvider<List<BangData>>.internal(
  allBangs,
  name: r'allBangsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allBangsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllBangsRef = AutoDisposeStreamProviderRef<List<BangData>>;
String _$frequentBangsHash() => r'12867819c6e2bbc5f2b6342aacc286f62d3a1803';

/// See also [frequentBangs].
@ProviderFor(frequentBangs)
final frequentBangsProvider =
    AutoDisposeStreamProvider<List<BangData>>.internal(
  frequentBangs,
  name: r'frequentBangsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$frequentBangsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FrequentBangsRef = AutoDisposeStreamProviderRef<List<BangData>>;
String _$ensureIconAvailableHash() =>
    r'2e112c88da8cf9bf12bdc5e5d525d59fe97a9419';

/// See also [ensureIconAvailable].
@ProviderFor(ensureIconAvailable)
const ensureIconAvailableProvider = EnsureIconAvailableFamily();

/// See also [ensureIconAvailable].
class EnsureIconAvailableFamily extends Family<AsyncValue<BangData>> {
  /// See also [ensureIconAvailable].
  const EnsureIconAvailableFamily();

  /// See also [ensureIconAvailable].
  EnsureIconAvailableProvider call(
    BangData bang,
  ) {
    return EnsureIconAvailableProvider(
      bang,
    );
  }

  @override
  EnsureIconAvailableProvider getProviderOverride(
    covariant EnsureIconAvailableProvider provider,
  ) {
    return call(
      provider.bang,
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
  String? get name => r'ensureIconAvailableProvider';
}

/// See also [ensureIconAvailable].
class EnsureIconAvailableProvider extends AutoDisposeFutureProvider<BangData> {
  /// See also [ensureIconAvailable].
  EnsureIconAvailableProvider(
    BangData bang,
  ) : this._internal(
          (ref) => ensureIconAvailable(
            ref as EnsureIconAvailableRef,
            bang,
          ),
          from: ensureIconAvailableProvider,
          name: r'ensureIconAvailableProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ensureIconAvailableHash,
          dependencies: EnsureIconAvailableFamily._dependencies,
          allTransitiveDependencies:
              EnsureIconAvailableFamily._allTransitiveDependencies,
          bang: bang,
        );

  EnsureIconAvailableProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bang,
  }) : super.internal();

  final BangData bang;

  @override
  Override overrideWith(
    FutureOr<BangData> Function(EnsureIconAvailableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EnsureIconAvailableProvider._internal(
        (ref) => create(ref as EnsureIconAvailableRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bang: bang,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<BangData> createElement() {
    return _EnsureIconAvailableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnsureIconAvailableProvider && other.bang == bang;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bang.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EnsureIconAvailableRef on AutoDisposeFutureProviderRef<BangData> {
  /// The parameter `bang` of this provider.
  BangData get bang;
}

class _EnsureIconAvailableProviderElement
    extends AutoDisposeFutureProviderElement<BangData>
    with EnsureIconAvailableRef {
  _EnsureIconAvailableProviderElement(super.provider);

  @override
  BangData get bang => (origin as EnsureIconAvailableProvider).bang;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
