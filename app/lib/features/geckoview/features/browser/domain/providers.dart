// ignore_for_file: use_setters_to_change_properties

import 'dart:async';

import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/topics/data/providers.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class SelectedBangTrigger extends _$SelectedBangTrigger {
  void setTrigger(String trigger) {
    state = trigger;
  }

  void clearTrigger() {
    state = null;
  }

  @override
  String? build({String? domain}) {
    return null;
  }
}

@Riverpod()
Stream<BangData?> selectedBangData(SelectedBangDataRef ref, {String? domain}) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  final selectedBangTrigger =
      ref.watch(selectedBangTriggerProvider(domain: domain));
  return repository.watchBang(selectedBangTrigger);
}

@Riverpod(keepAlive: true)
class LastUsedAssistantMode extends _$LastUsedAssistantMode {
  void update(AssistantMode mode) {
    state = mode;
  }

  @override
  AssistantMode build() {
    return AssistantMode.research;
  }
}

@Riverpod(keepAlive: true)
class ActiveResearchVariant extends _$ActiveResearchVariant {
  void update(ResearchVariant mode) {
    state = mode;
  }

  @override
  ResearchVariant build() {
    return ResearchVariant.expert;
  }
}

@Riverpod(keepAlive: true)
class ActiveChatModel extends _$ActiveChatModel {
  void update(ChatModel model) {
    state = model;
  }

  @override
  ChatModel build() {
    return ChatModel.gpt4o;
  }
}

@Riverpod(keepAlive: true)
class ShowFindInPage extends _$ShowFindInPage {
  void update(bool show) {
    state = show;
  }

  @override
  bool build() {
    return false;
  }
}

@Riverpod()
Stream<List<String>> availableTabIds(AvailableTabIdsRef ref, String? topicId) {
  final db = ref.watch(tabDatabaseProvider);
  final openTabs = ref
      .watch(
        tabStatesProvider.select(
          (states) =>
              EquatableCollection(states.keys.toSet(), immutable: false),
        ),
      )
      .collection;

  if (topicId != null) {
    return db.tabLinkDao.topicTabIds(topicId).watch().map(
          (tabIds) =>
              tabIds.where((tabId) => openTabs.contains(tabId)).toList(),
        );
  } else {
    return db.tabLinkDao.allTabIds().watch().map(
          (assignedTabIds) => openTabs
              .where((tabId) => !assignedTabIds.contains(tabId))
              .toList(),
        );
  }
}
