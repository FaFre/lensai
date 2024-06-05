// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_archive.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readArchivedChatHash() => r'e7d646a0ea22fe24d96e97f86c1d46fe83818508';

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

/// See also [readArchivedChat].
@ProviderFor(readArchivedChat)
const readArchivedChatProvider = ReadArchivedChatFamily();

/// See also [readArchivedChat].
class ReadArchivedChatFamily extends Family<AsyncValue<String>> {
  /// See also [readArchivedChat].
  const ReadArchivedChatFamily();

  /// See also [readArchivedChat].
  ReadArchivedChatProvider call(
    String fileName,
  ) {
    return ReadArchivedChatProvider(
      fileName,
    );
  }

  @override
  ReadArchivedChatProvider getProviderOverride(
    covariant ReadArchivedChatProvider provider,
  ) {
    return call(
      provider.fileName,
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
  String? get name => r'readArchivedChatProvider';
}

/// See also [readArchivedChat].
class ReadArchivedChatProvider extends AutoDisposeFutureProvider<String> {
  /// See also [readArchivedChat].
  ReadArchivedChatProvider(
    String fileName,
  ) : this._internal(
          (ref) => readArchivedChat(
            ref as ReadArchivedChatRef,
            fileName,
          ),
          from: readArchivedChatProvider,
          name: r'readArchivedChatProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$readArchivedChatHash,
          dependencies: ReadArchivedChatFamily._dependencies,
          allTransitiveDependencies:
              ReadArchivedChatFamily._allTransitiveDependencies,
          fileName: fileName,
        );

  ReadArchivedChatProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fileName,
  }) : super.internal();

  final String fileName;

  @override
  Override overrideWith(
    FutureOr<String> Function(ReadArchivedChatRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReadArchivedChatProvider._internal(
        (ref) => create(ref as ReadArchivedChatRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fileName: fileName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _ReadArchivedChatProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadArchivedChatProvider && other.fileName == fileName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fileName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReadArchivedChatRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `fileName` of this provider.
  String get fileName;
}

class _ReadArchivedChatProviderElement
    extends AutoDisposeFutureProviderElement<String> with ReadArchivedChatRef {
  _ReadArchivedChatProviderElement(super.provider);

  @override
  String get fileName => (origin as ReadArchivedChatProvider).fileName;
}

String _$chatArchiveRepositoryHash() =>
    r'c53b0d2704953a205c12357642237e15e8ffd3b1';

/// See also [ChatArchiveRepository].
@ProviderFor(ChatArchiveRepository)
final chatArchiveRepositoryProvider = AutoDisposeStreamNotifierProvider<
    ChatArchiveRepository, List<ChatEntity>>.internal(
  ChatArchiveRepository.new,
  name: r'chatArchiveRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatArchiveRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatArchiveRepository = AutoDisposeStreamNotifier<List<ChatEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
