// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedBangDataHash() => r'40dd3c51694394909fe83659ff3e19d51a06ec55';

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

/// See also [selectedBangData].
@ProviderFor(selectedBangData)
const selectedBangDataProvider = SelectedBangDataFamily();

/// See also [selectedBangData].
class SelectedBangDataFamily extends Family<AsyncValue<BangData?>> {
  /// See also [selectedBangData].
  const SelectedBangDataFamily();

  /// See also [selectedBangData].
  SelectedBangDataProvider call({
    String? domain,
  }) {
    return SelectedBangDataProvider(
      domain: domain,
    );
  }

  @override
  SelectedBangDataProvider getProviderOverride(
    covariant SelectedBangDataProvider provider,
  ) {
    return call(
      domain: provider.domain,
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
  String? get name => r'selectedBangDataProvider';
}

/// See also [selectedBangData].
class SelectedBangDataProvider extends AutoDisposeStreamProvider<BangData?> {
  /// See also [selectedBangData].
  SelectedBangDataProvider({
    String? domain,
  }) : this._internal(
          (ref) => selectedBangData(
            ref as SelectedBangDataRef,
            domain: domain,
          ),
          from: selectedBangDataProvider,
          name: r'selectedBangDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedBangDataHash,
          dependencies: SelectedBangDataFamily._dependencies,
          allTransitiveDependencies:
              SelectedBangDataFamily._allTransitiveDependencies,
          domain: domain,
        );

  SelectedBangDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.domain,
  }) : super.internal();

  final String? domain;

  @override
  Override overrideWith(
    Stream<BangData?> Function(SelectedBangDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SelectedBangDataProvider._internal(
        (ref) => create(ref as SelectedBangDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        domain: domain,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<BangData?> createElement() {
    return _SelectedBangDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangDataProvider && other.domain == domain;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, domain.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SelectedBangDataRef on AutoDisposeStreamProviderRef<BangData?> {
  /// The parameter `domain` of this provider.
  String? get domain;
}

class _SelectedBangDataProviderElement
    extends AutoDisposeStreamProviderElement<BangData?>
    with SelectedBangDataRef {
  _SelectedBangDataProviderElement(super.provider);

  @override
  String? get domain => (origin as SelectedBangDataProvider).domain;
}

String _$overlayDialogHash() => r'7a0376fff0ba12c70a257a47391e7c049dabd36d';

/// See also [OverlayDialog].
@ProviderFor(OverlayDialog)
final overlayDialogProvider =
    AutoDisposeNotifierProvider<OverlayDialog, Widget?>.internal(
  OverlayDialog.new,
  name: r'overlayDialogProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overlayDialogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OverlayDialog = AutoDisposeNotifier<Widget?>;
String _$bottomSheetHash() => r'31108d6d80d5b858024a8a8ae9ebb9c650eabe70';

/// See also [BottomSheet].
@ProviderFor(BottomSheet)
final bottomSheetProvider =
    AutoDisposeNotifierProvider<BottomSheet, Sheet?>.internal(
  BottomSheet.new,
  name: r'bottomSheetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bottomSheetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BottomSheet = AutoDisposeNotifier<Sheet?>;
String _$bottomSheetExtendHash() => r'81ae254499d1d7f57309274b0f18747b94d6dda3';

/// See also [BottomSheetExtend].
@ProviderFor(BottomSheetExtend)
final bottomSheetExtendProvider =
    StreamNotifierProvider<BottomSheetExtend, double>.internal(
  BottomSheetExtend.new,
  name: r'bottomSheetExtendProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bottomSheetExtendHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BottomSheetExtend = StreamNotifier<double>;
String _$selectedBangTriggerHash() =>
    r'b0e12bc95e93d50d04f1c658230cea9f15ff0385';

abstract class _$SelectedBangTrigger extends BuildlessNotifier<String?> {
  late final String? domain;

  String? build({
    String? domain,
  });
}

/// See also [SelectedBangTrigger].
@ProviderFor(SelectedBangTrigger)
const selectedBangTriggerProvider = SelectedBangTriggerFamily();

/// See also [SelectedBangTrigger].
class SelectedBangTriggerFamily extends Family<String?> {
  /// See also [SelectedBangTrigger].
  const SelectedBangTriggerFamily();

  /// See also [SelectedBangTrigger].
  SelectedBangTriggerProvider call({
    String? domain,
  }) {
    return SelectedBangTriggerProvider(
      domain: domain,
    );
  }

  @override
  SelectedBangTriggerProvider getProviderOverride(
    covariant SelectedBangTriggerProvider provider,
  ) {
    return call(
      domain: provider.domain,
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
  String? get name => r'selectedBangTriggerProvider';
}

/// See also [SelectedBangTrigger].
class SelectedBangTriggerProvider
    extends NotifierProviderImpl<SelectedBangTrigger, String?> {
  /// See also [SelectedBangTrigger].
  SelectedBangTriggerProvider({
    String? domain,
  }) : this._internal(
          () => SelectedBangTrigger()..domain = domain,
          from: selectedBangTriggerProvider,
          name: r'selectedBangTriggerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedBangTriggerHash,
          dependencies: SelectedBangTriggerFamily._dependencies,
          allTransitiveDependencies:
              SelectedBangTriggerFamily._allTransitiveDependencies,
          domain: domain,
        );

  SelectedBangTriggerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.domain,
  }) : super.internal();

  final String? domain;

  @override
  String? runNotifierBuild(
    covariant SelectedBangTrigger notifier,
  ) {
    return notifier.build(
      domain: domain,
    );
  }

  @override
  Override overrideWith(SelectedBangTrigger Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectedBangTriggerProvider._internal(
        () => create()..domain = domain,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        domain: domain,
      ),
    );
  }

  @override
  NotifierProviderElement<SelectedBangTrigger, String?> createElement() {
    return _SelectedBangTriggerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangTriggerProvider && other.domain == domain;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, domain.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SelectedBangTriggerRef on NotifierProviderRef<String?> {
  /// The parameter `domain` of this provider.
  String? get domain;
}

class _SelectedBangTriggerProviderElement
    extends NotifierProviderElement<SelectedBangTrigger, String?>
    with SelectedBangTriggerRef {
  _SelectedBangTriggerProviderElement(super.provider);

  @override
  String? get domain => (origin as SelectedBangTriggerProvider).domain;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
