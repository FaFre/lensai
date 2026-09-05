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
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'settings_export_directory.g.dart';

/// Where settings exports are written, remembered so the folder is picked once.
///
/// Deliberately not the profile backup folder: that one is a setting the user
/// chose for encrypted archives, and a settings export picking a one-off folder
/// would silently redirect the next backup with it.
@Riverpod(keepAlive: true)
class SettingsExportDirectoryUri extends _$SettingsExportDirectoryUri {
  // ignore: use_setters_to_change_properties
  void set(Uri? value) => state = value;

  @override
  Uri? build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'SettingsExportDirectoryUri',
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: (state) => state?.toString() ?? '',
      decode: (encoded) => encoded.isEmpty ? null : Uri.parse(encoded),
    );

    return stateOrNull;
  }
}
