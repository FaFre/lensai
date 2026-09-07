import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/asset_database.dart';
import 'package:weblibre/core/maintenance/backup_manifest.dart';
import 'package:weblibre/core/maintenance/backup_operation.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';

const _profileId = '0199a0b1-1111-7111-8111-111111111111';

/// Answers the fencing check, and can start refusing at a chosen boundary.
class _FakeProfileApi implements GeckoProfileApi {
  _FakeProfileApi({this.loseLeaseAt});

  final String? loseLeaseAt;
  final List<String> boundaries = [];

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';

  @override
  Future<bool> assertMaintenanceLease(
    String leaseId,
    String? taskId,
    String boundary,
  ) async {
    boundaries.add(boundary);
    return boundary != loseLeaseAt;
  }

  @override
  Future<bool> heartbeatMaintenance(String leaseId) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late Directory root;
  late Directory profileDir;
  late Directory workDir;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('weblibre_backup');
    profileDir = Directory(p.join(root.path, 'profile'));
    workDir = Directory(p.join(root.path, 'work'));
    await workDir.create(recursive: true);

    Future<void> write(String relative, String content) async {
      final file = File(p.join(profileDir.path, relative));
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
    }

    await write('databases/tab.db', 'tabs');
    await write('databases/user.db', 'user');
    await write('databases/quotes.db', 'quotes');
    await write('databases/sites.db', 'sites');
    await write('cache/gecko/entry', 'cached');
    await write('files/mozilla/prefs.js', 'prefs');
    await write('metadata.json', '{}');
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  MaintenanceLease leaseWith(_FakeProfileApi api) => MaintenanceLease(
    leaseId: 'lease-1',
    taskId: 'task-1',
    service: GeckoProfileService(api: api),
  );

  Future<BackupResult> run(
    _FakeProfileApi api, {
    Directory? staged,
    Future<int?> Function()? availableBytes,
    BackupOptions options = const BackupOptions(),
  }) {
    return backupProfile(
      lease: leaseWith(api),
      profileDir: profileDir,
      profileId: _profileId,
      profileName: 'Default',
      workDir: workDir,
      options: options,
      availableBytes: availableBytes,
      now: DateTime.utc(2026, 8, 19),
      pack: (source, output) async {
        // Stands in for the encrypted archive: copy the staged tree somewhere the
        // test can inspect, then write a byte or two so the digest has input.
        if (staged != null) {
          await _copyTree(source, staged);
        }
        await output.writeAsString('archive-of-${source.path}');
      },
      publish: (archive) async {},
    );
  }

  group('participants', () {
    test('what a participant stages ends up inside the archive', () async {
      // The bug this guards: participants wrote to a scratch workspace outside
      // the staging tree, so nothing they captured was ever archived and every
      // restore found "no participant state".
      final staged = Directory(p.join(root.path, 'staged'));
      final participant = _RecordingParticipant();

      await backupProfile(
        lease: leaseWith(_FakeProfileApi()),
        profileDir: profileDir,
        profileId: _profileId,
        profileName: 'Default',
        workDir: workDir,
        participants: [participant],
        now: DateTime.utc(2026, 8, 19),
        pack: (source, output) async {
          await _copyTree(source, staged);
          await output.writeAsString('archive');
        },
        publish: (archive) async {},
      );

      expect(participant.kinds, [MaintenanceOperationKind.backup]);
      expect(
        File(
          p.join(staged.path, participantStagingDirName, 'recorder', 'state'),
        ).existsSync(),
        isTrue,
      );
    });

    test('a leftover participant directory is not carried into the archive', () async {
      // Restores before this was cleaned up left the archive's own participant
      // payload inside the profile. Copying that into a new archive would republish
      // a stale snapshot of what the participants captured — credentials included —
      // under a fresh backup's name.
      final stale = File(
        p.join(profileDir.path, participantStagingDirName, 'recorder', 'state'),
      );
      await stale.parent.create(recursive: true);
      await stale.writeAsString('from an earlier restore');

      final staged = Directory(p.join(root.path, 'staged'));
      final result = await run(_FakeProfileApi(), staged: staged);

      // The directory itself is always there — this operation creates it for the
      // participants to stage into. What must not survive is its old content.
      expect(
        File(
          p.join(staged.path, participantStagingDirName, 'recorder', 'state'),
        ).existsSync(),
        isFalse,
      );
      // Nor may it be counted as profile data: the same four files as a profile
      // that never had one.
      expect(result.manifest.entryCount, 4);
    });

    test('a participant is told it is a backup, not a restore', () async {
      // A participant that cannot tell the two apart captures nothing on the way
      // out and finds nothing on the way back in.
      final participant = _RecordingParticipant();

      await backupProfile(
        lease: leaseWith(_FakeProfileApi()),
        profileDir: profileDir,
        profileId: _profileId,
        profileName: 'Default',
        workDir: workDir,
        participants: [participant],
        now: DateTime.utc(2026, 8, 19),
        pack: (source, output) => output.writeAsString('archive'),
        publish: (archive) async {},
      );

      expect(participant.kinds.single, MaintenanceOperationKind.backup);
    });
  });

