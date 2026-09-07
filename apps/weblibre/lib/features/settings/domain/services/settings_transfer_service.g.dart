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
/// What it adds on top is everything that follows from the file being
/// *readable* and portable, which sync's encrypted per-user blobs are not:
/// credentials and profile-local references are scrubbed on the way out and
/// taken from the device on the way in, and a file that did not come from here
/// is refused before any of it is applied.
///
/// A caveat the UI has to keep saying out loud: these are the same units sync
/// moves, so settings persisted outside those repositories — search language
/// and region, home and new-tab module order, menu layout — are not carried by
/// either path. Adding them belongs in `SettingsSyncPayload`, so that sync and
/// this gain them together.

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
/// What it adds on top is everything that follows from the file being
/// *readable* and portable, which sync's encrypted per-user blobs are not:
/// credentials and profile-local references are scrubbed on the way out and
/// taken from the device on the way in, and a file that did not come from here
/// is refused before any of it is applied.
///
/// A caveat the UI has to keep saying out loud: these are the same units sync
/// moves, so settings persisted outside those repositories — search language
/// and region, home and new-tab module order, menu layout — are not carried by
/// either path. Adding them belongs in `SettingsSyncPayload`, so that sync and
/// this gain them together.
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
  /// What it adds on top is everything that follows from the file being
  /// *readable* and portable, which sync's encrypted per-user blobs are not:
  /// credentials and profile-local references are scrubbed on the way out and
  /// taken from the device on the way in, and a file that did not come from here
  /// is refused before any of it is applied.
  ///
  /// A caveat the UI has to keep saying out loud: these are the same units sync
  /// moves, so settings persisted outside those repositories — search language
  /// and region, home and new-tab module order, menu layout — are not carried by
  /// either path. Adding them belongs in `SettingsSyncPayload`, so that sync and
  /// this gain them together.
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
    r'ebb8e84f06a95fabd7a2b31557201962fbe57cad';

/// Reads and writes settings as a plain file, next to — and independent of —
/// account sync.
///
/// Everything that knows how to turn settings into bytes and back already
/// exists as [SyncDocumentService] implementations; sync just happens to send
/// those bytes to a server. This does the same two calls with a file or the
/// clipboard on the other end, so the two paths cannot drift apart in what
/// they consider a setting.
///
/// What it adds on top is everything that follows from the file being
/// *readable* and portable, which sync's encrypted per-user blobs are not:
/// credentials and profile-local references are scrubbed on the way out and
/// taken from the device on the way in, and a file that did not come from here
/// is refused before any of it is applied.
///
/// A caveat the UI has to keep saying out loud: these are the same units sync
/// moves, so settings persisted outside those repositories — search language
/// and region, home and new-tab module order, menu layout — are not carried by
/// either path. Adding them belongs in `SettingsSyncPayload`, so that sync and
/// this gain them together.

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
