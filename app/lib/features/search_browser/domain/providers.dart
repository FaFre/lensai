// ignore_for_file: use_setters_to_change_properties

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/search_browser/domain/entities/modes.dart';
import 'package:lensai/features/search_browser/domain/entities/sheet.dart';
import 'package:lensai/features/search_browser/domain/services/create_tab.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'providers.g.dart';

@Riverpod()
class OverlayDialog extends _$OverlayDialog {
  @override
  Widget? build() {
    return null;
  }

  void show(Widget dialog) {
    state = dialog;
  }

  void dismiss() {
    state = null;
  }
}

@Riverpod()
class BottomSheet extends _$BottomSheet {
  @override
  Sheet? build() {
    //Don't use select here because it will only fire on new != previous
    return ref.watch(createTabStreamProvider).valueOrNull;
  }

  void show(Sheet sheet) {
    state = sheet;
  }

  void dismiss() {
    state = null;
  }
}

@Riverpod(keepAlive: true)
class BottomSheetExtend extends _$BottomSheetExtend {
  late StreamController<double> _extentStreamController;

  void add(double extent) {
    _extentStreamController.add(extent);
  }

  @override
  Stream<double> build() {
    _extentStreamController = StreamController();
    ref.onDispose(() async {
      await _extentStreamController.close();
    });

    return _extentStreamController.stream
        .sampleTime(const Duration(milliseconds: 50));
  }
}

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
