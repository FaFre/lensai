import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:lensai/features/geckoview/features/topics/data/models/topic_data.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/topic.dart';
import 'package:lensai/features/geckoview/features/topics/utils/color_palette.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Future<Color> unusedRandomTopicColor(UnusedRandomTopicColorRef ref) async {
  final repository = ref.watch(topicRepositoryProvider.notifier);

  final allColors = colorTypes.flattened.toList();
  final usedColors = await repository.getDistinctColors();

  Color randomColor;
  do {
    randomColor = randomColorShade(allColors);
  } while (usedColors.contains(randomColor));

  return randomColor;
}

@Riverpod()
Stream<List<TopicDataWithCount>> topicsWithCount(TopicsWithCountRef ref) {
  final db = ref.watch(tabDatabaseProvider);
  return db.topicsWithCount().watch();
}

@Riverpod()
Stream<List<String>> topicTabIds(TopicTabIdsRef ref, String topicId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabLinkDao.topicTabIds(topicId).watch();
}

@Riverpod()
Stream<String?> tabTopicId(TabTopicIdRef ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabLinkDao.tabTopicId(tabId).watchSingleOrNull();
}
