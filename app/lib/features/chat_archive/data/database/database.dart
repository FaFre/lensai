import 'package:bang_navigator/features/chat_archive/data/database/daos/search.dart';
import 'package:bang_navigator/features/query/domain/tokenizer.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [SearchDao],
)
class ChatSearchDatabase extends _$ChatSearchDatabase
    with TrigramQueryBuilderMixin {
  @override
  final int schemaVersion = 1;

  @override
  final int ftsTokenLimit = 6;
  @override
  final int ftsMinTokenLength = 3;

  ChatSearchDatabase(super.e);
}
