/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:convert';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/addons/utils/addon_html.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'providers.g.dart';

sealed class AddonUpdateOutcome {
  const AddonUpdateOutcome();
}

class AddonUpdateOutcomeAvailable extends AddonUpdateOutcome {
  final AddonInfo addon;
  final String availableVersion;

  const AddonUpdateOutcomeAvailable({
    required this.addon,
    required this.availableVersion,
  });
}

class AddonUpdateOutcomeUpToDate extends AddonUpdateOutcome {
  const AddonUpdateOutcomeUpToDate();
}

class AddonUpdateOutcomeMissing extends AddonUpdateOutcome {
  const AddonUpdateOutcomeMissing();
}

sealed class AddonUpdateRunResult {
  const AddonUpdateRunResult();
}

class AddonUpdateRunDone extends AddonUpdateRunResult {
  final String? message;

  const AddonUpdateRunDone(this.message);
}

class AddonUpdateRunNoRemoteSource extends AddonUpdateRunResult {
  const AddonUpdateRunNoRemoteSource();
}

class AddonUpdateRunFailed extends AddonUpdateRunResult {
  const AddonUpdateRunFailed();
}

String _resolveAvailableVersion(AddonInfo addon, AddonStoreInfo? storeInfo) {
  final latest = storeInfo?.latestVersion.trim();
  return (latest != null && latest.isNotEmpty) ? latest : addon.version;
}

@Riverpod()
class AddonDetails extends _$AddonDetails {
  GeckoAddonService get _service => ref.read(addonServiceProvider);

  Future<void> _run(Future<AddonInfo?> Function() action) async {
    state = const AsyncLoading<AddonInfo?>();

    final result = await AsyncValue.guard(action);

    if (!ref.mounted) {
      return;
    }

    state = result;

    ref.invalidate(addonListProvider);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> install() async {
    final current = state.value;
    if (current == null) return;

    await _run(() async {
      await _service.installAddon(Uri.parse(current.downloadUrl));
      return _service.getAddonById(addonId);
    });
  }

  Future<void> uninstall() async {
    await _run(() async {
      await _service.uninstallAddon(addonId);
      return null;
    });
  }

  Future<void> setEnabled({required bool enabled}) async {
    await _run(
      () => enabled
          ? _service.enableAddon(addonId)
          : _service.disableAddon(addonId),
    );
  }

  Future<void> setAllowedInPrivateBrowsing({required bool allowed}) async {
    await _run(
      () => _service.setAddonAllowedInPrivateBrowsing(addonId, allowed),
    );
  }

  Future<void> setAutoUpdateEnabled({required bool enabled}) async {
    await _run(
      () => _service.setAddonAutoUpdateEnabledForAddon(addonId, enabled),
    );
  }

  @override
  Future<AddonInfo?> build(String addonId) {
    return _service.getAddonById(addonId);
  }
}

@Riverpod()
Future<AddonStoreInfo?> addonStoreInfo(Ref ref, String addonId) {
  return ref.read(addonServiceProvider).getAddonStoreInfo(addonId);
}

@Riverpod()
Future<List<AddonListing>> featuredAddonListings(Ref ref, AddonStoreApp app) {
  return ref.read(addonServiceProvider).getFeaturedAddonListings(app: app);
}

@Riverpod()
Future<List<AddonListing>> searchAddonListings(
  Ref ref,
  String query,
  AddonStoreApp app,
) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return ref.watch(featuredAddonListingsProvider(app).future);
  }
  return ref
      .read(addonServiceProvider)
      .searchAddonListings(query: trimmed, app: app);
}

@Riverpod(keepAlive: true)
class AddonStoreAppFilter extends _$AddonStoreAppFilter {
  // ignore: use_setters_to_change_properties
  void setApp(AddonStoreApp app) => state = app;

  @override
  AddonStoreApp build() => AddonStoreApp.android;
}

@Riverpod()
Future<String> addonDescriptionMarkdown(Ref ref, String addonId) async {
  final description = await ref.watch(
    addonDetailsProvider(
      addonId,
    ).selectAsync((addon) => addon?.description ?? ''),
  );
  return turndownAddonHtml(description);
}

@Riverpod()
Future<String> addonHtmlMarkdown(Ref ref, String html) {
  return turndownAddonHtml(html);
}

@Riverpod()
Future<AddonUpdateAttemptInfo?> lastAddonUpdateAttempt(
  Ref ref,
  String addonId,
) {
  return ref.read(addonServiceProvider).getLastAddonUpdateAttempt(addonId);
}

