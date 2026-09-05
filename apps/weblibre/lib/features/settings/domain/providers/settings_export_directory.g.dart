// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_export_directory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where settings exports are written, remembered so the folder is picked once.
///
/// Deliberately not the profile backup folder: that one is a setting the user
/// chose for encrypted archives, and a settings export picking a one-off folder
/// would silently redirect the next backup with it.

@ProviderFor(SettingsExportDirectoryUri)
final settingsExportDirectoryUriProvider =
    SettingsExportDirectoryUriProvider._();

/// Where settings exports are written, remembered so the folder is picked once.
///
/// Deliberately not the profile backup folder: that one is a setting the user
/// chose for encrypted archives, and a settings export picking a one-off folder
/// would silently redirect the next backup with it.
final class SettingsExportDirectoryUriProvider
    extends $NotifierProvider<SettingsExportDirectoryUri, Uri?> {
  /// Where settings exports are written, remembered so the folder is picked once.
  ///
  /// Deliberately not the profile backup folder: that one is a setting the user
  /// chose for encrypted archives, and a settings export picking a one-off folder
  /// would silently redirect the next backup with it.
  SettingsExportDirectoryUriProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsExportDirectoryUriProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsExportDirectoryUriHash();

  @$internal
  @override
  SettingsExportDirectoryUri create() => SettingsExportDirectoryUri();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }
}

String _$settingsExportDirectoryUriHash() =>
    r'a819764c0bd230ec6417625a0c62b7743e2cd268';

/// Where settings exports are written, remembered so the folder is picked once.
///
/// Deliberately not the profile backup folder: that one is a setting the user
/// chose for encrypted archives, and a settings export picking a one-off folder
/// would silently redirect the next backup with it.

abstract class _$SettingsExportDirectoryUri extends $Notifier<Uri?> {
  Uri? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Uri?, Uri?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Uri?, Uri?>,
              Uri?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
