import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:lensai/features/topics/data/database/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:universal_io/io.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
TabDatabase tabDatabase(TabDatabaseRef ref) {
  return TabDatabase(
    LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final dbFolder = await path_provider.getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'tab.db'));

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await path_provider.getTemporaryDirectory()).path;
      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    }),
  );
}

@Riverpod()
Stream<bool> isTabExisting(IsTabExistingRef ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.watchTabExisiting(tabId);
}

@Riverpod()
Stream<TabData?> tabData(TabDataRef ref, String tabId) {
  final db = ref.watch(tabDatabaseProvider);
  return db.tabDao.watchTab(tabId);
}
