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
import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';

part 'data_source.g.dart';

@Riverpod(keepAlive: true)
class BangDataSourceService extends _$BangDataSourceService {
  @override
  void build() {}

  Future<Result<List<Bang>>> fetchRemoteBangs(Uri url, BangGroup group) {
    return Result.fromAsync(() async {
      return await compute((args) async {
        final client = http.Client();
        try {
          final url = Uri.parse(args[0]);
          final response = await client
              .get(url)
              .timeout(const Duration(seconds: 30));

          return jsonDecode(utf8.decode(response.bodyBytes)) as List;
        } finally {
          client.close();
        }
      }, [url.toString()]).then(
        (json) => json.map((e) {
          final bang = Bang.fromJson(e as Map<String, dynamic>);
          return bang.copyWith.group(group);
        }).toList(),
      );
    }, exceptionHandler: handleHttpError);
  }

  Future<DateTime> getBundledBangDate(String path) async {
    final content = await rootBundle.loadString(path);
    return DateTime.parse(content.trim()).toLocal();
  }

  /// Reads a bundled bang asset without decoding it.
  ///
  /// Split from the decode on purpose: `rootBundle` is only reachable from the
  /// isolate that owns the `ServicesBinding`, while decoding and mapping the
  /// ~2.2 MB main group is exactly the work that must not happen there. Hand the
  /// result to [parseBundledBangs] inside a background isolate.
  Future<String> loadBundledBangJson(String path) =>
      rootBundle.loadString(path);
}

/// Decodes the text of a bundled bang asset.
///
/// A top-level function so it can run in a background isolate; takes no
/// services and touches no bindings.
List<Bang> parseBundledBangs(String assetJson, BangGroup? group) {
  final json = jsonDecode(assetJson) as List;

  return json.map((e) {
    var bang = Bang.fromJson(e as Map<String, dynamic>);

    if (group != null) {
      bang = bang.copyWith.group(group);
    }

    return bang;
  }).toList();
}
