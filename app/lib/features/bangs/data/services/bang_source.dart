import 'dart:convert';

import 'package:bang_navigator/core/http_error_handler.dart';
import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bang_source.g.dart';

@Riverpod()
class BangSource extends _$BangSource {
  late http.Client _client;

  @override
  void build() {
    _client = http.Client();
  }

  Future<Result<List<Bang>>> getBangs(Uri url, BangGroup? group) async {
    return Result.fromAsync(
      () async {
        final response = await _client.get(url);
        return await compute(
          (args) => jsonDecode(utf8.decode(args[0])) as List,
          [response.bodyBytes],
        ).then(
          (json) => json.map((e) {
            var bang = Bang.fromJson(e as Map<String, dynamic>);

            if (group != null) {
              bang = bang.copyWith.group(group);
            }

            return bang;
          }).toList(),
        );
      },
      exceptionHandler: handleHttpError,
    );
  }
}
