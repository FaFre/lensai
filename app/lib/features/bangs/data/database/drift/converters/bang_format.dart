import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';

class BangFormatConverter extends TypeConverter<Set<BangFormat>?, String?> {
  const BangFormatConverter();

  @override
  Set<BangFormat>? fromSql(String? fromDb) {
    if (fromDb == null) {
      return null;
    }

    return Bang.decodeFormat(jsonDecode(fromDb) as List);
  }

  @override
  String? toSql(Set<BangFormat>? value) {
    if (value == null) {
      return null;
    }

    return jsonEncode(Bang.encodeFormat(value));
  }
}
