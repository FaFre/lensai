// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngineSettingsRepository)
final engineSettingsRepositoryProvider = EngineSettingsRepositoryProvider._();

final class EngineSettingsRepositoryProvider
    extends $StreamNotifierProvider<EngineSettingsRepository, EngineSettings> {
  EngineSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineSettingsRepositoryHash();

  @$internal
  @override
  EngineSettingsRepository create() => EngineSettingsRepository();
}

String _$engineSettingsRepositoryHash() =>
    r'd6d1677df7f949ca5721d7d17433e40cb0032ac4';

abstract class _$EngineSettingsRepository
    extends $StreamNotifier<EngineSettings> {
  Stream<EngineSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EngineSettings>, EngineSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EngineSettings>, EngineSettings>,
              AsyncValue<EngineSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Kept alive like its `generalSettingsWithDefaults` counterpart: it is
/// a pure projection of the keep-alive repository, so caching it costs a single
/// derived value and lets keep-alive consumers read it without pinning an
/// auto-disposed provider.

@ProviderFor(engineSettingsWithDefaults)
final engineSettingsWithDefaultsProvider =
    EngineSettingsWithDefaultsProvider._();

/// Kept alive like its `generalSettingsWithDefaults` counterpart: it is
/// a pure projection of the keep-alive repository, so caching it costs a single
/// derived value and lets keep-alive consumers read it without pinning an
/// auto-disposed provider.

final class EngineSettingsWithDefaultsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// Kept alive like its `generalSettingsWithDefaults` counterpart: it is
  /// a pure projection of the keep-alive repository, so caching it costs a single
  /// derived value and lets keep-alive consumers read it without pinning an
  /// auto-disposed provider.
  EngineSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<EngineSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngineSettings create(Ref ref) {
    return engineSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineSettings>(value),
    );
  }
}

String _$engineSettingsWithDefaultsHash() =>
    r'bbaa2384ccb02a46e85c8cf787337f6b7490f8b9';
