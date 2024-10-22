import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/domain/services/gecko_browser.dart';

class GeckoView extends StatefulWidget {
  final FutureOr<void> Function()? preInitializationStep;

  const GeckoView({super.key, this.preInitializationStep});

  @override
  State<GeckoView> createState() => _GeckoViewState();
}

class _GeckoViewState extends State<GeckoView> {
  static const platform =
      MethodChannel('me.movenext.flutter_mozilla_components/trim_memory');

  final browserService = GeckoBrowserService();

  @override
  void initState() {
    super.initState();
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onTrimMemory') {
        await browserService.onTrimMemory(call.arguments as int);
      }
    });
  }

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
              await widget.preInitializationStep?.call();

              await Future.delayed(
                //Wait for two more frames just to be sure view has been initialized
                Duration(milliseconds: ((1000 / 60) * 2).toInt()),
              ).whenComplete(() async {
                await browserService.showNativeFragment();
              });
            });
          })
          // ignore: discarded_futures
          ..create();
      },
    );
  }
}
