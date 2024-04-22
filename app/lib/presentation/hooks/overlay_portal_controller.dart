import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

OverlayPortalController useOverlayPortalController() {
  return use(const _OverlayPortalControllerHook());
}

class _OverlayPortalControllerHook extends Hook<OverlayPortalController> {
  const _OverlayPortalControllerHook();

  @override
  HookState<OverlayPortalController, Hook<OverlayPortalController>>
      createState() {
    return _OverlayPortalControllerHookState();
  }
}

class _OverlayPortalControllerHookState
    extends HookState<OverlayPortalController, _OverlayPortalControllerHook> {
  late final controller = OverlayPortalController();

  @override
  OverlayPortalController build(BuildContext context) => controller;

  @override
  String get debugLabel => 'useOverlayPortalController';
}
