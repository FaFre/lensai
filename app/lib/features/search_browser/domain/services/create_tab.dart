import 'dart:async';

import 'package:bang_navigator/domain/entities/received_parameter.dart';
import 'package:bang_navigator/features/app_widget/domain/services/home_widget.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/modes.dart';
import 'package:bang_navigator/features/search_browser/domain/entities/sheet.dart';
import 'package:bang_navigator/features/share_intent/domain/services/sharing_intent.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'create_tab.g.dart';

final _parameterToCreateTabTransformer =
    StreamTransformer<ReceivedParameter, CreateTab>.fromHandlers(
  handleData: (parameter, sink) {
    final createTab = CreateTab(
      preferredTool: KagiTool.values
          .firstWhereOrNull((tool) => tool.name == parameter.tool),
      content: parameter.content,
    );

    if (createTab.hasParameters) {
      sink.add(createTab);
    }
  },
);

@Riverpod()
class CreateTabStream extends _$CreateTabStream {
  late StreamController<CreateTab> _streamController;

  @override
  Stream<CreateTab> build() {
    _streamController = StreamController();
    ref.onDispose(() async {
      await _streamController.close();
    });

    final sharingItentStream = ref.watch(sharingIntentStreamProvider);
    final appWidgetLaunchStream = ref.watch(appWidgetLaunchStreamProvider);

    return MergeStream([
      sharingItentStream.transform(_parameterToCreateTabTransformer),
      appWidgetLaunchStream.transform(_parameterToCreateTabTransformer),
      _streamController.stream,
    ]);
  }

  void createTab(CreateTab parameter) {
    _streamController.add(parameter);
  }
}
