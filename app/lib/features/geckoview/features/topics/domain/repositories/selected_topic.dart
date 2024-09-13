import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_topic.g.dart';

@Riverpod(keepAlive: true)
class SelectedTopicRepository extends _$SelectedTopicRepository {
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
