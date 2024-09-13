import 'package:fast_equatable/fast_equatable.dart';

class ReaderableState with FastEquatable {
  final bool readerable;

  final bool active;

  ReaderableState({
    required this.readerable,
    required this.active,
  });

  factory ReaderableState.$default() => ReaderableState(
        readerable: false,
        active: false,
      );

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [readerable, active];
}
