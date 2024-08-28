// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$webViewControllerHash() => r'f35fb13d46fcb04cee5676089f0cb8d5ca21e89b';

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

/// See also [webViewController].
@ProviderFor(webViewController)
const webViewControllerProvider = WebViewControllerFamily();

/// See also [webViewController].
class WebViewControllerFamily extends Family<InAppWebViewController?> {
  /// See also [webViewController].
  const WebViewControllerFamily();

  /// See also [webViewController].
  WebViewControllerProvider call(
    String tabId,
  ) {
    return WebViewControllerProvider(
      tabId,
    );
  }

  @override
  WebViewControllerProvider getProviderOverride(
    covariant WebViewControllerProvider provider,
  ) {
    return call(
      provider.tabId,
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
  String? get name => r'webViewControllerProvider';
}

/// See also [webViewController].
class WebViewControllerProvider
    extends AutoDisposeProvider<InAppWebViewController?> {
  /// See also [webViewController].
  WebViewControllerProvider(
    String tabId,
  ) : this._internal(
          (ref) => webViewController(
            ref as WebViewControllerRef,
            tabId,
          ),
          from: webViewControllerProvider,
          name: r'webViewControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$webViewControllerHash,
          dependencies: WebViewControllerFamily._dependencies,
          allTransitiveDependencies:
              WebViewControllerFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  WebViewControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String tabId;

  @override
  Override overrideWith(
    InAppWebViewController? Function(WebViewControllerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WebViewControllerProvider._internal(
        (ref) => create(ref as WebViewControllerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tabId: tabId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<InAppWebViewController?> createElement() {
    return _WebViewControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebViewControllerProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebViewControllerRef on AutoDisposeProviderRef<InAppWebViewController?> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _WebViewControllerProviderElement
    extends AutoDisposeProviderElement<InAppWebViewController?>
    with WebViewControllerRef {
  _WebViewControllerProviderElement(super.provider);

  @override
  String get tabId => (origin as WebViewControllerProvider).tabId;
}

String _$webViewTabControllerHash() =>
    r'cf1b766aa84472040b56a7b4d9ce1fd1606ed5e1';

/// See also [WebViewTabController].
@ProviderFor(WebViewTabController)
final webViewTabControllerProvider =
    AutoDisposeNotifierProvider<WebViewTabController, String?>.internal(
  WebViewTabController.new,
  name: r'webViewTabControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$webViewTabControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WebViewTabController = AutoDisposeNotifier<String?>;
String _$tabStateHash() => r'9ce6b0d99e5032f534c97482d6140dda4b14fb07';

abstract class _$TabState extends BuildlessAutoDisposeNotifier<WebViewPage?> {
  late final String tabId;

  WebViewPage? build(
    String tabId,
  );
}

/// See also [TabState].
@ProviderFor(TabState)
const tabStateProvider = TabStateFamily();

/// See also [TabState].
class TabStateFamily extends Family<WebViewPage?> {
  /// See also [TabState].
  const TabStateFamily();

  /// See also [TabState].
  TabStateProvider call(
    String tabId,
  ) {
    return TabStateProvider(
      tabId,
    );
  }

  @override
  TabStateProvider getProviderOverride(
    covariant TabStateProvider provider,
  ) {
    return call(
      provider.tabId,
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
  String? get name => r'tabStateProvider';
}

/// See also [TabState].
class TabStateProvider
    extends AutoDisposeNotifierProviderImpl<TabState, WebViewPage?> {
  /// See also [TabState].
  TabStateProvider(
    String tabId,
  ) : this._internal(
          () => TabState()..tabId = tabId,
          from: tabStateProvider,
          name: r'tabStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tabStateHash,
          dependencies: TabStateFamily._dependencies,
          allTransitiveDependencies: TabStateFamily._allTransitiveDependencies,
          tabId: tabId,
        );

  TabStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String tabId;

  @override
  WebViewPage? runNotifierBuild(
    covariant TabState notifier,
  ) {
    return notifier.build(
      tabId,
    );
  }

  @override
  Override overrideWith(TabState Function() create) {
    return ProviderOverride(
      origin: this,
      override: TabStateProvider._internal(
        () => create()..tabId = tabId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tabId: tabId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TabState, WebViewPage?> createElement() {
    return _TabStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabStateProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TabStateRef on AutoDisposeNotifierProviderRef<WebViewPage?> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _TabStateProviderElement
    extends AutoDisposeNotifierProviderElement<TabState, WebViewPage?>
    with TabStateRef {
  _TabStateProviderElement(super.provider);

  @override
  String get tabId => (origin as TabStateProvider).tabId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
