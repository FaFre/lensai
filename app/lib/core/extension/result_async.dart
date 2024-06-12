import 'package:exceptions/exceptions.dart';
import 'package:riverpod/riverpod.dart';

extension AsyncExtension<T> on Result<T> {
  AsyncValue<T> toAsyncValue() {
    return switch (this) {
      Success(value: final value) => AsyncValue.data(value),
      // TODO: Handle this case.
      Failure(
        error: final error,
      ) =>
        AsyncError(error.message, error.stackTrace ?? StackTrace.empty),
    };
  }
}
