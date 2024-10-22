import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

class IconDataJsonConverter
    implements JsonConverter<IconData, Map<String, dynamic>> {
  const IconDataJsonConverter();

  @override
  IconData fromJson(Map<String, dynamic> json) {
    return IconData(
      json['codePoint'] as int,
      fontFamily: json['fontFamily'] as String,
      fontPackage: json['fontPackage'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson(IconData iconData) {
    return <String, dynamic>{
      'codePoint': iconData.codePoint,
      'fontFamily': iconData.fontFamily,
      'fontPackage': iconData.fontPackage,
    };
  }
}

class IconDataTypeConverter implements TypeConverter<IconData, String> {
  const IconDataTypeConverter();

  @override
  IconData fromSql(String fromDb) {
    final json = jsonDecode(fromDb) as Map<String, dynamic>;
    return const IconDataJsonConverter().fromJson(json);
  }

  @override
  String toSql(IconData value) {
    assert(
      value.fontFamily != null,
      'Font family must be provided to identify icon',
    );

    return jsonEncode(const IconDataJsonConverter().toJson(value));
  }
}
