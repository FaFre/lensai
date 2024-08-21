import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:lensai/core/uuid.dart';
import 'package:lensai/features/topics/data/database/database.dart';

part 'topic.g.dart';

@DriftAccessor()
class TopicDao extends DatabaseAccessor<TabDatabase> with _$TopicDaoMixin {
  TopicDao(super.db);

  Future<void> addTopic({String? name, required Color color}) {
    return db.topic.insertOne(
      TopicCompanion.insert(
        id: uuid.v7(),
        name: Value(name),
        color: color,
      ),
    );
  }

  Future<void> replaceTopic(
    String id, {
    required String? name,
    required Color color,
  }) {
    return db.topic.replaceOne(
      TopicCompanion(
        id: Value(id),
        name: Value(name),
        color: Value(color),
      ),
    );
  }

  Future<void> deleteTopic(String id) {
    return db.topic.deleteOne(TopicCompanion.custom(id: Variable(id)));
  }

  SingleOrNullSelectable<TopicData> getTopicData(String id) {
    return select(db.topic)..where((t) => t.id.equals(id));
  }

  Selectable<Color> getDistinctColors() {
    final query = db.selectOnly(db.topic, distinct: true)
      ..addColumns([db.topic.color])
      ..where(db.topic.color.isNotNull());

    return query
        .map((row) => row.readWithConverter<Color?, int>(db.topic.color)!);
  }
}
