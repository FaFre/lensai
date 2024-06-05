import 'package:bang_navigator/core/http_error_handler.dart';
import 'package:bang_navigator/features/settings/data/repositories/settings_repository.dart';
import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat.g.dart';

@Riverpod(keepAlive: true)
class KagiChatService extends _$KagiChatService {
  late http.Client _client;

  @override
  void build() {
    _client = http.Client();
  }

  Future<Result<String>> downloadChat(Uri url) {
    final kagiSession =
        ref.read(settingsRepositoryProvider).valueOrNull?.kagiSession;

    return Result.fromAsync(
      () async {
        final response = await _client
            .get(url.replace(queryParameters: {'token': kagiSession}));

        return response.body;
      },
      exceptionHandler: handleHttpError,
    );
  }
}
