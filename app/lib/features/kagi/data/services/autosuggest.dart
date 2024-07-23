import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:lensai/core/http_error_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'autosuggest.g.dart';

@Riverpod(keepAlive: true)
class KagiAutosuggestService extends _$KagiAutosuggestService {
  static final _baseUrl = Uri.https('kagi.com', 'api/autosuggest');

  late http.Client _client;

  @override
  void build() {
    _client = http.Client();
  }

  Future<Result<List<String>>> getSuggestions(String query) async {
    return Result.fromAsync(
      () async {
        final response = await _client
            .get(_baseUrl.replace(queryParameters: {'q': query}))
            .timeout(const Duration(seconds: 5));

        final results = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        return switch (results.last) {
          final String result => [result],
          final List resultList => resultList.cast(),
          _ => []
        };
      },
      exceptionHandler: handleHttpError,
    );
  }
}
