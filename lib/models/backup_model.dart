import 'dart:convert';

// ignore_for_file: sort_constructors_first
class BackupModel {
  final String? name;
  final String? theme;

  BackupModel({
    required this.name,
    required this.theme,
  });

  BackupModel copyWith({
    String? name,
    String? theme,
  }) {
    return BackupModel(
      name: name ?? this.name,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'theme': theme,
    };
  }

  factory BackupModel.fromMap(Map<String, dynamic> map) {
    return BackupModel(
      name: map['name'] as String,
      theme: map['theme'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BackupModel.fromJson(String source) =>
      BackupModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '''BackupModel(name: $name, theme: $theme)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BackupModel && other.name == name && other.theme == theme;
  }

  @override
  int get hashCode {
    return name.hashCode ^ theme.hashCode;
  }
}
