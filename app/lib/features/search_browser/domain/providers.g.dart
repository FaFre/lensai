// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedBangDataHash() => r'619555a048e9d38602ceffa42dae1ba7d68ced89';

/// See also [selectedBangData].
@ProviderFor(selectedBangData)
final selectedBangDataProvider = AutoDisposeStreamProvider<BangData?>.internal(
  selectedBangData,
  name: r'selectedBangDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedBangDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SelectedBangDataRef = AutoDisposeStreamProviderRef<BangData?>;
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
    r'd110e4f8bd9d362e0cc54ee56a4f247d0870c760';

/// See also [SelectedBangTrigger].
@ProviderFor(SelectedBangTrigger)
final selectedBangTriggerProvider =
    NotifierProvider<SelectedBangTrigger, String?>.internal(
  SelectedBangTrigger.new,
  name: r'selectedBangTriggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedBangTriggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedBangTrigger = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
