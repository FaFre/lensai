// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readerability_script.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readerabilityScriptServiceHash() =>
    r'7a4fe65f683c31545b2f2bcb3ea199619be4bf4b';

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

abstract class _$ReaderabilityScriptService
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final InAppWebViewController? controller;

  FutureOr<void> build(
    InAppWebViewController? controller,
  );
}

/// See also [ReaderabilityScriptService].
@ProviderFor(ReaderabilityScriptService)
const readerabilityScriptServiceProvider = ReaderabilityScriptServiceFamily();

/// See also [ReaderabilityScriptService].
class ReaderabilityScriptServiceFamily extends Family<AsyncValue<void>> {
  /// See also [ReaderabilityScriptService].
  const ReaderabilityScriptServiceFamily();

  /// See also [ReaderabilityScriptService].
  ReaderabilityScriptServiceProvider call(
    InAppWebViewController? controller,
  ) {
    return ReaderabilityScriptServiceProvider(
      controller,
    );
  }

  @override
  ReaderabilityScriptServiceProvider getProviderOverride(
    covariant ReaderabilityScriptServiceProvider provider,
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
  String? get name => r'readerabilityScriptServiceProvider';
}

/// See also [ReaderabilityScriptService].
class ReaderabilityScriptServiceProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ReaderabilityScriptService,
        void> {
  /// See also [ReaderabilityScriptService].
  ReaderabilityScriptServiceProvider(
    InAppWebViewController? controller,
  ) : this._internal(
          () => ReaderabilityScriptService()..controller = controller,
          from: readerabilityScriptServiceProvider,
          name: r'readerabilityScriptServiceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$readerabilityScriptServiceHash,
          dependencies: ReaderabilityScriptServiceFamily._dependencies,
          allTransitiveDependencies:
              ReaderabilityScriptServiceFamily._allTransitiveDependencies,
          controller: controller,
        );

  ReaderabilityScriptServiceProvider._internal(
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
    covariant ReaderabilityScriptService notifier,
  ) {
    return notifier.build(
      controller,
    );
  }

  @override
  Override overrideWith(ReaderabilityScriptService Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReaderabilityScriptServiceProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ReaderabilityScriptService, void>
      createElement() {
    return _ReaderabilityScriptServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderabilityScriptServiceProvider &&
        other.controller == controller;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, controller.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReaderabilityScriptServiceRef
    on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `controller` of this provider.
  InAppWebViewController? get controller;
}

class _ReaderabilityScriptServiceProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ReaderabilityScriptService,
        void> with ReaderabilityScriptServiceRef {
  _ReaderabilityScriptServiceProviderElement(super.provider);

  @override
  InAppWebViewController? get controller =>
      (origin as ReaderabilityScriptServiceProvider).controller;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
