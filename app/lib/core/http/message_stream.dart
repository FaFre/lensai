import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpMessageStream {
  final http.Client client;

  HttpMessageStream({http.Client? client}) : client = client ?? http.Client();

  Stream<String> readMessages(http.Request request) async* {
    final buffer = StringBuffer();

    final streamedResponse = await request.send();

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      buffer.write(chunk);

      final messages = buffer.toString().split('\u0000');
      if (messages.length > 1) {
        for (final message
            in messages.take(messages.length - 1).map((x) => x.trim())) {
          yield message;
        }

        buffer.clear();
        buffer.write(messages.last);
      }
    }
  }

  void dispose() {
    client.close();
  }
}
