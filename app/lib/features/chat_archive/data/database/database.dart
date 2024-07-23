import 'package:drift/drift.dart';
import 'package:lensai/features/chat_archive/data/database/daos/search.dart';
import 'package:lensai/features/query/domain/tokenizer.dart';

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
