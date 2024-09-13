import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:lensai/features/geckoview/features/topics/data/models/topic_data.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:lensai/features/geckoview/features/topics/domain/repositories/topic.dart';
import 'package:lensai/features/geckoview/features/topics/utils/color_palette.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class SelectedTopic extends _$SelectedTopic {
  void setTopic(String id) {
    state = id;
  }

  void toggleTopic(String id) {
    if (state == id) {
      clearTopic();
    } else {
      setTopic(id);
    }
  }

  void clearTopic() {
    state = null;
  }

  @override
  String? build() {
    return null;
  }
}

@Riverpod()
Stream<TopicData?> selectedTopicData(SelectedTopicDataRef ref) {
  final db = ref.watch(tabDatabaseProvider);
  final selectedTopic = ref.watch(selectedTopicProvider);

  if (selectedTopic != null) {
    return db.topicDao.getTopicData(selectedTopic).watchSingleOrNull();
  }

  return Stream.value(null);
}

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
