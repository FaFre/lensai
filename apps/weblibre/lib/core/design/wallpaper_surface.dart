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
import 'package:flutter/material.dart';

/// Fills for surfaces painted directly onto the home wallpaper.
///
/// Translucency marks what touches the wallpaper, and nothing else. It is
/// applied to the outermost surface of a group only: whatever sits inside one
/// of these reads against it rather than against the image, so a second alpha
/// nested in the first only muddies both. Chips carrying a container's identity
/// color and any control that should read as solid stay opaque for the same
/// reason — alpha shifts a color against whatever happens to be behind it.
///
/// Two levels, and the split is by text density rather than by importance. The
/// small, densely typeset surface is the one that needs the quieter backdrop.
extension WallpaperSurfaceFill on Color {
  /// Broad containers: a module card, a banner. Little type per unit of area,
  /// so they can let more of the image through.
  Color get wallpaperBroad => withValues(alpha: 0.9);

  /// Small, text-dense cells: a shortcut tile. These carry the smallest type on
  /// the surface, directly over the image, so they get the more opaque fill.
  Color get wallpaperDense => withValues(alpha: 0.7);
}

extension WallpaperSurfaceOutline on ColorScheme {
  /// Hairline edge that belongs with every one of those fills. Over a
  /// photograph an edge holds the boundary of a surface far better than the
  /// fill does. A surface with a branded outline of its own substitutes that.
  Color get wallpaperOutline => outlineVariant.withValues(alpha: 0.4);
}
