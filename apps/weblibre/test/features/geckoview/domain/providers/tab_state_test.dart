import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart'
    show ReaderableState;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';

/// Holds [getTabDataById] open so a test decides when the database answers.
class _TabDataRepository extends TabDataRepository {
  final result = Completer<TabData?>();
  final requestedIds = <String>[];

  @override
  void build() {}

  @override
  Future<TabData?> getTabDataById(String tabId) {
    requestedIds.add(tabId);
    return result.future;
  }
}

class _EngineReadyState extends EngineReadyState {
  @override
  bool build() => false;
}

typedef _Harness = ({
  GeckoEventService events,
  _TabDataRepository repository,
  ProviderContainer container,
});

_Harness _setUpHarness() {
  final events = GeckoEventService.setUp();
  final repository = _TabDataRepository();
  final container = ProviderContainer(
    overrides: [
      eventServiceProvider.overrideWithValue(events),
      tabDataRepositoryProvider.overrideWith(() => repository),
      engineReadyStateProvider.overrideWith(_EngineReadyState.new),
    ],
  );
  addTearDown(() async {
    container.dispose();
    await events.dispose();
  });

  return (events: events, repository: repository, container: container);
}

TabContentState _contentState({String? contextId, bool isPrivate = false}) =>
    TabContentState(
      id: 'tab',
      contextId: contextId,
      url: 'about:blank',
      title: '',
      progress: 0,
      isPrivate: isPrivate,
      isFullScreen: false,
      isLoading: false,
      showToolbarAsExpanded: false,
    );

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  // Each seed below leaves an entry whose fields are indistinguishable from a
  // regular about:blank tab, which is why the flag and not the fields decides
  // whether the tab may be acted on.
  for (final seed in ['security', 'icon', 'readerable']) {
    for (final (name, mode, contextId, isPrivate) in [
      ('a private', TabMode.private, 'private-context', true),
      ('an isolated', TabMode.isolated('iso1_test'), 'iso1_test', false),
      ('a regular', TabMode.regular, null, false),
    ]) {
      test('$seed state does not stand in for $name tab', () async {
        final (:events, :repository, :container) = _setUpHarness();

        final emissions = <TabState>[];
        container.listen(
          tabStatesProvider,
          (_, states) => emissions.add(states['tab']!),
        );

        var awaited = false;
        final pending = container
            .read(tabStatesProvider.notifier)
            .awaitContentState('tab')
            .whenComplete(() => awaited = true);

        switch (seed) {
          case 'security':
            events.onSecurityInfoStateChange(
              1,
              'tab',
              SecurityInfoState(secure: true, host: 'example.com', issuer: ''),
            );
          case 'icon':
            events.onIconChange(1, 'tab', null);
          case 'readerable':
            events.onReaderableStateChange(
              1,
              'tab',
              ReaderableState(readerable: true, active: false),
            );
        }
        await pumpEventQueue();

        final partial = container.read(tabStatesProvider)['tab']!;
        expect(partial.hasContentState, isFalse);
        expect(partial.tabMode, TabMode.regular);
        expect(partial.contextId, isNull);
        expect(emissions, [partial]);
        expect(awaited, isFalse);
        expect(repository.requestedIds, isEmpty);

        events.onTabContentStateChange(
          2,
          _contentState(contextId: contextId, isPrivate: isPrivate),
        );
        await pumpEventQueue();

        // The content event on its own is not the tab either: it is applied on
        // top of whatever the database holds for the tab, and that read is
        // still outstanding.
        expect(repository.requestedIds, ['tab']);
        expect(container.read(tabStatesProvider)['tab'], same(partial));
        expect(emissions, [partial]);
        expect(awaited, isFalse);

        repository.result.complete(null);
        await pumpEventQueue();

        final ready = container.read(tabStatesProvider)['tab']!;
        expect(ready.hasContentState, isTrue);
        expect(ready.tabMode, mode);
        expect(ready.contextId, contextId);
        expect(emissions, [partial, ready]);
        expect(await pending, same(ready));
      });
    }
  }

  test('a tab that already has content is returned without waiting', () async {
    final (:events, :repository, :container) = _setUpHarness();

    // Read first: the provider only subscribes to the event service once it is
    // built, and building it is what this read does.
    container.read(tabStatesProvider);
    events.onTabContentStateChange(1, _contentState());
    repository.result.complete(null);
    await pumpEventQueue();

    final ready = container.read(tabStatesProvider)['tab']!;
    expect(ready.hasContentState, isTrue);
    expect(
      await container
          .read(tabStatesProvider.notifier)
          .awaitContentState('tab', timeout: Duration.zero),
      same(ready),
    );
  });

  test('a tab the engine never reports gives up', () async {
    final (events: _, repository: _, :container) = _setUpHarness();

    expect(
      await container
          .read(tabStatesProvider.notifier)
          .awaitContentState('tab', timeout: Duration.zero),
      isNull,
    );
  });

  test('disposal releases everything still waiting', () async {
    final (events: _, repository: _, :container) = _setUpHarness();

    final pending = container
        .read(tabStatesProvider.notifier)
        .awaitContentState('tab');
    container.dispose();

    expect(await pending, isNull);
  });
}
