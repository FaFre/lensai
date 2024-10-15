import 'package:fast_equatable/fast_equatable.dart';

class EquatableCollection<T> with FastEquatable {
  final T collection;
  final bool immutable;

  EquatableCollection(this.collection, {required this.immutable})
      : assert(
          collection is Map || collection is Iterable,
          'Collection type not supported',
        );

  @override
  bool get cacheHash => immutable;

  @override
  List<Object?> get hashParameters => [
        collection,
        immutable,
      ];
}
