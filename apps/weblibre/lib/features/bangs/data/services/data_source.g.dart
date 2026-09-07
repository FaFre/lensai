// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BangDataSourceService)
final bangDataSourceServiceProvider = BangDataSourceServiceProvider._();

final class BangDataSourceServiceProvider
    extends $NotifierProvider<BangDataSourceService, void> {
  BangDataSourceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangDataSourceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangDataSourceServiceHash();

  @$internal
  @override
  BangDataSourceService create() => BangDataSourceService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$bangDataSourceServiceHash() =>
    r'ffc06aadd30c7ed7a89f245379266b9a5952f198';

abstract class _$BangDataSourceService extends $Notifier<void> {
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
