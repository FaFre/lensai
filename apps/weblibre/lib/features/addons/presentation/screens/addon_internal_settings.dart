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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/features/addons/extensions/addon_info.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

Future<void> openAddonSettingsFlow(
  BuildContext context,
  WidgetRef ref,
  AddonInfo addon,
) async {
  if (!addon.hasOptionsPage) {
    await const AddonManagerRoute().push<void>(context);
    return;
  }

  if (addon.openOptionsPageInTab) {
    final optionsPageUrl = addon.optionsPageUrl;
    if (optionsPageUrl == null || optionsPageUrl.isEmpty) {
      return;
    }

    await GeckoTabService().selectOrAddTabByUrl(
      url: Uri.parse(optionsPageUrl),
      ignoreFragment: true,
    );

    if (context.mounted) {
      const BrowserRoute().go(context);
    }
    return;
  }

  await AddonInternalSettingsRoute(addonId: addon.id).push<void>(context);
}

Future<void> openAddonSettingsFlowById(
  BuildContext context,
  WidgetRef ref,
  String addonId,
) async {
  final addon = await ref.read(addonServiceProvider).getAddonById(addonId);
  if (addon == null) {
    if (!context.mounted) return;

    await const AddonManagerRoute().push<void>(context);
    return;
  }

  if (!context.mounted) return;

  await openAddonSettingsFlow(context, ref, addon);
}

class AddonInternalSettingsScreen extends ConsumerWidget {
  final String addonId;

  const AddonInternalSettingsScreen({required this.addonId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonAsync = ref.watch(addonDetailsProvider(addonId));

    final addon = addonAsync.value;
    final optionsPageUrl = addon?.optionsPageUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          addon == null
              ? 'Extension Settings'
              : '${addon.displayName} Settings',
        ),
      ),
      body: switch (addonAsync) {
        AsyncLoading() when addon == null => const Center(
          child: CircularProgressIndicator(),
        ),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load extension settings: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _
            when addon == null ||
                optionsPageUrl == null ||
                optionsPageUrl.isEmpty =>
          const Center(
            child: Text('This extension does not expose a settings page.'),
          ),
        _ => _AddonSettingsPlatformView(optionsPageUrl: optionsPageUrl),
      },
    );
  }
}

class _AddonSettingsPlatformView extends StatelessWidget {
  final String optionsPageUrl;

  const _AddonSettingsPlatformView({required this.optionsPageUrl});

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'eu.weblibre/addon_settings',
      surfaceFactory: (context, controller) =>
          PointerInputSurface(controller: controller),
      onCreatePlatformView: (params) {
        final controller = PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: 'eu.weblibre/addon_settings',
          layoutDirection: TextDirection.ltr,
          creationParams: <String, Object?>{'optionsPageUrl': optionsPageUrl},
          creationParamsCodec: const StandardMessageCodec(),
        );
        controller.addOnPlatformViewCreatedListener(
          params.onPlatformViewCreated,
        );
        unawaited(controller.create());
        return controller;
      },
    );
  }
}
