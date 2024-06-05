import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_io/io.dart';
import 'package:watcher/watcher.dart';

part 'chat_archive_file.g.dart';

@Riverpod()
class ChatArchiveFileRepository extends _$ChatArchiveFileRepository {
  final Future<Directory> _archiveDirectoryFuture;

  ChatArchiveFileRepository()
      : _archiveDirectoryFuture =
            path_provider.getApplicationDocumentsDirectory().then(
                  (documentDirectory) => Directory(
                    path.join(documentDirectory.path, 'archive', 'chat'),
                  ).create(recursive: true),
                );

  Future<List<FileSystemEntity>> list() {
    return _archiveDirectoryFuture.then((value) => value.list().toList());
  }

  Future<void> write(String fileName, String contents) async {
    final directory = await _archiveDirectoryFuture;
    final file = File(path.join(directory.path, fileName));

    await file.writeAsString(contents, flush: true);
  }

  Future<String?> read(String fileName) async {
    final directory = await _archiveDirectoryFuture;
    final file = File(path.join(directory.path, fileName));

    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }

  Future<void> delete(String fileName) async {
    final directory = await _archiveDirectoryFuture;
    final file = File(path.join(directory.path, fileName));

    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Raw<Stream<WatchEvent>> build() async* {
    final watcher = DirectoryWatcher(
      await _archiveDirectoryFuture
          .then((archiveDirectory) => archiveDirectory.absolute.path),
    );

    yield* watcher.events;
  }
}
