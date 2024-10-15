import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/domain/services/gecko_browser.dart';

class GeckoView extends StatelessWidget {
  final FutureOr<void> Function()? preInitializationStep;

  const GeckoView({super.key, this.preInitializationStep});

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'eu.lensai/gecko',
      surfaceFactory: (
        context,
        controller,
      ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: 'eu.lensai/gecko',
          layoutDirection: TextDirection.ltr,
          creationParams: {},
          creationParamsCodec: const StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener((value) async {
            params.onPlatformViewCreated(value);

            SchedulerBinding.instance.addPostFrameCallback((_) async {
              await preInitializationStep?.call();
              await GeckoBrowserService().showNativeFragment();
            });
          })
          // ignore: discarded_futures
          ..create();
      },
    );
  }
}
