// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readerability.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readerabilityControllerHash() =>
    r'1260623c58d23511c3e4f58f97e18663be354ced';

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

abstract class _$ReaderabilityController
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final InAppWebViewController? controller;

  FutureOr<void> build(
    InAppWebViewController? controller,
  );
}

/// See also [ReaderabilityController].
@ProviderFor(ReaderabilityController)
const readerabilityControllerProvider = ReaderabilityControllerFamily();

/// See also [ReaderabilityController].
class ReaderabilityControllerFamily extends Family<AsyncValue<void>> {
  /// See also [ReaderabilityController].
  const ReaderabilityControllerFamily();

  /// See also [ReaderabilityController].
  ReaderabilityControllerProvider call(
    InAppWebViewController? controller,
  ) {
    return ReaderabilityControllerProvider(
      controller,
    );
  }

  @override
  ReaderabilityControllerProvider getProviderOverride(
    covariant ReaderabilityControllerProvider provider,
  ) {
    return call(
      provider.controller,
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
class ReaderabilityControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ReaderabilityController,
        void> {
  /// See also [ReaderabilityController].
  ReaderabilityControllerProvider(
    InAppWebViewController? controller,
  ) : this._internal(
          () => ReaderabilityController()..controller = controller,
          from: readerabilityControllerProvider,
          name: r'readerabilityControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$readerabilityControllerHash,
          dependencies: ReaderabilityControllerFamily._dependencies,
          allTransitiveDependencies:
              ReaderabilityControllerFamily._allTransitiveDependencies,
          controller: controller,
        );

  ReaderabilityControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.controller,
  }) : super.internal();

  final InAppWebViewController? controller;

  @override
  FutureOr<void> runNotifierBuild(
    covariant ReaderabilityController notifier,
  ) {
    return notifier.build(
      controller,
    );
  }

  @override
  Override overrideWith(ReaderabilityController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReaderabilityControllerProvider._internal(
        () => create()..controller = controller,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        controller: controller,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ReaderabilityController, void>
      createElement() {
    return _ReaderabilityControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderabilityControllerProvider &&
        other.controller == controller;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, controller.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReaderabilityControllerRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `controller` of this provider.
  InAppWebViewController? get controller;
}

class _ReaderabilityControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ReaderabilityController,
        void> with ReaderabilityControllerRef {
  _ReaderabilityControllerProviderElement(super.provider);

  @override
  InAppWebViewController? get controller =>
      (origin as ReaderabilityControllerProvider).controller;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
