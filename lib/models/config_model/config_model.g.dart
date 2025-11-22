// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigModel _$ConfigModelFromJson(Map<String, dynamic> json) => ConfigModel(
  name: json['name'] as String?,
  backupEmail: json['backupEmail'] as String?,
  isAutoBackupEnabled: json['isAutoBackupEnabled'] as bool? ?? true,
  hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
  profile: json['profile'] as String?,
  lastBackup: _$JsonConverterFromJson<String, DateTime>(
    json['lastBackup'],
    const DateTimeConverter().fromJson,
  ),
  appLock: json['appLock'] as bool? ?? false,
);

Map<String, dynamic> _$ConfigModelToJson(ConfigModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'profile': instance.profile,
      'backupEmail': instance.backupEmail,
      'isAutoBackupEnabled': instance.isAutoBackupEnabled,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
      'appLock': instance.appLock,
      'lastBackup': _$JsonConverterToJson<String, DateTime>(
        instance.lastBackup,
        const DateTimeConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
