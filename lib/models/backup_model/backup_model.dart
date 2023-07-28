import 'package:heartry/models/converters.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../database/database.dart';
import '../theme_detail_model/theme_detail_model.dart';

part 'backup_model.g.dart';

@JsonSerializable()
class BackupModel {
  const BackupModel({
    required this.poems,
    required this.theme,
    required this.config,
  });

  @PoemModelConverter()
  final List<PoemModel> poems;
  final ThemeDetailModel theme;
  final ConfigModel config;

  factory BackupModel.fromJson(Map<String, dynamic> json) =>
      _$BackupModelFromJson(json);

  Map<String, dynamic> toJson() => _$BackupModelToJson(this);
}

@JsonSerializable()
class ConfigModel {
  const ConfigModel({
    required this.name,
    required this.image,
  });

  final String name;
  final List<int>? image;

  factory ConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigModelToJson(this);
}
