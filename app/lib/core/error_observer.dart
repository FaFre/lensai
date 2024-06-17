import 'package:bang_navigator/core/logger.dart';
import 'package:riverpod/riverpod.dart';

class ErrorObserver extends ProviderObserver {
  const ErrorObserver();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logger.e('Provider $provider threw $error at $stackTrace');
  }
}
