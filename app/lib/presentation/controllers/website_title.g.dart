// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_title.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pageInfoHash() => r'66800fc7e4863750fc9a3717a25e94ee95ec52a3';

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

/// See also [pageInfo].
@ProviderFor(pageInfo)
const pageInfoProvider = PageInfoFamily();

/// See also [pageInfo].
class PageInfoFamily extends Family<AsyncValue<WebPageInfo>> {
  /// See also [pageInfo].
  const PageInfoFamily();

  /// See also [pageInfo].
  PageInfoProvider call(
    Uri url,
  ) {
    return PageInfoProvider(
      url,
    );
  }

  @override
  PageInfoProvider getProviderOverride(
    covariant PageInfoProvider provider,
  ) {
    return call(
      provider.url,
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
  String? get name => r'pageInfoProvider';
}

/// See also [pageInfo].
class PageInfoProvider extends FutureProvider<WebPageInfo> {
  /// See also [pageInfo].
  PageInfoProvider(
    Uri url,
  ) : this._internal(
          (ref) => pageInfo(
            ref as PageInfoRef,
            url,
          ),
          from: pageInfoProvider,
          name: r'pageInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pageInfoHash,
          dependencies: PageInfoFamily._dependencies,
          allTransitiveDependencies: PageInfoFamily._allTransitiveDependencies,
          url: url,
        );

  PageInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
  }) : super.internal();

  final Uri url;

  @override
  Override overrideWith(
    FutureOr<WebPageInfo> Function(PageInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PageInfoProvider._internal(
        (ref) => create(ref as PageInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
      ),
    );
  }

  @override
  FutureProviderElement<WebPageInfo> createElement() {
    return _PageInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PageInfoProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PageInfoRef on FutureProviderRef<WebPageInfo> {
  /// The parameter `url` of this provider.
  Uri get url;
}

class _PageInfoProviderElement extends FutureProviderElement<WebPageInfo>
    with PageInfoRef {
  _PageInfoProviderElement(super.provider);

  @override
  Uri get url => (origin as PageInfoProvider).url;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
