// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BangSyncRepository)
final bangSyncRepositoryProvider = BangSyncRepositoryProvider._();

final class BangSyncRepositoryProvider
    extends $NotifierProvider<BangSyncRepository, void> {
  BangSyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangSyncRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangSyncRepositoryHash();

  @$internal
  @override
  BangSyncRepository create() => BangSyncRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$bangSyncRepositoryHash() =>
    r'7e508b1c3ff274b165e13652b030fc711eff17c6';

abstract class _$BangSyncRepository extends $Notifier<void> {
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
