import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// 사용자 프로필 데이터 모델
@JsonSerializable()
class UserProfile {
  /// 사용자 고유 ID
  final String id;

  /// 사용자 이름
  final String name;

  /// 이메일
  final String email;

  /// 프로필 이미지 URL
  final String? profileImageUrl;

  /// 생년월일
  final DateTime? birthDate;

  /// 성별
  final Gender? gender;

  /// 키 (cm)
  final double? height;

  /// 몸무게 (kg)
  final double? weight;

  /// 러닝 경험 수준
  final RunningLevel level;

  /// 주간 목표 거리 (km)
  final double weeklyGoal;

  /// 주간 목표 러닝 횟수
  final int weeklyRunGoal;

  /// 목표 페이스 (분/km)
  final double? targetPace;

  /// 선호하는 러닝 시간대
  final List<RunningTime> preferredTimes;

  /// 선호하는 러닝 장소
  final List<String> preferredLocations;

  /// 알림 설정
  final NotificationSettings notifications;

  /// 개인정보 공개 설정
  final PrivacySettings privacy;

  /// 가입일
  final DateTime createdAt;

  /// 마지막 업데이트
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.birthDate,
    this.gender,
    this.height,
    this.weight,
    required this.level,
    required this.weeklyGoal,
    required this.weeklyRunGoal,
    this.targetPace,
    required this.preferredTimes,
    required this.preferredLocations,
    required this.notifications,
    required this.privacy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 객체 생성
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

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

  /// BMI 계산
  double? get bmi {
    if (height == null || weight == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// 프로필 복사본 생성
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    DateTime? birthDate,
    Gender? gender,
    double? height,
    double? weight,
    RunningLevel? level,
    double? weeklyGoal,
    int? weeklyRunGoal,
    double? targetPace,
    List<RunningTime>? preferredTimes,
    List<String>? preferredLocations,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      level: level ?? this.level,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      weeklyRunGoal: weeklyRunGoal ?? this.weeklyRunGoal,
      targetPace: targetPace ?? this.targetPace,
      preferredTimes: preferredTimes ?? this.preferredTimes,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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

/// 러닝 경험 수준
enum RunningLevel {
  @JsonValue('beginner')
  beginner, // 초보자

  @JsonValue('intermediate')
  intermediate, // 중급자

  @JsonValue('advanced')
  advanced, // 고급자

  @JsonValue('expert')
  expert, // 전문가
}

/// 러닝 시간대
enum RunningTime {
  @JsonValue('early_morning')
  earlyMorning, // 새벽 (5-7시)

  @JsonValue('morning')
  morning, // 오전 (7-9시)

  @JsonValue('afternoon')
  afternoon, // 오후 (12-17시)

  @JsonValue('evening')
  evening, // 저녁 (17-19시)

  @JsonValue('night')
  night, // 밤 (19-22시)
}

/// 알림 설정
@JsonSerializable()
class NotificationSettings {
  /// 러닝 알림 활성화
  final bool runningReminders;

  /// 목표 달성 알림
  final bool goalAchievements;

  /// 주간 리포트 알림
  final bool weeklyReports;

  /// 친구 활동 알림
  final bool friendActivities;

  /// 마케팅 알림
  final bool marketing;

  /// 푸시 알림 시간 (시)
  final int? pushNotificationHour;

  const NotificationSettings({
    required this.runningReminders,
    required this.goalAchievements,
    required this.weeklyReports,
    required this.friendActivities,
    required this.marketing,
    this.pushNotificationHour,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  NotificationSettings copyWith({
    bool? runningReminders,
    bool? goalAchievements,
    bool? weeklyReports,
    bool? friendActivities,
    bool? marketing,
    int? pushNotificationHour,
  }) {
    return NotificationSettings(
      runningReminders: runningReminders ?? this.runningReminders,
      goalAchievements: goalAchievements ?? this.goalAchievements,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      friendActivities: friendActivities ?? this.friendActivities,
      marketing: marketing ?? this.marketing,
      pushNotificationHour: pushNotificationHour ?? this.pushNotificationHour,
    );
  }
}

/// 개인정보 공개 설정
@JsonSerializable()
class PrivacySettings {
  /// 프로필 공개 여부
  final bool isProfilePublic;

  /// 러닝 기록 공개 여부
  final bool isRunningHistoryPublic;

  /// 위치 정보 공개 여부
  final bool isLocationPublic;

  /// 친구 요청 허용
  final bool allowFriendRequests;

  const PrivacySettings({
    required this.isProfilePublic,
    required this.isRunningHistoryPublic,
    required this.isLocationPublic,
    required this.allowFriendRequests,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);

  PrivacySettings copyWith({
    bool? isProfilePublic,
    bool? isRunningHistoryPublic,
    bool? isLocationPublic,
    bool? allowFriendRequests,
  }) {
    return PrivacySettings(
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      isRunningHistoryPublic:
          isRunningHistoryPublic ?? this.isRunningHistoryPublic,
      isLocationPublic: isLocationPublic ?? this.isLocationPublic,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
    );
  }
}
