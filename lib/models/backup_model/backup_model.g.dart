// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupModel _$BackupModelFromJson(Map<String, dynamic> json) => BackupModel(
  poems: const PoemModelConverter().fromJson(json['poems'] as List),
  prefs: json['prefs'] as Map<String, dynamic>,
  image: (json['image'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$BackupModelToJson(BackupModel instance) =>
    <String, dynamic>{
      'poems': const PoemModelConverter().toJson(instance.poems),
      'prefs': instance.prefs,
      'image': instance.image,
    };
