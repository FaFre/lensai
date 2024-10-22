// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_container.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedContainerDataHash() =>
    r'dc930d1bb47b3c7989c6c119b0459f37d687af84';

/// See also [selectedContainerData].
@ProviderFor(selectedContainerData)
final selectedContainerDataProvider =
    AutoDisposeStreamProvider<ContainerData?>.internal(
  selectedContainerData,
  name: r'selectedContainerDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedContainerDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SelectedContainerDataRef = AutoDisposeStreamProviderRef<ContainerData?>;
String _$selectedContainerHash() => r'e38e86db5bd0584af9561156c26ceaea3d23aebf';

/// See also [SelectedContainer].
@ProviderFor(SelectedContainer)
final selectedContainerProvider =
    NotifierProvider<SelectedContainer, String?>.internal(
  SelectedContainer.new,
  name: r'selectedContainerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedContainerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedContainer = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
