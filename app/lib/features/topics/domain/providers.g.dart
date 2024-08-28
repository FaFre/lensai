// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedTopicDataHash() => r'fa450784052498014f592c356bde4ff5ec675281';

/// See also [selectedTopicData].
@ProviderFor(selectedTopicData)
final selectedTopicDataProvider =
    AutoDisposeStreamProvider<TopicData?>.internal(
  selectedTopicData,
  name: r'selectedTopicDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTopicDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SelectedTopicDataRef = AutoDisposeStreamProviderRef<TopicData?>;
String _$unusedRandomTopicColorHash() =>
    r'099730b0d987cc37bcae4ef5c999cbebfa67d7da';

/// See also [unusedRandomTopicColor].
@ProviderFor(unusedRandomTopicColor)
final unusedRandomTopicColorProvider =
    AutoDisposeFutureProvider<Color>.internal(
  unusedRandomTopicColor,
  name: r'unusedRandomTopicColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unusedRandomTopicColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnusedRandomTopicColorRef = AutoDisposeFutureProviderRef<Color>;
String _$selectedTopicHash() => r'f4e1c0620971a0b7501ee9aff0d5b41da3130ba0';

/// See also [SelectedTopic].
@ProviderFor(SelectedTopic)
final selectedTopicProvider = NotifierProvider<SelectedTopic, String?>.internal(
  SelectedTopic.new,
  name: r'selectedTopicProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTopicHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedTopic = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
