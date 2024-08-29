import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart';
import 'package:universal_io/io.dart';

ErrorMessage handleHttpError(
  Exception exception,
  StackTrace stackTrace,
) {
  return switch (exception) {
    SocketException() => const ErrorMessage(
        source: 'http',
        message: 'Could not contact remote service',
      ),
    HttpException() => const ErrorMessage(
        source: 'http',
        message: 'Web request returned error',
      ),
    FormatException() => const ErrorMessage(
        source: 'http',
        message: 'Bad response format',
      ),
    ClientException() => const ErrorMessage(
        source: 'http',
        message: 'Could not contact remote service',
      ),
    _ => ErrorMessage.fromException(
        exception,
        stackTrace,
      )
  };
}
