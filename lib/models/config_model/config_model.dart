import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../converters.dart';

part 'config_model.g.dart';

@JsonSerializable()
class ConfigModel extends Equatable {
  final String? name, profile, backupEmail;
  final bool isAutoBackupEnabled, hasCompletedOnboarding, appLock;
  @DateTimeConverter()
  final DateTime? lastBackup;

  const ConfigModel({
    required this.name,
    required this.backupEmail,
    this.isAutoBackupEnabled = true,
    this.hasCompletedOnboarding = false,
    this.profile,
    this.lastBackup,
    this.appLock = false,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigModelToJson(this);

  ConfigModel copyWith({
    String? name,
    String? profile,
    String? backupEmail,
    bool? isAutoBackupEnabled,
    bool? hasCompletedOnboarding,
    DateTime? lastBackup,
    bool? appLock,
  }) {
    return ConfigModel(
      name: name ?? this.name,
      profile: profile ?? this.profile,
      backupEmail: backupEmail ?? this.backupEmail,
      lastBackup: lastBackup ?? this.lastBackup,
      isAutoBackupEnabled: isAutoBackupEnabled ?? this.isAutoBackupEnabled,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      appLock: appLock ?? this.appLock,
    );
  }

  ConfigModel removeProfile() {
    return ConfigModel(
      name: name,
      profile: null,
      backupEmail: backupEmail,
      isAutoBackupEnabled: isAutoBackupEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding,
      lastBackup: lastBackup,
    );
  }

  ConfigModel removeBackupEmail() {
    return ConfigModel(
      name: name,
      profile: profile,
      backupEmail: null,
      isAutoBackupEnabled: isAutoBackupEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding,
      lastBackup: lastBackup,
    );
  }

  @override
  List<Object?> get props => [
    name,
    profile,
    backupEmail,
    isAutoBackupEnabled,
    hasCompletedOnboarding,
    lastBackup,
  ];
}
