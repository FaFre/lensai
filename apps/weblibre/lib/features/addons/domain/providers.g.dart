// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddonDetails)
final addonDetailsProvider = AddonDetailsFamily._();

final class AddonDetailsProvider
    extends $AsyncNotifierProvider<AddonDetails, AddonInfo?> {
  AddonDetailsProvider._({
    required AddonDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonDetailsHash();

  @override
  String toString() {
    return r'addonDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddonDetails create() => AddonDetails();

  @override
  bool operator ==(Object other) {
    return other is AddonDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonDetailsHash() => r'b8b7b0620d618488227fb6b8ba889279b933b707';

final class AddonDetailsFamily extends $Family
    with
        $ClassFamilyOverride<
          AddonDetails,
          AsyncValue<AddonInfo?>,
          AddonInfo?,
          FutureOr<AddonInfo?>,
          String
        > {
  AddonDetailsFamily._()
    : super(
        retry: null,
        name: r'addonDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonDetailsProvider call(String addonId) =>
      AddonDetailsProvider._(argument: addonId, from: this);

  @override
  String toString() => r'addonDetailsProvider';
}

abstract class _$AddonDetails extends $AsyncNotifier<AddonInfo?> {
  late final _$args = ref.$arg as String;
  String get addonId => _$args;

  FutureOr<AddonInfo?> build(String addonId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AddonInfo?>, AddonInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AddonInfo?>, AddonInfo?>,
              AsyncValue<AddonInfo?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(addonStoreInfo)
final addonStoreInfoProvider = AddonStoreInfoFamily._();

final class AddonStoreInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<AddonStoreInfo?>,
          AddonStoreInfo?,
          FutureOr<AddonStoreInfo?>
        >
    with $FutureModifier<AddonStoreInfo?>, $FutureProvider<AddonStoreInfo?> {
  AddonStoreInfoProvider._({
    required AddonStoreInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonStoreInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonStoreInfoHash();

  @override
  String toString() {
    return r'addonStoreInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AddonStoreInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AddonStoreInfo?> create(Ref ref) {
    final argument = this.argument as String;
    return addonStoreInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddonStoreInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonStoreInfoHash() => r'0024a540ecf6f1d55243d9dc963e04fbc212275e';

final class AddonStoreInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AddonStoreInfo?>, String> {
  AddonStoreInfoFamily._()
    : super(
        retry: null,
        name: r'addonStoreInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonStoreInfoProvider call(String addonId) =>
      AddonStoreInfoProvider._(argument: addonId, from: this);

  @override
  String toString() => r'addonStoreInfoProvider';
}

@ProviderFor(featuredAddonListings)
final featuredAddonListingsProvider = FeaturedAddonListingsFamily._();

final class FeaturedAddonListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AddonListing>>,
          List<AddonListing>,
          FutureOr<List<AddonListing>>
        >
    with
        $FutureModifier<List<AddonListing>>,
        $FutureProvider<List<AddonListing>> {
  FeaturedAddonListingsProvider._({
    required FeaturedAddonListingsFamily super.from,
    required AddonStoreApp super.argument,
  }) : super(
         retry: null,
         name: r'featuredAddonListingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$featuredAddonListingsHash();

  @override
  String toString() {
    return r'featuredAddonListingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AddonListing>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AddonListing>> create(Ref ref) {
    final argument = this.argument as AddonStoreApp;
    return featuredAddonListings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeaturedAddonListingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$featuredAddonListingsHash() =>
    r'94f2eb452297611d5b91ac827cb73045cc553826';

final class FeaturedAddonListingsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<AddonListing>>, AddonStoreApp> {
  FeaturedAddonListingsFamily._()
    : super(
        retry: null,
        name: r'featuredAddonListingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeaturedAddonListingsProvider call(AddonStoreApp app) =>
      FeaturedAddonListingsProvider._(argument: app, from: this);

  @override
  String toString() => r'featuredAddonListingsProvider';
}

@ProviderFor(searchAddonListings)
final searchAddonListingsProvider = SearchAddonListingsFamily._();

final class SearchAddonListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AddonListing>>,
          List<AddonListing>,
          FutureOr<List<AddonListing>>
        >
    with
        $FutureModifier<List<AddonListing>>,
        $FutureProvider<List<AddonListing>> {
  SearchAddonListingsProvider._({
    required SearchAddonListingsFamily super.from,
    required (String, AddonStoreApp) super.argument,
  }) : super(
         retry: null,
         name: r'searchAddonListingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchAddonListingsHash();

  @override
  String toString() {
    return r'searchAddonListingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<AddonListing>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AddonListing>> create(Ref ref) {
    final argument = this.argument as (String, AddonStoreApp);
    return searchAddonListings(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchAddonListingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchAddonListingsHash() =>
    r'e20c27fb597093b92f8f4d402f196cc707a3e928';

final class SearchAddonListingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<AddonListing>>,
          (String, AddonStoreApp)
        > {
  SearchAddonListingsFamily._()
    : super(
        retry: null,
        name: r'searchAddonListingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchAddonListingsProvider call(String query, AddonStoreApp app) =>
      SearchAddonListingsProvider._(argument: (query, app), from: this);

  @override
  String toString() => r'searchAddonListingsProvider';
}

@ProviderFor(AddonStoreAppFilter)
final addonStoreAppFilterProvider = AddonStoreAppFilterProvider._();

final class AddonStoreAppFilterProvider
    extends $NotifierProvider<AddonStoreAppFilter, AddonStoreApp> {
  AddonStoreAppFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addonStoreAppFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addonStoreAppFilterHash();

  @$internal
  @override
  AddonStoreAppFilter create() => AddonStoreAppFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddonStoreApp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddonStoreApp>(value),
    );
  }
}

String _$addonStoreAppFilterHash() =>
    r'167303f223c14ce2c118aa5b76342cc3433dc8f0';

abstract class _$AddonStoreAppFilter extends $Notifier<AddonStoreApp> {
  AddonStoreApp build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddonStoreApp, AddonStoreApp>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddonStoreApp, AddonStoreApp>,
              AddonStoreApp,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(addonDescriptionMarkdown)
final addonDescriptionMarkdownProvider = AddonDescriptionMarkdownFamily._();

final class AddonDescriptionMarkdownProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AddonDescriptionMarkdownProvider._({
    required AddonDescriptionMarkdownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonDescriptionMarkdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonDescriptionMarkdownHash();

  @override
  String toString() {
    return r'addonDescriptionMarkdownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return addonDescriptionMarkdown(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddonDescriptionMarkdownProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonDescriptionMarkdownHash() =>
    r'e60659ccef172237e44b9f77b79df4fe11997617';

final class AddonDescriptionMarkdownFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  AddonDescriptionMarkdownFamily._()
    : super(
        retry: null,
        name: r'addonDescriptionMarkdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonDescriptionMarkdownProvider call(String addonId) =>
      AddonDescriptionMarkdownProvider._(argument: addonId, from: this);

  @override
  String toString() => r'addonDescriptionMarkdownProvider';
}

@ProviderFor(addonHtmlMarkdown)
final addonHtmlMarkdownProvider = AddonHtmlMarkdownFamily._();

final class AddonHtmlMarkdownProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AddonHtmlMarkdownProvider._({
    required AddonHtmlMarkdownFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonHtmlMarkdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonHtmlMarkdownHash();

  @override
  String toString() {
    return r'addonHtmlMarkdownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return addonHtmlMarkdown(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddonHtmlMarkdownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonHtmlMarkdownHash() => r'51d6c7d7cf6040acc9540893dacad581606ff4a8';

final class AddonHtmlMarkdownFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  AddonHtmlMarkdownFamily._()
    : super(
        retry: null,
        name: r'addonHtmlMarkdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonHtmlMarkdownProvider call(String html) =>
      AddonHtmlMarkdownProvider._(argument: html, from: this);

  @override
  String toString() => r'addonHtmlMarkdownProvider';
}

@ProviderFor(lastAddonUpdateAttempt)
final lastAddonUpdateAttemptProvider = LastAddonUpdateAttemptFamily._();

final class LastAddonUpdateAttemptProvider
    extends
        $FunctionalProvider<
          AsyncValue<AddonUpdateAttemptInfo?>,
          AddonUpdateAttemptInfo?,
          FutureOr<AddonUpdateAttemptInfo?>
        >
    with
        $FutureModifier<AddonUpdateAttemptInfo?>,
        $FutureProvider<AddonUpdateAttemptInfo?> {
  LastAddonUpdateAttemptProvider._({
    required LastAddonUpdateAttemptFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'lastAddonUpdateAttemptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lastAddonUpdateAttemptHash();

  @override
  String toString() {
    return r'lastAddonUpdateAttemptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AddonUpdateAttemptInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AddonUpdateAttemptInfo?> create(Ref ref) {
    final argument = this.argument as String;
    return lastAddonUpdateAttempt(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LastAddonUpdateAttemptProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastAddonUpdateAttemptHash() =>
    r'79847d9f5720fea1f742d57c3b17272ffd980cc1';

final class LastAddonUpdateAttemptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AddonUpdateAttemptInfo?>, String> {
  LastAddonUpdateAttemptFamily._()
    : super(
        retry: null,
        name: r'lastAddonUpdateAttemptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LastAddonUpdateAttemptProvider call(String addonId) =>
      LastAddonUpdateAttemptProvider._(argument: addonId, from: this);

  @override
  String toString() => r'lastAddonUpdateAttemptProvider';
}

@ProviderFor(AddonUpdateCheck)
final addonUpdateCheckProvider = AddonUpdateCheckFamily._();

final class AddonUpdateCheckProvider
    extends
        $NotifierProvider<AddonUpdateCheck, AsyncValue<AddonUpdateRunResult>> {
  AddonUpdateCheckProvider._({
    required AddonUpdateCheckFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonUpdateCheckProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonUpdateCheckHash();

  @override
  String toString() {
    return r'addonUpdateCheckProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddonUpdateCheck create() => AddonUpdateCheck();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AddonUpdateRunResult> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AddonUpdateRunResult>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddonUpdateCheckProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonUpdateCheckHash() => r'496cf9756101c9c36fa4b90f1fd92627aee92177';

final class AddonUpdateCheckFamily extends $Family
    with
        $ClassFamilyOverride<
          AddonUpdateCheck,
          AsyncValue<AddonUpdateRunResult>,
          AsyncValue<AddonUpdateRunResult>,
          AsyncValue<AddonUpdateRunResult>,
          String
        > {
  AddonUpdateCheckFamily._()
    : super(
        retry: null,
        name: r'addonUpdateCheckProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonUpdateCheckProvider call(String addonId) =>
      AddonUpdateCheckProvider._(argument: addonId, from: this);

  @override
  String toString() => r'addonUpdateCheckProvider';
}

abstract class _$AddonUpdateCheck
    extends $Notifier<AsyncValue<AddonUpdateRunResult>> {
  late final _$args = ref.$arg as String;
  String get addonId => _$args;

  AsyncValue<AddonUpdateRunResult> build(String addonId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AddonUpdateRunResult>,
              AsyncValue<AddonUpdateRunResult>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AddonUpdateRunResult>,
                AsyncValue<AddonUpdateRunResult>
              >,
              AsyncValue<AddonUpdateRunResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(AddonList)
final addonListProvider = AddonListProvider._();

final class AddonListProvider
    extends $AsyncNotifierProvider<AddonList, List<AddonInfo>> {
  AddonListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addonListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addonListHash();

  @$internal
  @override
  AddonList create() => AddonList();
}

String _$addonListHash() => r'96459b04639f15ebee8a1f11807dfcf856c360f6';

abstract class _$AddonList extends $AsyncNotifier<List<AddonInfo>> {
  FutureOr<List<AddonInfo>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<AddonInfo>>, List<AddonInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AddonInfo>>, List<AddonInfo>>,
              AsyncValue<List<AddonInfo>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(AddonBusyIds)
final addonBusyIdsProvider = AddonBusyIdsProvider._();

final class AddonBusyIdsProvider
    extends $NotifierProvider<AddonBusyIds, Set<String>> {
  AddonBusyIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addonBusyIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addonBusyIdsHash();

  @$internal
  @override
  AddonBusyIds create() => AddonBusyIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$addonBusyIdsHash() => r'aac8fd8784ba296129ffdb17c2d1355c1546140f';

abstract class _$AddonBusyIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PinnedAddonIds)
final pinnedAddonIdsProvider = PinnedAddonIdsProvider._();

final class PinnedAddonIdsProvider
    extends $NotifierProvider<PinnedAddonIds, Set<String>> {
  PinnedAddonIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedAddonIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedAddonIdsHash();

  @$internal
  @override
  PinnedAddonIds create() => PinnedAddonIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$pinnedAddonIdsHash() => r'93a3e6944156569eb6eca2bb934c8e94e64484ad';

abstract class _$PinnedAddonIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BulkAddonUpdate)
final bulkAddonUpdateProvider = BulkAddonUpdateProvider._();

final class BulkAddonUpdateProvider
    extends $NotifierProvider<BulkAddonUpdate, AsyncValue<void>> {
  BulkAddonUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bulkAddonUpdateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bulkAddonUpdateHash();

  @$internal
  @override
  BulkAddonUpdate create() => BulkAddonUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$bulkAddonUpdateHash() => r'ec3cdc136c0ad4a6687516bf14912fd5b96b11b4';

abstract class _$BulkAddonUpdate extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
