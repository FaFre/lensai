// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_token_issuance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchTokenIssuanceController)
final searchTokenIssuanceControllerProvider =
    SearchTokenIssuanceControllerProvider._();

final class SearchTokenIssuanceControllerProvider
    extends
        $NotifierProvider<
          SearchTokenIssuanceController,
          SearchTokenIssuanceState
        > {
  SearchTokenIssuanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchTokenIssuanceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchTokenIssuanceControllerHash();

  @$internal
  @override
  SearchTokenIssuanceController create() => SearchTokenIssuanceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchTokenIssuanceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchTokenIssuanceState>(value),
    );
  }
}

String _$searchTokenIssuanceControllerHash() =>
    r'4ec1b90ba827e555f0bac509af0e4d395b8e47c5';

abstract class _$SearchTokenIssuanceController
    extends $Notifier<SearchTokenIssuanceState> {
  SearchTokenIssuanceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SearchTokenIssuanceState, SearchTokenIssuanceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchTokenIssuanceState, SearchTokenIssuanceState>,
              SearchTokenIssuanceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(searchTokenAvailability)
final searchTokenAvailabilityProvider = SearchTokenAvailabilityProvider._();

final class SearchTokenAvailabilityProvider
    extends
        $FunctionalProvider<
          SearchTokenAvailability,
          SearchTokenAvailability,
          SearchTokenAvailability
        >
    with $Provider<SearchTokenAvailability> {
  SearchTokenAvailabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchTokenAvailabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchTokenAvailabilityHash();

  @$internal
  @override
  $ProviderElement<SearchTokenAvailability> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchTokenAvailability create(Ref ref) {
    return searchTokenAvailability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchTokenAvailability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchTokenAvailability>(value),
    );
  }
}

String _$searchTokenAvailabilityHash() =>
    r'4125c2f267684ee6adcd7a174a3d1570a01643a6';
