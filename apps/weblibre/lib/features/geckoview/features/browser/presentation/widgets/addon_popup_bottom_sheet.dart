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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

const _viewType = 'eu.weblibre/addon_popup';

Future<void> showAddonPopupBottomSheet(
  BuildContext context, {
  required String extensionId,
  required String extensionName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _AddonPopupSheet(
      extensionId: extensionId,
      extensionName: extensionName,
    ),
  );
}

class _AddonPopupSheet extends StatelessWidget {
  final String extensionId;
  final String extensionName;

  const _AddonPopupSheet({
    required this.extensionId,
    required this.extensionName,
  });

  @override
  Widget build(BuildContext context) {
    return PointerScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SheetDragHandle(),
            const Divider(height: 1),
            Expanded(child: _AddonPopupPlatformView(extensionId: extensionId)),
          ],
        );
      },
    );
  }
}

class _AddonPopupPlatformView extends StatelessWidget {
  final String extensionId;

  const _AddonPopupPlatformView({required this.extensionId});

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: _viewType,
      surfaceFactory: (context, controller) => PointerInputSurface(
        controller: controller,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
      onCreatePlatformView: (params) {
        final controller = PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: <String, Object?>{'extensionId': extensionId},
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
