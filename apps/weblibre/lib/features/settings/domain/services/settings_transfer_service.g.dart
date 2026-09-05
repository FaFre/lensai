// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_transfer_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads and writes settings as a plain file, next to — and independent of —
/// account sync.
///
/// Everything that knows how to turn settings into bytes and back already
/// exists as [SyncDocumentService] implementations; sync just happens to send
/// those bytes to a server. This does the same two calls with a file or the
/// clipboard on the other end, so the two paths cannot drift apart in what
/// they consider a setting.
///
/// The one thing it adds is redaction, which sync does not need: sync's
/// documents are encrypted with a key only the user's devices hold, while
/// these are written to be read.

@ProviderFor(SettingsTransferService)
final settingsTransferServiceProvider = SettingsTransferServiceProvider._();

/// Reads and writes settings as a plain file, next to — and independent of —
/// account sync.
///
/// Everything that knows how to turn settings into bytes and back already
/// exists as [SyncDocumentService] implementations; sync just happens to send
/// those bytes to a server. This does the same two calls with a file or the
/// clipboard on the other end, so the two paths cannot drift apart in what
/// they consider a setting.
///
/// The one thing it adds is redaction, which sync does not need: sync's
/// documents are encrypted with a key only the user's devices hold, while
/// these are written to be read.
final class SettingsTransferServiceProvider
    extends $NotifierProvider<SettingsTransferService, void> {
  /// Reads and writes settings as a plain file, next to — and independent of —
  /// account sync.
  ///
  /// Everything that knows how to turn settings into bytes and back already
  /// exists as [SyncDocumentService] implementations; sync just happens to send
  /// those bytes to a server. This does the same two calls with a file or the
  /// clipboard on the other end, so the two paths cannot drift apart in what
  /// they consider a setting.
  ///
  /// The one thing it adds is redaction, which sync does not need: sync's
  /// documents are encrypted with a key only the user's devices hold, while
  /// these are written to be read.
  SettingsTransferServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsTransferServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsTransferServiceHash();

  @$internal
  @override
  SettingsTransferService create() => SettingsTransferService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$settingsTransferServiceHash() =>
    r'cb4eac1f14b6a834171e5b951e14c94f3bd9eca1';

/// Reads and writes settings as a plain file, next to — and independent of —
/// account sync.
///
/// Everything that knows how to turn settings into bytes and back already
/// exists as [SyncDocumentService] implementations; sync just happens to send
/// those bytes to a server. This does the same two calls with a file or the
/// clipboard on the other end, so the two paths cannot drift apart in what
/// they consider a setting.
///
/// The one thing it adds is redaction, which sync does not need: sync's
/// documents are encrypted with a key only the user's devices hold, while
/// these are written to be read.

abstract class _$SettingsTransferService extends $Notifier<void> {
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
