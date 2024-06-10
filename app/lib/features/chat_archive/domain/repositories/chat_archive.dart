import 'package:bang_navigator/features/chat_archive/data/repositories/chat_archive_file.dart';
import 'package:bang_navigator/features/chat_archive/domain/entities/chat_entity.dart';
import 'package:bang_navigator/features/kagi/data/services/chat.dart';
import 'package:exceptions/exceptions.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'chat_archive.g.dart';

@Riverpod()
class ChatArchiveRepository extends _$ChatArchiveRepository {
  Future<List<ChatEntity>> _listArchivedChats() async {
    final files =
        await ref.read(chatArchiveFileRepositoryProvider.notifier).list();

    return files
        .where((file) => path.extension(file.path) == '.md')
        .map((file) => ChatEntity.fromFileName(path.basename(file.path)))
        .toList();
  }

  Future<Result<void>> archiveChat(String fileName, Uri url) async {
    final contentsResult =
        await ref.read(kagiChatServiceProvider.notifier).downloadChat(url);

    return contentsResult.flatMapAsync(
      (contents) => ref
          .read(chatArchiveFileRepositoryProvider.notifier)
          .write(fileName, contents),
    );
  }

  Future<Result<String>> readChat(String fileName) async {
    final contentsResult = await Result.fromAsync(
      () => ref.read(chatArchiveFileRepositoryProvider.notifier).read(fileName),
    );

    return contentsResult.fold(
      (value) => (value == null)
          ? Result.failure(
              ErrorMessage(
                source: 'Chat Archive',
                message: 'Chat $fileName not found',
              ),
            )
          : Result.success(value),
      onFailure: Result.failure,
    );
  }

  @override
  Stream<List<ChatEntity>> build() async* {
    final fileRepository = ref.watch(chatArchiveFileRepositoryProvider);

    yield* ConcatStream([
      _listArchivedChats().asStream(),
      fileRepository.asyncMap(
        (_) => _listArchivedChats(),
      ),
    ]);
  }
}

@Riverpod()
Future<String> readArchivedChat(
  ReadArchivedChatRef ref,
  String fileName,
) async {
  final result =
      await ref.read(chatArchiveRepositoryProvider.notifier).readChat(fileName);

  return result.value;
}
