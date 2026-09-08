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
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A [DraggableScrollableSheet] that also answers to a mouse wheel.
///
/// A drop-in replacement: it takes the same arguments and hands the same
/// scroll controller to [builder], and wraps what that builds in a
/// [DraggableSheetPointerScroll] — one listener over the whole sheet, chrome
/// and scrollable alike, which is all it takes now that notches are claimed
/// through the [PointerSignalResolver].
///
/// Prefer this over [DraggableScrollableSheet] everywhere; on a touch-only
/// device it behaves identically.
class PointerScrollableSheet extends HookWidget {
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool expand;
  final bool snap;
  final List<double>? snapSizes;
  final Duration? snapAnimationDuration;
  final DraggableScrollableController? controller;
  final bool shouldCloseOnMinExtent;
  final ScrollableWidgetBuilder builder;

  const PointerScrollableSheet({
    required this.builder,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.expand = true,
    this.snap = false,
    this.snapSizes,
    this.snapAnimationDuration,
    this.controller,
    this.shouldCloseOnMinExtent = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Resizing from a wheel goes through a controller, so a sheet that was
    // never given one still needs it. Hooks cannot be called conditionally, so
    // this is created either way and left unused when a controller was passed.
    final fallbackController = useDraggableScrollableController();
    final sheetController = controller ?? fallbackController;

    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: expand,
      snap: snap,
      snapSizes: snapSizes,
      snapAnimationDuration: snapAnimationDuration,
      shouldCloseOnMinExtent: shouldCloseOnMinExtent,
      builder: (context, scrollController) {
        return DraggableSheetPointerScroll(
          sheetController: sheetController,
          contentController: scrollController,
          child: builder(context, scrollController),
        );
      },
    );
  }
}

/// Gives a [DraggableScrollableSheet] the wheel behaviour it is missing.
///
/// The sheet resizes itself from inside its scroll position's
/// [ScrollPosition.applyUserOffset], which only ever runs for *drags*. A
/// pointer signal — a mouse wheel, or anything else that reports discrete
/// scroll deltas — reaches the scrollable through [ScrollPosition.pointerScroll]
/// instead, which forces the pixels directly and never passes through
/// `applyUserOffset`. So with a mouse the list inside a sheet scrolls, but the
/// sheet itself can never be expanded, collapsed or dismissed, and anything
/// that is not a scrollable (a pinned header, a drag handle) swallows the wheel
/// entirely. See https://github.com/flutter/flutter/issues/104290.
///
/// [PointerScrollableSheet] applies this to a sheet it builds itself, which is
/// the way to reach for it; wrap by hand only around a [DraggableScrollableSheet]
/// built elsewhere.
///
/// One listener over the whole sheet is enough. The notch is claimed
/// through the [PointerSignalResolver], the same way [Scrollable] claims it, so
/// this only ever acts on a notch nothing under the cursor wanted: signals are
/// dispatched innermost-first and the resolver keeps the *first* registrant, and
/// a scrollable registers only when the notch would actually scroll it. That is
/// what keeps a list and the sheet from both travelling on one notch — nested
/// scrollables this widget knows nothing about included.
///
/// [contentController] is the sheet's own scrollable, i.e. the controller handed
/// to [DraggableScrollableSheet.builder]. A notch the sheet cannot use, because
/// it is already at that end of its range, is passed on to it rather than
/// dropped — which is what lets the wheel scroll the list from over a pinned
/// header.
class DraggableSheetPointerScroll extends StatelessWidget {
  final DraggableScrollableController sheetController;
  final ScrollController? contentController;
  final Widget child;

  const DraggableSheetPointerScroll({
    required this.sheetController,
    required this.child,
    this.contentController,
    super.key,
  });

  /// The sheet's scroll position, when there is exactly one to speak of.
  ///
  /// [ScrollController.position] throws while several scrollables share a
  /// controller, which is a normal moment rather than a broken one: the small
  /// web menu cross-fades its panels through an [AnimatedSwitcher], and for the
  /// length of that transition the outgoing and incoming panel are both mounted
  /// on the sheet's controller.
  ScrollPosition? get _contentPosition {
    final positions = contentController?.positions;
    if (positions == null || positions.length != 1) {
      return null;
    }

    return positions.single;
  }

  bool _contentAbsorbs(ScrollPosition position, double delta) {
    return delta > 0
        ? position.pixels < position.maxScrollExtent - precisionErrorTolerance
        : position.pixels > position.minScrollExtent + precisionErrorTolerance;
  }

  /// Resizes the sheet by [delta] pixels, matching what a drag of the same size
  /// does: a notch downwards grows the sheet, upwards shrinks it (and, at the
  /// minimum extent, dismisses it — the sheet's own notification carries that).
  ///
  /// Returns false when the sheet is already at that end of its range, which is
  /// read back from the controller rather than compared against the sheet's min
  /// and max: [DraggableScrollableController.jumpTo] clamps to them internally
  /// and they are not exposed.
  bool _resizeSheet(double delta) {
    final sizeBefore = sheetController.size;
    final target = clampDouble(
      sheetController.pixelsToSize(sheetController.pixels + delta),
      0.0,
      1.0,
    );

    if (target == sizeBefore) {
      return false;
    }

    sheetController.jumpTo(target);

    return sheetController.size != sizeBefore;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        event.scrollDelta.dy == 0.0 ||
        !sheetController.isAttached) {
      return;
    }

    GestureBinding.instance.pointerSignalResolver.register(
      event,
      _applyPointerScroll,
    );
  }

  void _applyPointerScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !sheetController.isAttached) {
      return;
    }

    final position = _contentPosition;
    if (contentController != null && position == null) {
      // Ambiguous, mid-transition. Resizing is off the table too:
      // [DraggableScrollableController.jumpTo] reads the same `position` and
      // would throw, so the notch is dropped until the transition settles.
      return;
    }

    final delta = event.scrollDelta.dy;

    if (_resizeSheet(delta)) {
      return;
    }

    // The sheet has nowhere left to go, so hand the notch to its list rather
    // than dropping it. Only reached from chrome: a list under the cursor would
    // have claimed the notch itself.
    if (position != null && _contentAbsorbs(position, delta)) {
      position.pointerScroll(delta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(onPointerSignal: _handlePointerSignal, child: child);
  }
}
