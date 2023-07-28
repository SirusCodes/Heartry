// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeDetailModel _$ThemeDetailModelFromJson(Map<String, dynamic> json) =>
    ThemeDetailModel(
      themeType: $enumDecode(_$ThemeTypeEnumMap, json['themeType']),
      accentColor:
          const NullableColorConverter().fromJson(json['accentColor'] as int?),
    );

Map<String, dynamic> _$ThemeDetailModelToJson(ThemeDetailModel instance) =>
    <String, dynamic>{
      'themeType': _$ThemeTypeEnumMap[instance.themeType]!,
      'accentColor':
          const NullableColorConverter().toJson(instance.accentColor),
    };

const _$ThemeTypeEnumMap = {
  ThemeType.light: 'light',
  ThemeType.dark: 'dark',
  ThemeType.black: 'black',
  ThemeType.system: 'system',
};
