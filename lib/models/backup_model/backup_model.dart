import 'package:heartry/models/converters.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../database/database.dart';

part 'backup_model.g.dart';

@JsonSerializable()
class BackupModel {
  const BackupModel({
    required this.poems,
    required this.prefs,
    required this.image,
  });

  @PoemModelConverter()
  final List<PoemModel> poems;
  final Map<String, dynamic> prefs;
  final List<int>? image;

  factory BackupModel.fromJson(Map<String, dynamic> json) =>
      _$BackupModelFromJson(json);

  Map<String, dynamic> toJson() => _$BackupModelToJson(this);
}
