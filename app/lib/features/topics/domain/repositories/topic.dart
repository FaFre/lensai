import 'dart:ui';

import 'package:lensai/features/topics/data/database/database.dart';
import 'package:lensai/features/topics/data/models/topic_data.dart';
import 'package:lensai/features/topics/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'topic.g.dart';

@Riverpod(keepAlive: true)
class TopicRepository extends _$TopicRepository {
  late TabDatabase _db;

  @override
  Stream<List<TopicDataWithCount>> build() {
    _db = ref.watch(tabDatabaseProvider);
    return _db.topicsWithCount().watch();
  }

  Future<void> addTopic({required String? name, required Color color}) {
    return _db.topicDao.addTopic(name: name, color: color);
  }

  Future<void> replaceTopic({
    required String id,
    required String? name,
    required Color color,
  }) {
    return _db.topicDao.replaceTopic(id, name: name, color: color);
  }

  Future<void> deleteTopic(String id) {
    return _db.topicDao.deleteTopic(id);
  }

  Future<Set<Color>> getDistinctColors() {
    return _db.topicDao
        .getDistinctColors()
        .get()
        .then((colors) => colors.toSet());
  }
}
