import 'package:lensai/features/geckoview/features/topics/data/models/topic_data.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_topic.g.dart';

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
