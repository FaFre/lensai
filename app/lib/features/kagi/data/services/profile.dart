import 'dart:convert';

import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:lensai/core/http/error_handler.dart';
import 'package:lensai/core/http/message_stream.dart';
import 'package:lensai/features/kagi/data/entities/profile_data.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile.g.dart';

@Riverpod(keepAlive: true)
class KagiProfileService extends _$KagiProfileService {
  static final _baseUrl = Uri.https('kagi.com', '_nt/assistant/profile_list');
  static const _profileMessageId = 'profiles.json:';

  late http.Client _client;

  @override
  void build() {
    _client = http.Client();
  }

  Future<Result<ProfileData>> getProfile() {
    final kagiSession =
        ref.read(settingsRepositoryProvider).valueOrNull?.kagiSession;

    return Result.fromAsync(
      () async {
        final headers = {
          'Accept': 'application/vnd.kagi.stream',
          'Accept-Language': 'en-US,en;q=0.5',
          'Content-Type': 'application/json',
          'Cookie': 'kagi_session=$kagiSession',
        };

        final body = json.encode({});

        final request = http.Request('POST', _baseUrl)
          ..body = body
          ..headers.addAll(headers);

        return HttpMessageStream(client: _client)
            .readMessages(request)
            .firstWhere((message) => message.startsWith(_profileMessageId))
            .then(
              (message) => ProfileData.fromJson(
                json.decode(message.substring(_profileMessageId.length))
                    as Map<String, dynamic>,
              ),
            );
      },
      exceptionHandler: handleHttpError,
    );
  }
}
