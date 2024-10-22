import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/widgets.dart';

class ContainerData with FastEquatable {
  final String id;
  final String? contextualIdentity;
  final String? name;
  final Color color;
  final IconData? icon;

  ContainerData({
    required this.id,
    this.contextualIdentity,
    this.name,
    required this.color,
    this.icon,
  });

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        id,
        contextualIdentity,
        name,
        color,
        icon,
      ];
}

class ContainerDataWithCount extends ContainerData {
  final int? tabCount;

  ContainerDataWithCount({
    required super.id,
    super.contextualIdentity,
    super.name,
    required super.color,
    super.icon,
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
