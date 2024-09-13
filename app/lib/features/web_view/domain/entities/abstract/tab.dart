import 'package:drift/drift.dart';

abstract interface class ITab {
  String get id;
  Uri get url;
  String? get title;
  String? get topicId;
  Favicon? get favicon;
  Uint8List? get screenshot;
}
