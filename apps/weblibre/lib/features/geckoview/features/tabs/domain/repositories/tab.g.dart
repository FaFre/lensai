// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabDataRepository)
final tabDataRepositoryProvider = TabDataRepositoryProvider._();

final class TabDataRepositoryProvider
    extends $NotifierProvider<TabDataRepository, void> {
  TabDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabDataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabDataRepositoryHash();

  @$internal
  @override
  TabDataRepository create() => TabDataRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tabDataRepositoryHash() => r'7d6cf0c65c3f47b7448c6217317c7ef664d7e57a';

abstract class _$TabDataRepository extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
