import 'dart:async';

import 'package:collection/collection.dart';
import 'package:lensai/data/models/received_parameter.dart';
import 'package:lensai/features/app_widget/domain/services/home_widget.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:lensai/features/search_browser/domain/entities/sheet.dart';
import 'package:lensai/features/share_intent/domain/services/sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'create_tab.g.dart';

final _parameterToCreateTabSheetTransformer =
    StreamTransformer<ReceivedParameter, CreateTabSheet>.fromHandlers(
  handleData: (parameter, sink) {
    final createTab = CreateTabSheet(
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
  late StreamController<CreateTabSheet> _streamController;

  @override
  Stream<CreateTabSheet> build() {
    _streamController = StreamController();
    ref.onDispose(() async {
      await _streamController.close();
    });

    final sharingItentStream = ref.watch(sharingIntentStreamProvider);
    final appWidgetLaunchStream = ref.watch(appWidgetLaunchStreamProvider);

    return MergeStream([
      sharingItentStream.transform(_parameterToCreateTabSheetTransformer),
      appWidgetLaunchStream.transform(_parameterToCreateTabSheetTransformer),
      _streamController.stream,
    ]);
  }

  void createTab(CreateTabSheet parameter) {
    _streamController.add(parameter);
  }
}
