/// JSON 타입 정의
typedef Json = Object?;

/// Supabase 데이터베이스 타입 정의
/// MCP를 통해 자동 생성된 타입을 Dart로 변환

/// 데이터베이스 스키마 정의
class Database {
  static const String postgrestVersion = "13.0.5";
}

/// UserProfile 테이블의 행 타입
class UserProfileRow {
  final String? avatarUrl;
  final String? birthDate;
  final String? createdAt;
  final String? displayName;
  final String email;
  final String? fitnessLevel;
  final String? gender;
  final int? height;
  final String id;
  final String? updatedAt;
  final double? weight;

  const UserProfileRow({
    this.avatarUrl,
    this.birthDate,
    this.createdAt,
    this.displayName,
    required this.email,
    this.fitnessLevel,
    this.gender,
    this.height,
    required this.id,
    this.updatedAt,
    this.weight,
  });

  factory UserProfileRow.fromJson(Map<String, dynamic> json) {
    return UserProfileRow(
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] as String?,
      createdAt: json['created_at'] as String?,
      displayName: json['display_name'] as String?,
      email: json['email'] as String,
      fitnessLevel: json['fitness_level'] as String?,
      gender: json['gender'] as String?,
      height: json['height'] as int?,
      id: json['id'] as String,
      updatedAt: json['updated_at'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'birth_date': birthDate,
      'created_at': createdAt,
      'display_name': displayName,
      'email': email,
      'fitness_level': fitnessLevel,
      'gender': gender,
      'height': height,
      'id': id,
      'updated_at': updatedAt,
      'weight': weight,
    };
  }
}

/// UserProfile 테이블의 삽입 타입
class UserProfileInsert {
  final String? avatarUrl;
  final String? birthDate;
  final String? createdAt;
  final String? displayName;
  final String email;
  final String? fitnessLevel;
  final String? gender;
  final int? height;
  final String id;
  final String? updatedAt;
  final double? weight;

  const UserProfileInsert({
    this.avatarUrl,
    this.birthDate,
    this.createdAt,
    this.displayName,
    required this.email,
    this.fitnessLevel,
    this.gender,
    this.height,
    required this.id,
    this.updatedAt,
    this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'birth_date': birthDate,
      'created_at': createdAt,
      'display_name': displayName,
      'email': email,
      'fitness_level': fitnessLevel,
      'gender': gender,
      'height': height,
      'id': id,
      'updated_at': updatedAt,
      'weight': weight,
    };
  }
}

/// UserProfile 테이블의 업데이트 타입
class UserProfileUpdate {
  final String? avatarUrl;
  final String? birthDate;
  final String? createdAt;
  final String? displayName;
  final String? email;
  final String? fitnessLevel;
  final String? gender;
  final int? height;
  final String? id;
  final String? updatedAt;
  final double? weight;

  const UserProfileUpdate({
    this.avatarUrl,
    this.birthDate,
    this.createdAt,
    this.displayName,
    this.email,
    this.fitnessLevel,
    this.gender,
    this.height,
    this.id,
    this.updatedAt,
    this.weight,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (avatarUrl != null) json['avatar_url'] = avatarUrl;
    if (birthDate != null) json['birth_date'] = birthDate;
    if (createdAt != null) json['created_at'] = createdAt;
    if (displayName != null) json['display_name'] = displayName;
    if (email != null) json['email'] = email;
    if (fitnessLevel != null) json['fitness_level'] = fitnessLevel;
    if (gender != null) json['gender'] = gender;
    if (height != null) json['height'] = height;
    if (id != null) json['id'] = id;
    if (updatedAt != null) json['updated_at'] = updatedAt;
    if (weight != null) json['weight'] = weight;
    return json;
  }
}
