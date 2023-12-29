// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupModel _$BackupModelFromJson(Map<String, dynamic> json) => BackupModel(
      poems: const PoemModelConverter().fromJson(json['poems'] as List),
      theme: ThemeDetailModel.fromJson(json['theme'] as Map<String, dynamic>),
      config: ConfigModel.fromJson(json['config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BackupModelToJson(BackupModel instance) =>
    <String, dynamic>{
      'poems': const PoemModelConverter().toJson(instance.poems),
      'theme': instance.theme,
      'config': instance.config,
    };

ConfigModel _$ConfigModelFromJson(Map<String, dynamic> json) => ConfigModel(
      name: json['name'] as String,
      image: (json['image'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );

Map<String, dynamic> _$ConfigModelToJson(ConfigModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'image': instance.image,
    };
