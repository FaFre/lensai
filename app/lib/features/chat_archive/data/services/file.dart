import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_io/io.dart';
import 'package:watcher/watcher.dart';

part 'file.g.dart';

@Riverpod()
class ChatArchiveFileService extends _$ChatArchiveFileService {
  final Future<Directory> _archiveDirectoryFuture;

  ChatArchiveFileService()
      : _archiveDirectoryFuture =
            path_provider.getApplicationDocumentsDirectory().then(
                  (documentDirectory) => Directory(
                    path.join(documentDirectory.path, 'archive', 'chat'),
                  ).create(recursive: true),
                );

  Future<List<FileSystemEntity>> list() {
    return _archiveDirectoryFuture.then(
      (value) => value
          .list()
          .where((file) => path.extension(file.path) == '.md')
          .toList(),
    );
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

  Stream<WatchEvent> _directoryStream() async* {
    final watcher = DirectoryWatcher(
      await _archiveDirectoryFuture
          .then((archiveDirectory) => archiveDirectory.absolute.path),
    );

    yield* watcher.events.where((event) => path.extension(event.path) == '.md');
  }

  @override
  Raw<Stream<WatchEvent>> build() {
    //We return a Raw stream here and yield* doesnt support broadcast.
    //So it is required to use asBroadcastStream here
    return _directoryStream().asBroadcastStream();
  }
}
