import 'dart:convert';

// ignore_for_file: sort_constructors_first
class BackupModel {
  final String? name;
  final String? theme;
  final String? profile;

  BackupModel({
    required this.name,
    required this.theme,
    required this.profile,
  });

  BackupModel copyWith({
    String? name,
    String? theme,
    String? profile,
  }) {
    return BackupModel(
      name: name ?? this.name,
      theme: theme ?? this.theme,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'theme': theme,
      'profile': profile,
    };
  }

  factory BackupModel.fromMap(Map<String, dynamic> map) {
    return BackupModel(
      name: map['name'] as String,
      theme: map['theme'] as String,
      profile: map['profile'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BackupModel.fromJson(String source) =>
      BackupModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '''BackupModel(name: $name, theme: $theme, profile: $profile)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BackupModel &&
        other.name == name &&
        other.theme == theme &&
        other.profile == profile;
  }

  @override
  int get hashCode {
    return name.hashCode ^ theme.hashCode ^ profile.hashCode;
  }
}
