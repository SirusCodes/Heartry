import 'package:json_annotation/json_annotation.dart';

import '../converters.dart';

part 'config_model.g.dart';

@JsonSerializable()
class ConfigModel {
  final String? name;
  final String? profile;
  @DateTimeConverter()
  final DateTime? lastBackup;

  ConfigModel({
    required this.name,
    this.profile,
    this.lastBackup,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigModelToJson(this);

  ConfigModel copyWith({
    String? name,
    String? profile,
    DateTime? lastBackup,
  }) {
    return ConfigModel(
      name: name ?? this.name,
      profile: profile ?? this.profile,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }
}
