import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lensai/core/http_error_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'source.g.dart';

@Riverpod()
class HostSourceService extends _$HostSourceService {
  late http.Client _client;

  @override
  void build() {
    _client = http.Client();
  }

  Future<Result<Set<String>>> getHosts(Uri url) async {
    return Result.fromAsync(
      () async {
        final response = await _client.get(url);
        return await compute(
          (args) {
            final hostRegex = RegExp(
              r'^\s*([0-9a-fA-F:.]+)\s+(\S+)',
              multiLine: true,
            );

            final matches = hostRegex.allMatches(utf8.decode(args[0]));
            return matches
                .map((match) => match.group(2))
                .whereNotNull()
                .toSet();
          },
          [response.bodyBytes],
        );
      },
      exceptionHandler: handleHttpError,
    );
  }
}
