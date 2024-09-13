import 'dart:ui';

import 'package:fast_equatable/fast_equatable.dart';

class TopicData with FastEquatable {
  final String id;
  final String? name;
  final Color color;

  TopicData({required this.id, this.name, required this.color});

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        id,
        name,
        color,
      ];
}

class TopicDataWithCount extends TopicData {
  final int? tabCount;

  TopicDataWithCount({
    required super.id,
    super.name,
    required super.color,
    required this.tabCount,
  });

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        ...super.hashParameters,
        tabCount,
      ];
}
