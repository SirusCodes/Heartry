import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/theme.dart';
import '../converters.dart';

part 'theme_detail_model.g.dart';

@JsonSerializable()
class ThemeDetailModel {
  const ThemeDetailModel({required this.themeType, required this.accentColor});

  final ThemeType themeType;

  @NullableColorConverter()
  final Color? accentColor;

  factory ThemeDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ThemeDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThemeDetailModelToJson(this);

  ThemeDetailModel removeAccentColor() {
    return ThemeDetailModel(themeType: themeType, accentColor: null);
  }

  ThemeDetailModel copyWith({ThemeType? themeType, Color? accentColor}) {
    return ThemeDetailModel(
      themeType: themeType ?? this.themeType,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  int get hashCode => themeType.hashCode ^ accentColor.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ThemeDetailModel &&
        themeType == other.themeType &&
        accentColor == other.accentColor;
  }
}