  group('exclusions', () {
    test('the contract list is matched by path and by prefix', () {
      expect(BackupExclusions.isExcluded('cache'), isTrue);
      expect(BackupExclusions.isExcluded('cache/gecko/entry'), isTrue);
      expect(BackupExclusions.isExcluded('databases/quotes.db'), isTrue);
      expect(BackupExclusions.isExcluded('databases/sites.db'), isTrue);

      // The install stamps go with their databases. `isExcluded` matches a
      // path or a directory prefix, so `databases/sites.db` does not cover
      // `databases/sites.db.asset` — they have to be named, and without that
      // an archive carried a stamp for a database the same manifest declares
      // excluded and reseeded.
      expect(
        BackupExclusions.isExcluded('databases/quotes.db$assetStampSuffix'),
        isTrue,
      );
      expect(
        BackupExclusions.isExcluded('databases/sites.db$assetStampSuffix'),
        isTrue,
      );

      expect(BackupExclusions.isExcluded('databases/tab.db'), isFalse);
      // Not a prefix match on the name: only the exact asset databases go.
      expect(BackupExclusions.isExcluded('databases/quotes.db.bak'), isFalse);
      expect(BackupExclusions.isExcluded('cached/thing'), isFalse);
    });
  });

  group('backupProfile', () {
    test('stages everything except the excluded paths', () async {
      final staged = Directory(p.join(root.path, 'staged'));
      await run(_FakeProfileApi(), staged: staged);

      String rel(String path) => p.relative(path, from: staged.path);
      final files = staged
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => rel(file.path))
          .toSet();

      expect(files, contains(p.join('databases', 'tab.db')));
      expect(files, contains(p.join('files', 'mozilla', 'prefs.js')));
      expect(files, isNot(contains(p.join('databases', 'quotes.db'))));
      expect(files, isNot(contains(p.join('databases', 'sites.db'))));
      expect(files.any((path) => path.startsWith('cache')), isFalse);
    });

    test('writes a manifest that names what it left out', () async {
      final staged = Directory(p.join(root.path, 'staged'));
      await run(_FakeProfileApi(), staged: staged);

      final manifest = BackupManifest.fromJson(
        jsonDecode(
              File(
                p.join(staged.path, backupManifestFileName),
              ).readAsStringSync(),
            )
            as Map<String, Object?>,
      );

      expect(manifest.profileId, _profileId);
      expect(manifest.profileName, 'Default');
      expect(
        manifest.exclusions.map((entry) => entry.path),
        containsAll(<String>['cache', 'databases/quotes.db']),
      );
      // The categories that are not in the archive at all must be stated, not
      // silently missing.
      expect(manifest.undeclaredCategories, isNotEmpty);
    });

    test('counts only the bytes it actually archived', () async {
      final result = await run(_FakeProfileApi());

      // tabs(4) + user(4) + prefs(5) + metadata(2) = 15; caches and asset DBs
      // must not be counted.
      expect(result.manifest.entryCount, 4);
      expect(result.manifest.sourceBytes, 15);
    });

    test('reports a digest of the finished archive', () async {
      final result = await run(_FakeProfileApi());

      expect(result.manifest.archiveSha256, isNotNull);
      expect(result.manifest.archiveSha256, hasLength(64));
    });

    test('cleans up the staged copy even on success', () async {
      await run(_FakeProfileApi());

      expect(Directory(p.join(workDir.path, 'source')).existsSync(), isFalse);
    });

    test('refuses before writing anything when storage is short', () async {
      final api = _FakeProfileApi();

      await expectLater(
        run(api, availableBytes: () async => 10),
        throwsA(isA<InsufficientStorage>()),
      );

      expect(
        File(p.join(workDir.path, 'archive.weblibre')).existsSync(),
        isFalse,
      );
      expect(Directory(p.join(workDir.path, 'source')).existsSync(), isFalse);
    });

    test('an unknown free-space answer does not block the backup', () async {
      final result = await run(
        _FakeProfileApi(),
        availableBytes: () async => null,
      );

      expect(result.manifest.entryCount, 4);
    });

    test(
      'the lease is checked at every boundary, not just the start',
      () async {
        final api = _FakeProfileApi();
        await run(api);

        expect(api.boundaries, [
          'backup.start',
          'backup.stage',
          'backup.pack',
          'backup.publish',
        ]);
      },
    );

    test(
      'losing the lease mid-operation stops it and clears the staging',
      () async {
        final api = _FakeProfileApi(loseLeaseAt: 'backup.pack');

        await expectLater(run(api), throwsA(isA<MaintenanceLeaseLost>()));

        expect(Directory(p.join(workDir.path, 'source')).existsSync(), isFalse);
      },
    );

    test('an unreachable arbiter counts as a lost lease', () async {
      const lease = MaintenanceLease(leaseId: 'lease-1', taskId: 'task-1');

      // No fake installed, so the real Pigeon channel throws in a test binding.
      await expectLater(
        lease.assertHeld('backup.start'),
        throwsA(isA<MaintenanceLeaseLost>()),
      );
    });
  });
}

