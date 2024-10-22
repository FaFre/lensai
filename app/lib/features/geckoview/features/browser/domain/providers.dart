// ignore_for_file: use_setters_to_change_properties

import 'dart:async';

import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_list.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
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
List<String> availableTabIds(
  AvailableTabIdsRef ref,
  String? containerId,
) {
  final containerTabs = ref.watch(
    containerTabIdsProvider(containerId).select((value) => value.valueOrNull),
  );
  final tabStates = ref.watch(tabListProvider);

  return containerTabs?.where((tabId) => tabStates.contains(tabId)).toList() ??
      [];
}
