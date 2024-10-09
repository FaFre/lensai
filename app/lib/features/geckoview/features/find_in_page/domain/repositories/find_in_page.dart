import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'find_in_page.g.dart';

@Riverpod()
class FindInPageRepository extends _$FindInPageRepository {
  late GeckoFindInPageService _service;

  @override
  void build(String? tabId) {
    _service = (tabId != null)
        ? GeckoFindInPageService(tabId: tabId)
        : GeckoFindInPageService.forActiveTab();
  }

  Future<void> findAll({required String text}) {
    return _service.findAll(text);
  }

  Future<void> findNext({bool forward = true}) {
    return _service.findNext(forward);
  }

  Future<void> clearMatches() {
    return _service.clearMatches();
  }
}
