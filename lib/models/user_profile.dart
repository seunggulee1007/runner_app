import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// 사용자 프로필 모델 클래스
@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? birthDate;
  final Gender? gender;
  final int? height; // cm 단위
  final double? weight; // kg 단위
  final FitnessLevel? fitnessLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.height,
    this.weight,
    this.fitnessLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// 프로필 복사본 생성 (일부 필드 수정)
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? birthDate,
    Gender? gender,
    int? height,
    double? weight,
    FitnessLevel? fitnessLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 프로필이 완성되었는지 확인
  bool get isComplete {
    return displayName != null &&
        displayName!.isNotEmpty &&
        birthDate != null &&
        gender != null &&
        height != null &&
        weight != null &&
        fitnessLevel != null;
  }

  /// 전체 필드 개수 (완성도 계산용)
  static const int _totalRequiredFields = 6;

  /// 채워진 필드 개수
  int get _filledFieldsCount {
    int count = 0;

    // 닉네임 (빈 문자열과 공백만 있는 경우 제외)
    if (displayName != null && displayName!.trim().isNotEmpty) count++;

    // 생년월일
    if (birthDate != null) count++;

    // 성별
    if (gender != null) count++;

    // 키
    if (height != null) count++;

    // 몸무게
    if (weight != null) count++;

    // 체력 수준
    if (fitnessLevel != null) count++;

    return count;
  }

  /// 프로필 완성도 퍼센트 (0-100)
  int get completionPercentage {
    return (_filledFieldsCount * 100 / _totalRequiredFields).round();
  }

  /// 프로필 완성도 메시지
  String get completionMessage {
    final percentage = completionPercentage;

    if (percentage == 0) {
      return '프로필을 완성해주세요';
    } else if (percentage == 100) {
      return '프로필 완성!';
    } else {
      return '$_filledFieldsCount/$_totalRequiredFields 항목 완료';
    }
  }

  /// 미진행 항목 목록
  List<String> get incompleteFields {
    final List<String> incomplete = [];

    if (displayName == null || displayName!.trim().isEmpty) {
      incomplete.add('닉네임');
    }
    if (birthDate == null) {
      incomplete.add('생년월일');
    }
    if (gender == null) {
      incomplete.add('성별');
    }
    if (height == null) {
      incomplete.add('키');
    }
    if (weight == null) {
      incomplete.add('몸무게');
    }
    if (fitnessLevel == null) {
      incomplete.add('체력 수준');
    }

    return incomplete;
  }

  /// BMI 계산
  double? get bmi {
    if (height == null || weight == null) return null;
    final heightInMeters = height! / 100.0;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// 나이 계산
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}

/// 성별 열거형
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}

/// 체력 수준 열거형
enum FitnessLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

/// Gender 확장 메서드
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return '남성';
      case Gender.female:
        return '여성';
      case Gender.other:
        return '기타';
    }
  }
}

/// FitnessLevel 확장 메서드
extension FitnessLevelExtension on FitnessLevel {
  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return '초급';
      case FitnessLevel.intermediate:
        return '중급';
      case FitnessLevel.advanced:
        return '고급';
    }
  }
}
