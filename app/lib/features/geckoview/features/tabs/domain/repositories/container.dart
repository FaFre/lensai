import 'dart:ui';

import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'container.g.dart';

@Riverpod(keepAlive: true)
class ContainerRepository extends _$ContainerRepository {
  late TabDatabase _db;

  @override
  void build() {
    _db = ref.watch(tabDatabaseProvider);
  }

  Future<void> addContainer({required String? name, required Color color}) {
    return _db.containerDao.addContainer(name: name, color: color);
  }

  Future<void> replaceContainer({
    required String id,
    required String? name,
    required Color color,
  }) {
    return _db.containerDao.replaceContainer(id, name: name, color: color);
  }

  Future<void> deleteContainer(String id) {
    return _db.containerDao.deleteContainer(id);
  }

  Future<Set<Color>> getDistinctColors() {
    return _db.containerDao
        .getDistinctColors()
        .get()
        .then((colors) => colors.toSet());
  }

  Future<String> getLeadingOrderKey(String? containerId) {
    return _db.containerDao.generateLeadingOrderKey(containerId).getSingle();
  }

  Future<String> getTrailingOrderKey(String? containerId) {
    return _db.containerDao.generateTrailingOrderKey(containerId).getSingle();
  }

  Future<String> getOrderKeyAfterTab(String tabId, String? containerId) {
    return _db.containerDao
        .generateOrderKeyAfterTabId(containerId, tabId)
        .getSingle();
  }
}
