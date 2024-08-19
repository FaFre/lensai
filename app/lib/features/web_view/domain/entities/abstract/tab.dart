import 'package:drift/drift.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract interface class ITab {
  String get id;
  Uri get url;
  String? get title;
  Favicon? get favicon;
  Uint8List? get screenshot;
}
