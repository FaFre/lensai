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
import 'dart:io';
import 'dart:math' as math;

import 'package:fast_equatable/fast_equatable.dart';

/// Home wallpaper blur, as a gaussian sigma in logical pixels.
///
/// A photograph stops being recognisable somewhere around 6, so a range much
/// wider than this is all the same picture: an even smear. What is left above
/// that is there for the "abstract wash of colour" look, not for a stronger
/// version of a legible wallpaper.
const maxHomeWallpaperBlur = 12.0;

/// How far the wallpaper may be pulled toward the theme's surface colour.
/// Capped below 1 so the setting can never hide the image completely — that is
/// what removing the wallpaper is for.
const maxHomeWallpaperDim = 0.85;

/// Steps in each treatment slider's travel.
const homeWallpaperSliderDivisions = 20;

/// Slider travel (0 to 1) to blur sigma, and back.
///
/// Squared, because the interesting half of the range is the bottom of it: the
/// difference between sigma 0.5 and 2 is the difference between a sharp
/// wallpaper and a softened one, while everything past 6 is the same smear. A
/// linear slider spent three quarters of its travel on that smear and gave the
/// useful part four notches. This gives half the travel to sigma 0–3.
double homeWallpaperBlurFromSlider(double travel) =>
    maxHomeWallpaperBlur * math.pow(travel.clamp(0.0, 1.0), 2).toDouble();

double homeWallpaperBlurToSlider(double blur) =>
    math.sqrt((blur / maxHomeWallpaperBlur).clamp(0.0, 1.0));

/// Enough of a scrim that theme-coloured text over an arbitrary photo stays
/// legible out of the box, without washing the image out.
const defaultHomeWallpaperDim = 0.35;

/// A wallpaper resolved down to what it takes to draw it: which file, and the
/// treatment that applies to it here.
///
/// Produced by `resolvedHomeWallpaperProvider`, which is what decides whether
/// the selected container's own wallpaper or the profile-wide one wins. Nothing
/// downstream of that needs to know which of the two it got.
class HomeWallpaper with FastEquatable {
  // Compared by `file.path` in `hashParameters`: `File` has identity equality,
  // so two handles on the same wallpaper would otherwise never match.
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  final File file;

  /// Gaussian sigma in logical pixels; 0 means no blur.
  final double blur;

  /// How far the image is pulled toward the theme's surface colour, 0 to
  /// [maxHomeWallpaperDim].
  final double dim;

  HomeWallpaper({required this.file, required this.blur, required this.dim});

  @override
  List<Object?> get hashParameters => [file.path, blur, dim];
}
