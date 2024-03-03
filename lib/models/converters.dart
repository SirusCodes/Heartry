import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../database/database.dart';

class DateTimeConverter extends JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

class NullableColorConverter extends JsonConverter<Color?, int?> {
  const NullableColorConverter();

  @override
  Color? fromJson(int? json) => json != null ? Color(json) : null;

  @override
  int? toJson(Color? object) => object?.value;
}

class PoemModelConverter extends JsonConverter<List<PoemModel>, List> {
  const PoemModelConverter();

  @override
  List<PoemModel> fromJson(List json) {
    return json.map((e) => PoemModel.fromJson(e)).toList();
  }

  @override
  List toJson(List<PoemModel> object) {
    return object.map((e) => e.toJson()).toList();
  }
}
