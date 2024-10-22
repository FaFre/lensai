import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:lensai/features/geckoview/features/tabs/utils/color_palette.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Future<Color> unusedRandomContainerColor(
  UnusedRandomContainerColorRef ref,
) async {
  final repository = ref.watch(containerRepositoryProvider.notifier);

  final allColors = colorTypes.flattened.toList();
  final usedColors = await repository.getDistinctColors();

  Color randomColor;
  do {
    randomColor = randomColorShade(allColors);
  } while (usedColors.contains(randomColor));

  return randomColor;
}

@Riverpod()
Stream<List<ContainerDataWithCount>> containersWithCount(
  ContainersWithCountRef ref,
) {
  final db = ref.watch(tabDatabaseProvider);
  return db.containersWithCount().watch();
}

@Riverpod()
Stream<String?> tabContainerId(TabContainerIdRef ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.tabContainerId(tabId).watchSingle();
}

@Riverpod()
Stream<List<String>> containerTabIds(
  ContainerTabIdsRef ref,
  String? containerId,
) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.containerTabIds(containerId).watch();
}
