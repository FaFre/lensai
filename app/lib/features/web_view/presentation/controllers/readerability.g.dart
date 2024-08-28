// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readerability.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readerabilityControllerHash() =>
    r'a1c8da3a9cf48300089e390a4fcae89862a6ec1a';

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

abstract class _$ReaderabilityController extends BuildlessAutoDisposeNotifier<
    AsyncValue<({bool readerable, bool applied})>> {
  late final String tabId;

  AsyncValue<({bool readerable, bool applied})> build(
    String tabId,
  );
}

/// See also [ReaderabilityController].
@ProviderFor(ReaderabilityController)
const readerabilityControllerProvider = ReaderabilityControllerFamily();

/// See also [ReaderabilityController].
class ReaderabilityControllerFamily
    extends Family<AsyncValue<({bool readerable, bool applied})>> {
  /// See also [ReaderabilityController].
  const ReaderabilityControllerFamily();

  /// See also [ReaderabilityController].
  ReaderabilityControllerProvider call(
    String tabId,
  ) {
    return ReaderabilityControllerProvider(
      tabId,
    );
  }

  @override
  ReaderabilityControllerProvider getProviderOverride(
    covariant ReaderabilityControllerProvider provider,
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
  String? get name => r'readerabilityControllerProvider';
}

/// See also [ReaderabilityController].
class ReaderabilityControllerProvider extends AutoDisposeNotifierProviderImpl<
    ReaderabilityController, AsyncValue<({bool readerable, bool applied})>> {
  /// See also [ReaderabilityController].
  ReaderabilityControllerProvider(
    String tabId,
  ) : this._internal(
          () => ReaderabilityController()..tabId = tabId,
          from: readerabilityControllerProvider,
          name: r'readerabilityControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$readerabilityControllerHash,
          dependencies: ReaderabilityControllerFamily._dependencies,
          allTransitiveDependencies:
              ReaderabilityControllerFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  ReaderabilityControllerProvider._internal(
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
  AsyncValue<({bool readerable, bool applied})> runNotifierBuild(
    covariant ReaderabilityController notifier,
  ) {
    return notifier.build(
      tabId,
    );
  }

  @override
  Override overrideWith(ReaderabilityController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReaderabilityControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<ReaderabilityController,
      AsyncValue<({bool readerable, bool applied})>> createElement() {
    return _ReaderabilityControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderabilityControllerProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReaderabilityControllerRef on AutoDisposeNotifierProviderRef<
    AsyncValue<({bool readerable, bool applied})>> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _ReaderabilityControllerProviderElement
    extends AutoDisposeNotifierProviderElement<ReaderabilityController,
        AsyncValue<({bool readerable, bool applied})>>
    with ReaderabilityControllerRef {
  _ReaderabilityControllerProviderElement(super.provider);

  @override
  String get tabId => (origin as ReaderabilityControllerProvider).tabId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
