// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blockContentHostsHash() => r'41855093d8376152244ae37f98e66eea7c74aa32';

/// See also [blockContentHosts].
@ProviderFor(blockContentHosts)
final blockContentHostsProvider = StreamProvider<Set<String>?>.internal(
  blockContentHosts,
  name: r'blockContentHostsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$blockContentHostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BlockContentHostsRef = StreamProviderRef<Set<String>?>;
String _$readerabilityScriptHash() =>
    r'6fdd1aa920bc58c35ef9888158e572e25793870a';

/// See also [readerabilityScript].
@ProviderFor(readerabilityScript)
final readerabilityScriptProvider = FutureProvider<String>.internal(
  readerabilityScript,
  name: r'readerabilityScriptProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$readerabilityScriptHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ReaderabilityScriptRef = FutureProviderRef<String>;
String _$activeTabsHash() => r'd1ef2ae32d8707f7cc0902dd031e8302a63f50d4';

/// See also [activeTabs].
@ProviderFor(activeTabs)
final activeTabsProvider = AutoDisposeProvider<List<String>>.internal(
  activeTabs,
  name: r'activeTabsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeTabsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveTabsRef = AutoDisposeProviderRef<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
