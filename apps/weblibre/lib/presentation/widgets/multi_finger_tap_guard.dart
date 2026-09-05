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
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// How many fingers landing together make a sequence a multi-finger tap.
const _minPointers = 3;

/// How close together those fingers have to land.
///
/// Long enough to cover the spread of a deliberate three-finger tap, short
/// enough that a finger *added* to a gesture already under way — a third finger
/// resting on the screen during a two-finger tray gesture, say — is left alone.
const _landingWindow = Duration(milliseconds: 200);

/// Cancels touch sequences in which three or more fingers land at once.
///
/// Flutter's drag recognizers accumulate travel from *every* pointer they are
/// tracking until one of them is accepted: [DragGestureRecognizer] only starts
/// following a single pointer once `_activePointer` is set, which happens in
/// `acceptGesture`. Before that, the few pixels each finger rolls as it lands
/// are summed, and three fingers reach the ~8px Android touch slop between
/// them without any one of them having moved meaningfully. The drag is
/// accepted, the fingers lift a moment later, and the velocity tracker turns
/// that jitter into a fling — a list scrolls, or a tab is swiped away, from
/// what the user did as a three-finger *tap* (the system screenshot gesture on
/// many devices). See https://github.com/FaFre/WebLibre/issues/458.
///
/// Cancelling the pointers as the third one lands gets in ahead of that: the
/// recognizers give the pointers up before the summed slop is reached, so the
/// sequence ends in `_checkCancel` with no scroll and no fling. Later events
/// for those pointers are dropped by [GestureBinding], which has already
/// forgotten their hit-test path.
///
/// This watches a global pointer route rather than joining the gesture arena.
/// An arena member would be a second one on every pointer that lands on the
/// browser's platform view, and the platform view relies on being the *only*
/// member there: an arena with one member resolves as soon as it closes, while
/// one with two waits for a sweep at pointer-up — which would hold back every
/// touch on a web page until the finger lifted.
class MultiFingerTapGuard extends HookWidget {
  final Widget child;

  const MultiFingerTapGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final guard = _MultiFingerTapCanceller();
      final router = GestureBinding.instance.pointerRouter
        ..addGlobalRoute(guard.handleEvent);

      return () => router.removeGlobalRoute(guard.handleEvent);
    }, const []);

    return child;
  }
}

class _MultiFingerTapCanceller {
  /// Pointers currently down, and when each landed.
  final Map<int, Duration> _downSince = <int, Duration>{};

  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _downSince[event.pointer] = event.timeStamp;

      if (_downSince.length < _minPointers) {
        return;
      }

      final firstLanded = _downSince.values.reduce((a, b) => a < b ? a : b);
      if (event.timeStamp - firstLanded > _landingWindow) {
        return;
      }

      // The cancels come back through this route and clear the map.
      for (final pointer in _downSince.keys.toList()) {
        GestureBinding.instance.cancelPointer(pointer);
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _downSince.remove(event.pointer);
    }
  }
}
