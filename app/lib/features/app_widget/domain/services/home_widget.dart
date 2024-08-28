import 'package:home_widget/home_widget.dart';
import 'package:lensai/domain/entities/received_parameter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'home_widget.g.dart';

@Riverpod(keepAlive: true)
FutureOr<bool> widgetPinnable(WidgetPinnableRef ref) async {
  return await HomeWidget.isRequestPinWidgetSupported() ?? false;
}

@Riverpod()
Raw<Stream<ReceivedParameter>> appWidgetLaunchStream(
  AppWidgetLaunchStreamRef ref,
) {
  // ignore: discarded_futures
  final initialStream = HomeWidget.initiallyLaunchedFromHomeWidget().asStream();

  return ConcatStream([initialStream, HomeWidget.widgetClicked])
      .whereNotNull()
      .map((uri) => ReceivedParameter(null, uri.host));
}
