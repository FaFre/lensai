// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sitesDatabase)
final sitesDatabaseProvider = SitesDatabaseProvider._();

final class SitesDatabaseProvider
    extends $FunctionalProvider<SitesDatabase, SitesDatabase, SitesDatabase>
    with $Provider<SitesDatabase> {
  SitesDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sitesDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sitesDatabaseHash();

  @$internal
  @override
  $ProviderElement<SitesDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SitesDatabase create(Ref ref) {
    return sitesDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SitesDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SitesDatabase>(value),
    );
  }
}

String _$sitesDatabaseHash() => r'd7ea16dc1ff3778d4584a6049c4ee83008747136';