@Riverpod()
class AddonUpdateCheck extends _$AddonUpdateCheck {
  /// Refreshes store info and returns whether an update is available.
  Future<AddonUpdateOutcome> resolveAvailableUpdate() async {
    final storeInfo = await ref
        .read(addonServiceProvider)
        .getAddonStoreInfo(addonId);
    final fresh = await ref
        .read(addonServiceProvider)
        .getAddonById(addonId, allowCache: false);

    if (fresh == null) return const AddonUpdateOutcomeMissing();

    final available = _resolveAvailableVersion(fresh, storeInfo);
    final hasUpdate =
        fresh.installedVersion != null &&
        available.isNotEmpty &&
        fresh.installedVersion != available;

    return hasUpdate
        ? AddonUpdateOutcomeAvailable(addon: fresh, availableVersion: available)
        : const AddonUpdateOutcomeUpToDate();
  }

  /// Triggers a remote update and awaits completion. Invalidates dependent
  /// providers on completion.
  Future<AddonUpdateRunResult> triggerAndAwait() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard<AddonUpdateRunResult>(() async {
      final AddonUpdateAttemptInfo? attempt;
      try {
        attempt = await ref
            .read(addonServiceProvider)
            .triggerAddonUpdate(addonId);
      } catch (error) {
        final noRemote = error.toString().contains(
          'No remote update source is available for this locally installed extension.',
        );
        return noRemote
            ? const AddonUpdateRunNoRemoteSource()
            : const AddonUpdateRunFailed();
      }

      return attempt?.status == AddonUpdateStatus.error
          ? const AddonUpdateRunFailed()
          : AddonUpdateRunDone(attempt?.message);
    });

    if (!ref.mounted) {
      return result.value ?? const AddonUpdateRunFailed();
    }

    state = result;
    ref.invalidate(addonDetailsProvider(addonId));
    ref.invalidate(lastAddonUpdateAttemptProvider(addonId));

    return result.value ?? const AddonUpdateRunFailed();
  }

  @override
  AsyncValue<AddonUpdateRunResult> build(String addonId) =>
      const AsyncData(AddonUpdateRunDone(null));
}

@Riverpod()
class AddonList extends _$AddonList {
  GeckoAddonService get _service => ref.read(addonServiceProvider);

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> install(AddonInfo addon) =>
      _install(addon.id, Uri.parse(addon.downloadUrl));

  /// Installs straight from a browse listing, before the add-on exists as an
  /// [AddonInfo].
  ///
  /// Same body as [install] and here rather than in the button that calls it:
  /// an install runs long enough — a network fetch plus a blocking install
  /// prompt — for the user to leave the details screen while it is in flight,
  /// and the busy flag still has to be cleared afterwards. A `WidgetRef` throws
  /// once its widget is gone, so the flag has to be dropped from something that
  /// outlives the screen.
  Future<void> installListing(AddonListing listing) =>
      _install(listing.id, Uri.parse(listing.downloadUrl));

  Future<void> _install(String addonId, Uri downloadUrl) async {
    final busyIds = ref.read(addonBusyIdsProvider.notifier);
    busyIds.add(addonId);

    try {
      await _service.installAddon(downloadUrl);

      if (!ref.mounted) {
        return;
      }

      ref.invalidate(addonDetailsProvider(addonId));
      ref.invalidateSelf();
      await future;
    } finally {
      busyIds.remove(addonId);
    }
  }

  Future<void> uninstall(AddonInfo addon) async {
    final busyIds = ref.read(addonBusyIdsProvider.notifier);
    busyIds.add(addon.id);

    try {
      await _service.uninstallAddon(addon.id);

      if (!ref.mounted) {
        return;
      }

      ref.invalidate(addonDetailsProvider(addon.id));
      ref.invalidateSelf();
      await future;
    } finally {
      busyIds.remove(addon.id);
    }
  }

  @override
  Future<List<AddonInfo>> build() {
    return _service.getAddons();
  }
}

@Riverpod()
class AddonBusyIds extends _$AddonBusyIds {
  void add(String id) {
    if (!ref.mounted) return;
    state = {...state, id};
  }

  void remove(String id) {
    if (!ref.mounted) return;
    state = {...state}..remove(id);
  }

  @override
  Set<String> build() => const {};
}

@Riverpod(keepAlive: true)
class PinnedAddonIds extends _$PinnedAddonIds {
  void setPinned(String addonId, {required bool pinned}) {
    if (pinned) {
      if (!state.contains(addonId)) {
        state = {...state, addonId};
      }
    } else if (state.contains(addonId)) {
      state = {...state}..remove(addonId);
    }
  }

  @override
  Set<String> build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'PinnedAddonIds',
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: (state) => jsonEncode(state.toList()),
      decode: (encoded) =>
          (jsonDecode(encoded) as List<dynamic>).cast<String>().toSet(),
    );

    return stateOrNull ?? const {};
  }
}

@Riverpod()
class BulkAddonUpdate extends _$BulkAddonUpdate {
  Future<void> triggerAll() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref.read(addonServiceProvider).triggerAllAddonUpdates();
    });

    if (!ref.mounted) {
      return;
    }

    state = result;
  }

  @override
  AsyncValue<void> build() => const AsyncData(null);
}
