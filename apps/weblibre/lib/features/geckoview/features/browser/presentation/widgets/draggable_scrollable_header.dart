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
import 'package:flutter/material.dart';

class DraggableScrollableHeader extends StatefulWidget {
  final DraggableScrollableController controller;
  final Widget child;

  // Velocity control parameters
  final double velocitySensitivity;
  final double maxVelocity;
  final double minVelocity;
  final Duration animationDuration;
  final Curve animationCurve;
  final double dragSensitivity;

  const DraggableScrollableHeader({
    super.key,
    required this.controller,
    required this.child,
    this.velocitySensitivity = 0.25, // Higher = more sensitive to velocity
    this.maxVelocity = 2500.0, // Maximum velocity to consider
    this.minVelocity = 50.0, // Minimum velocity to trigger momentum
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.decelerate,
    this.dragSensitivity = 1.0, // Controls drag responsiveness
  });

  @override
  State<DraggableScrollableHeader> createState() =>
      _DraggableScrollableHeaderState();
}

class _DraggableScrollableHeaderState extends State<DraggableScrollableHeader> {
  Future<void> _animateToPosition(
    double targetSize, {
    Duration? customDuration,
  }) async {
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.controller.jumpTo(targetSize);
      return;
    }

    await widget.controller.animateTo(
      targetSize,
      duration: customDuration ?? widget.animationDuration,
      curve: widget.animationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Apply drag sensitivity
        final adjustedDelta = details.delta.dy * widget.dragSensitivity;

        widget.controller.jumpTo(
          clampDouble(
            widget.controller.pixelsToSize(
              widget.controller.pixels - adjustedDelta,
            ),
            0.0,
            1.0,
          ),
        );
      },
      onVerticalDragEnd: (details) async {
        final velocity = details.primaryVelocity ?? 0;
        final currentSize = widget.controller.size;

        // Clamp velocity to defined range
        final clampedVelocity = velocity.clamp(
          -widget.maxVelocity,
          widget.maxVelocity,
        );

        // Only apply momentum if velocity exceeds minimum threshold
        if (clampedVelocity.abs() < widget.minVelocity) {
          return; // No momentum, stay at current position
        }

        // Calculate momentum-based target with sensitivity control
        final velocityFactor =
            clampedVelocity / 1000 * widget.velocitySensitivity;
        double targetSize = currentSize - velocityFactor;

        // Clamp to valid range
        targetSize = targetSize.clamp(0.0, 1.0);

        // Calculate animation duration based on velocity (faster velocity = longer animation)
        final velocityRatio = clampedVelocity.abs() / widget.maxVelocity;
        final dynamicDuration = Duration(
          milliseconds:
              (widget.animationDuration.inMilliseconds * (0.5 + velocityRatio))
                  .round(),
        );

        await _animateToPosition(targetSize, customDuration: dynamicDuration);
      },
      child: widget.child,
    );
  }
}
