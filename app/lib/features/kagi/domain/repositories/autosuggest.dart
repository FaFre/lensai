import 'dart:async';

import 'package:lensai/features/kagi/data/services/autosuggest.dart';
import 'package:lensai/utils/lru_cache.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'autosuggest.g.dart';

@Riverpod(keepAlive: true)
class AutosuggestRepository extends _$AutosuggestRepository {
  final LRUCache<String, List<String>> _cache;

  late StreamController<String> _queryStreamController;

  AutosuggestRepository() : _cache = LRUCache(100);

  void addQuery(String query) {
    _queryStreamController.add(query);
  }

  @override
  Raw<Stream<List<String>>> build() {
    _queryStreamController = StreamController();
    ref.onDispose(() async {
      await _queryStreamController.close();
    });

    return _queryStreamController.stream
        .sampleTime(const Duration(milliseconds: 100))
        .switchMap<List<String>>(
      (query) {
        if (query.isEmpty) {
          return Stream.value([]);
        }

        final cached = _cache.get(query);
        if (cached != null) {
          return Stream.value(cached);
        }

        return ref
            .read(kagiAutosuggestServiceProvider.notifier)
            // ignore: discarded_futures
            .getSuggestions(query)
            // ignore: discarded_futures
            .then((result) {
          result.onSuccess((result) {
            _cache.set(query, result);
          });

          return result.value;
        }).asStream();
      },
    ).asBroadcastStream();
  }
}
