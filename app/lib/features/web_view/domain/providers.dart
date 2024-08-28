import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lensai/features/content_block/domain/repositories/host.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/features/topics/domain/providers.dart';
import 'package:lensai/features/topics/domain/repositories/tab.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_io/io.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Stream<Set<String>?> blockContentHosts(BlockContentHostsRef ref) {
  final hostRepository = ref.watch(hostRepositoryProvider.notifier);
  final enableContentBlocking = ref.watch(
    settingsRepositoryProvider.select(
      (value) =>
          (value.valueOrNull ?? Settings.withDefaults()).enableContentBlocking,
    ),
  );
  final enableHostList = ref.watch(
    settingsRepositoryProvider.select(
      (value) => (value.valueOrNull ?? Settings.withDefaults()).enableHostList,
    ),
  );

  if (!enableContentBlocking || enableHostList.isEmpty) {
    return Stream.value(null);
  }

  return hostRepository
      .watchHosts(sources: enableHostList)
      .map((hosts) => hosts.toSet());
}

@Riverpod(keepAlive: true)
Future<String> readerabilityScript(ReaderabilityScriptRef ref) {
  return rootBundle.load('assets/scripts/readability.min.js.gz').then(
        (value) => compute(
          (message) => utf8.decode(gzip.decode(message)),
          value.buffer.asUint8List(),
        ),
      );
}

@Riverpod()
List<String> activeTabs(ActiveTabsRef ref) {
  final topic = ref.watch(selectedTopicProvider);
  return ref.watch(
    topicTabRepositoryProvider(topic)
        .select((value) => value.valueOrNull ?? []),
  );
}
