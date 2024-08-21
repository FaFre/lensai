import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:lensai/features/topics/data/database/database.dart';
import 'package:lensai/features/topics/domain/repositories/topic.dart';
import 'package:lensai/features/topics/utils/color_palette.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
Stream<List<TopicData>> topicList(TopicListRef ref) {
  final repository = ref.watch(topicRepositoryProvider.notifier);
  return repository.watchTopics();
}

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
  final repository = ref.watch(topicRepositoryProvider.notifier);
  final selectedBangTrigger = ref.watch(selectedTopicProvider);
  return repository.watchTopic(selectedBangTrigger);
}

@Riverpod()
Future<Set<Color>> distinctTopicColors(DistinctTopicColorsRef ref) {
  final repository = ref.watch(topicRepositoryProvider.notifier);
  return repository.getDistinctColors();
}

@Riverpod()
Future<Color> unusedRandomTopicColor(UnusedRandomTopicColorRef ref) async {
  final allColors = colorTypes.flattened.toList();
  final usedColors = await ref.read(distinctTopicColorsProvider.future);

  Color randomColor;
  do {
    randomColor = randomColorShade(allColors);
  } while (usedColors.contains(randomColor));

  return randomColor;
}
