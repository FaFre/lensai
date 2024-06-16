import 'package:bang_navigator/features/chat_archive/data/services/file.dart';
import 'package:bang_navigator/features/chat_archive/domain/entities/chat_entity.dart';
import 'package:bang_navigator/features/kagi/data/services/chat.dart';
import 'package:exceptions/exceptions.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'archive.g.dart';

@Riverpod()
class ChatArchiveRepository extends _$ChatArchiveRepository {
  Future<List<ChatEntity>> listArchivedChats() async {
    final files =
        await ref.read(chatArchiveFileServiceProvider.notifier).list();

    return files
        .map((file) => ChatEntity.fromFileName(path.basename(file.path)))
        .toList();
  }

  Future<Result<void>> archiveChat(String fileName, Uri url) async {
    final contentsResult =
        await ref.read(kagiChatServiceProvider.notifier).downloadChat(url);

    return contentsResult.flatMapAsync(
      (contents) => ref
          .read(chatArchiveFileServiceProvider.notifier)
          .write(fileName, contents),
    );
  }

  Future<Result<String>> readChat(String fileName) async {
    final contentsResult = await Result.fromAsync(
      () => ref.read(chatArchiveFileServiceProvider.notifier).read(fileName),
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
    final fileRepository = ref.watch(chatArchiveFileServiceProvider);

    yield* ConcatStream([
      listArchivedChats().asStream(),
      fileRepository.asyncMap(
        (_) => listArchivedChats(),
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
