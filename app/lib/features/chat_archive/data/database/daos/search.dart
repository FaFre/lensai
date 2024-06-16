import 'package:bang_navigator/features/chat_archive/data/database/database.dart';
import 'package:drift/drift.dart';

part 'search.g.dart';

@DriftAccessor()
class SearchDao extends DatabaseAccessor<ChatSearchDatabase>
    with _$SearchDaoMixin {
  SearchDao(super.db);

  Future<void> indexChats(Iterable<ChatCompanion> chats) {
    return db.chat.insertAll(chats);
  }

  Future<int> deleteAllChats() {
    return db.chat.deleteAll();
  }

  Future<int> deleteChat(String fileName) {
    return (db.chat.delete()..where((t) => t.fileName.equals(fileName))).go();
  }

  Future<void> upsertChat(ChatCompanion chat) {
    return db.chat.insertOne(
      chat,
      onConflict: DoUpdate(
        (old) => ChatCompanion.custom(
          content: Variable(chat.content.value),
        ),
      ),
    );
  }

  Selectable<ChatQueryResult> queryChats({
    required String matchPrefix,
    required String matchSuffix,
    required String ellipsis,
    required int snippetLength,
    required String searchString,
  }) {
    return db.chatQuery(
      query: db.buildQuery(searchString),
      snippetLength: snippetLength,
      beforeMatch: matchPrefix,
      afterMatch: matchSuffix,
      ellipsis: ellipsis,
    );
  }
}