Future<void> _copyTree(Directory source, Directory target) async {
  await target.create(recursive: true);
  await for (final entity in source.list(recursive: true, followLinks: false)) {
    final relative = p.relative(entity.path, from: source.path);
    final destination = p.join(target.path, relative);
    if (entity is Directory) {
      await Directory(destination).create(recursive: true);
    } else if (entity is File) {
      await Directory(p.dirname(destination)).create(recursive: true);
      await entity.copy(destination);
    }
  }
}

/// Writes a marker during `prepare` so the test can see where it landed.
class _RecordingParticipant implements MaintenanceParticipant {
  final List<MaintenanceOperationKind> kinds = [];

  @override
  String get id => 'recorder';

  @override
  int get version => 1;

  @override
  Future<void> discover(MaintenanceParticipantContext context) async {}

  @override
  Future<void> prepare(MaintenanceParticipantContext context) async {
    kinds.add(context.kind);
    final dir = Directory(p.join(context.stagedDir.path, id));
    await dir.create(recursive: true);
    await File(p.join(dir.path, 'state')).writeAsString('captured');
  }

  @override
  Future<void> apply(MaintenanceParticipantContext context) async {}

  @override
  Future<void> verify(MaintenanceParticipantContext context) async {}

  @override
  Future<void> finalizeWork(MaintenanceParticipantContext context) async {}

  @override
  Future<void> rollback(MaintenanceParticipantContext context) async {}
}
