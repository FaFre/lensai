import 'package:fast_equatable/fast_equatable.dart';

class FindResultState with FastEquatable {
  final int activeMatchOrdinal;
  final int numberOfMatches;
  final bool isDoneCounting;

  FindResultState({
    required this.activeMatchOrdinal,
    required this.numberOfMatches,
    required this.isDoneCounting,
  });

  factory FindResultState.$default() => FindResultState(
        activeMatchOrdinal: -1,
        numberOfMatches: 0,
        isDoneCounting: false,
      );

  @override
  List<Object?> get hashParameters => [
        activeMatchOrdinal,
        numberOfMatches,
        isDoneCounting,
      ];

  @override
  bool get cacheHash => true;
}
