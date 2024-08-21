// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topicListHash() => r'7220aef5653bb3c2b44b016ce4f083f20896b353';

/// See also [topicList].
@ProviderFor(topicList)
final topicListProvider = AutoDisposeStreamProvider<List<TopicData>>.internal(
  topicList,
  name: r'topicListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$topicListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TopicListRef = AutoDisposeStreamProviderRef<List<TopicData>>;
String _$selectedTopicDataHash() => r'191ad088ab90ef2348a836593f92b48d095afdc8';

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
String _$distinctTopicColorsHash() =>
    r'c671f349615313d3b17e93e9e46fae12889e5e1f';

/// See also [distinctTopicColors].
@ProviderFor(distinctTopicColors)
final distinctTopicColorsProvider =
    AutoDisposeFutureProvider<Set<Color>>.internal(
  distinctTopicColors,
  name: r'distinctTopicColorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$distinctTopicColorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DistinctTopicColorsRef = AutoDisposeFutureProviderRef<Set<Color>>;
String _$unusedRandomTopicColorHash() =>
    r'8f6907bb50a5bf2ac0320e93531d9e61616337b9';

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
