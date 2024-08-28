// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabRepositoryHash() => r'454e182a99910512be72279f68caa0af125ed165';

/// See also [TabRepository].
@ProviderFor(TabRepository)
final tabRepositoryProvider =
    StreamNotifierProvider<TabRepository, List<TabData>>.internal(
  TabRepository.new,
  name: r'tabRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tabRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TabRepository = StreamNotifier<List<TabData>>;
String _$topicTabRepositoryHash() =>
    r'52ceb013e0b31046fdd0a00d031392ba84b9ecda';

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

abstract class _$TopicTabRepository
    extends BuildlessAutoDisposeStreamNotifier<List<String>> {
  late final String? topicId;

  Stream<List<String>> build(
    String? topicId,
  );
}

/// See also [TopicTabRepository].
@ProviderFor(TopicTabRepository)
const topicTabRepositoryProvider = TopicTabRepositoryFamily();

/// See also [TopicTabRepository].
class TopicTabRepositoryFamily extends Family<AsyncValue<List<String>>> {
  /// See also [TopicTabRepository].
  const TopicTabRepositoryFamily();

  /// See also [TopicTabRepository].
  TopicTabRepositoryProvider call(
    String? topicId,
  ) {
    return TopicTabRepositoryProvider(
      topicId,
    );
  }

  @override
  TopicTabRepositoryProvider getProviderOverride(
    covariant TopicTabRepositoryProvider provider,
  ) {
    return call(
      provider.topicId,
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
  String? get name => r'topicTabRepositoryProvider';
}

/// See also [TopicTabRepository].
class TopicTabRepositoryProvider extends AutoDisposeStreamNotifierProviderImpl<
    TopicTabRepository, List<String>> {
  /// See also [TopicTabRepository].
  TopicTabRepositoryProvider(
    String? topicId,
  ) : this._internal(
          () => TopicTabRepository()..topicId = topicId,
          from: topicTabRepositoryProvider,
          name: r'topicTabRepositoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$topicTabRepositoryHash,
          dependencies: TopicTabRepositoryFamily._dependencies,
          allTransitiveDependencies:
              TopicTabRepositoryFamily._allTransitiveDependencies,
          topicId: topicId,
        );

  TopicTabRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topicId,
  }) : super.internal();

  final String? topicId;

  @override
  Stream<List<String>> runNotifierBuild(
    covariant TopicTabRepository notifier,
  ) {
    return notifier.build(
      topicId,
    );
  }

  @override
  Override overrideWith(TopicTabRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: TopicTabRepositoryProvider._internal(
        () => create()..topicId = topicId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topicId: topicId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<TopicTabRepository, List<String>>
      createElement() {
    return _TopicTabRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicTabRepositoryProvider && other.topicId == topicId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topicId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TopicTabRepositoryRef
    on AutoDisposeStreamNotifierProviderRef<List<String>> {
  /// The parameter `topicId` of this provider.
  String? get topicId;
}

class _TopicTabRepositoryProviderElement
    extends AutoDisposeStreamNotifierProviderElement<TopicTabRepository,
        List<String>> with TopicTabRepositoryRef {
  _TopicTabRepositoryProviderElement(super.provider);

  @override
  String? get topicId => (origin as TopicTabRepositoryProvider).topicId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
