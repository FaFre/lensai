/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 */
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/asset_database.dart';
import 'package:weblibre/core/maintenance/participant_category.dart';
import 'package:weblibre/core/startup/models/json_read.dart';

part 'backup_manifest.g.dart';

/// Name of the manifest inside the archive root.
const backupManifestFileName = 'weblibre_backup.json';

const backupManifestVersion = 1;

/// Directory inside the archive holding staged participant state.
///
/// Inside the archive on purpose: it is the only way state that lives outside
/// the profile directory can travel with a backup and be found again by the
/// restore of that same archive.
const participantStagingDirName = 'weblibre_participants';

/// What a backup deliberately leaves out.
///
/// This is the backup contract, not a size optimization, which is why it is not
/// configurable. Restore has to *recreate* these rather than assume the archive
/// carried them, and the manifest names them so a restored profile's gaps are
/// explainable instead of mysterious.
/// Const-constructible on purpose: [BackupExclusions.entries] is a `const` list
/// and is a default constructor argument, so no equality mixin can be added here.
@JsonSerializable()
class BackupExclusion {
  const BackupExclusion({
    required this.path,
    required this.reason,
    required this.recreatedOnRestore,
  });

  factory BackupExclusion.fromJson(Map<String, dynamic> json) =>
      _$BackupExclusionFromJson(json);

  /// Profile-relative path, POSIX-style.
  @JsonKey(fromJson: stringOrEmpty)
  final String path;

  @JsonKey(fromJson: stringOrEmpty)
  final String reason;

  /// Whether restore reproduces it, or the profile simply lives without it.
  @JsonKey(fromJson: _recreatedFromJson)
  final bool recreatedOnRestore;

  Map<String, dynamic> toJson() => _$BackupExclusionToJson(this);
}

/// The exclusion list.
///
/// A namespace rather than a value: the list is fixed by the backup contract, so
/// there is nothing to instantiate and nothing to configure.
// ignore: avoid_classes_with_only_static_members
abstract final class BackupExclusions {
  static const entries = [
    BackupExclusion(
      path: 'cache',
      reason: 'Gecko cache, regenerated on first run',
      recreatedOnRestore: true,
    ),
    BackupExclusion(
      path: 'databases/quotes.db',
      reason: 'Read-only asset database, reseeded from the bundled asset',
      recreatedOnRestore: true,
    ),
    BackupExclusion(
      path: 'databases/sites.db',
      reason: 'Read-only asset database, reseeded from the bundled asset',
      recreatedOnRestore: true,
    ),
    // The stamps have to be named separately: `isExcluded` matches a path or a
    // directory prefix, and `databases/sites.db.asset` is neither of those
    // relative to `databases/sites.db`. Without these the archive would carry a
    // stamp for a database the same manifest declares excluded.
    BackupExclusion(
      path: 'databases/quotes.db$assetStampSuffix',
      reason: 'Install stamp for an excluded asset database',
      recreatedOnRestore: true,
    ),
    BackupExclusion(
      path: 'databases/sites.db$assetStampSuffix',
      reason: 'Install stamp for an excluded asset database',
      recreatedOnRestore: true,
    ),
  ];

  /// Whether [relativePath] (profile-relative) is excluded.
  ///
  /// Matches a directory and everything under it, so `cache/x/y` goes with
  /// `cache`. Comparison is on normalized POSIX paths because the manifest and
  /// the archive both speak that.
  static bool isExcluded(String relativePath) {
    final normalized = p.posix.normalize(relativePath.replaceAll(r'\', '/'));

    for (final exclusion in entries) {
      if (normalized == exclusion.path ||
          p.posix.isWithin(exclusion.path, normalized)) {
        return true;
      }
    }

    return false;
  }
}

/// Describes an archive: what is in it, what is not, and what it came from.
///
/// Every field is tolerant on the way in. A manifest is read from a file the
/// user supplies, and a malformed one must degrade to a restore that explains
/// less — never to an exception on the startup path.
@CopyWith()
@JsonSerializable()
class BackupManifest with FastEquatable {
  BackupManifest({
    required this.profileId,
    required this.profileName,
    required this.createdAt,
    required this.sourceBytes,
    required this.entryCount,
    this.version = backupManifestVersion,
    this.exclusions = BackupExclusions.entries,
    List<String>? undeclaredCategories,
    List<String>? includedParticipantCategories,
    this.archiveSha256,
  }) : undeclaredCategories =
           undeclaredCategories ?? ParticipantCategory.archiveOmissions,
       includedParticipantCategories =
           includedParticipantCategories ?? ParticipantCategory.archiveContents;

  factory BackupManifest.fromJson(Map<String, dynamic> json) =>
      _$BackupManifestFromJson(json);

  @JsonKey(fromJson: _versionFromJson)
  final int version;

  @JsonKey(fromJson: stringOrEmpty)
  final String profileId;

  @JsonKey(fromJson: stringOrEmpty)
  final String profileName;

  /// Epoch when unreadable: a manifest with no usable date is still a manifest,
  /// and the date is the least load-bearing thing in it.
  @JsonKey(fromJson: _createdAtFromJson, toJson: _createdAtToJson)
  final DateTime createdAt;

  /// Bytes actually copied into the archive source, after exclusions.
  @JsonKey(fromJson: _countFromJson)
  final int sourceBytes;

  @JsonKey(fromJson: _countFromJson)
  final int entryCount;

  @JsonKey(fromJson: _exclusionsFromJson)
  final List<BackupExclusion> exclusions;

  /// Categories of profile-owned state that are *not* in the archive.
  ///
  /// Read back from the archive rather than re-derived, so a manifest written by
  /// another build describes the archive that build actually made. New archives
  /// default to [ParticipantCategory.archiveOmissions].
  @JsonKey(fromJson: stringList)
  final List<String> undeclaredCategories;

  /// State from outside the profile directory that participants put *into* the
  /// archive.
  ///
  /// Empty in archives written before participants shipped, and correctly so:
  /// those really did carry none of this.
  @JsonKey(fromJson: stringList)
  final List<String> includedParticipantCategories;

  /// Digest of the finished archive. Absent inside the archive itself — it
  /// cannot contain its own hash — and filled in by the operation's result.
  @JsonKey(includeIfNull: false, fromJson: stringOrNull)
  final String? archiveSha256;

  BackupManifest withDigest(String digest) => copyWith(archiveSha256: digest);

  Map<String, dynamic> toJson() => _$BackupManifestToJson(this);

  @override
  List<Object?> get hashParameters => [
    version,
    profileId,
    profileName,
    createdAt,
    sourceBytes,
    entryCount,
    exclusions,
    undeclaredCategories,
    includedParticipantCategories,
    archiveSha256,
  ];
}

int _versionFromJson(Object? value) => intOr(value, backupManifestVersion);

int _countFromJson(Object? value) => intOr(value, 0);

bool _recreatedFromJson(Object? value) => boolOr(value, false);

DateTime _createdAtFromJson(Object? value) =>
    dateTimeOrNull(value) ??
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

String _createdAtToJson(DateTime value) => value.toUtc().toIso8601String();

List<BackupExclusion> _exclusionsFromJson(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(BackupExclusion.fromJson)
      .toList();
}
