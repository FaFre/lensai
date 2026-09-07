// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(quotesDatabase)
final quotesDatabaseProvider = QuotesDatabaseProvider._();

final class QuotesDatabaseProvider
    extends $FunctionalProvider<QuotesDatabase, QuotesDatabase, QuotesDatabase>
    with $Provider<QuotesDatabase> {
  QuotesDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quotesDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quotesDatabaseHash();

  @$internal
  @override
  $ProviderElement<QuotesDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuotesDatabase create(Ref ref) {
    return quotesDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuotesDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuotesDatabase>(value),
    );
  }
}

String _$quotesDatabaseHash() => r'4773a1597e0a68508bcb21a0f44db4b7c989d688';
