// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
  level: $enumDecode(_$RunningLevelEnumMap, json['level']),
  weeklyGoal: (json['weeklyGoal'] as num).toDouble(),
  weeklyRunGoal: (json['weeklyRunGoal'] as num).toInt(),
  targetPace: (json['targetPace'] as num?)?.toDouble(),
  preferredTimes: (json['preferredTimes'] as List<dynamic>)
      .map((e) => $enumDecode(_$RunningTimeEnumMap, e))
      .toList(),
  preferredLocations: (json['preferredLocations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notifications: NotificationSettings.fromJson(
    json['notifications'] as Map<String, dynamic>,
  ),
  privacy: PrivacySettings.fromJson(json['privacy'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profileImageUrl': instance.profileImageUrl,
      'birthDate': instance.birthDate?.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender],
      'height': instance.height,
      'weight': instance.weight,
      'level': _$RunningLevelEnumMap[instance.level]!,
      'weeklyGoal': instance.weeklyGoal,
      'weeklyRunGoal': instance.weeklyRunGoal,
      'targetPace': instance.targetPace,
      'preferredTimes': instance.preferredTimes
          .map((e) => _$RunningTimeEnumMap[e]!)
          .toList(),
      'preferredLocations': instance.preferredLocations,
      'notifications': instance.notifications,
      'privacy': instance.privacy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const _$RunningLevelEnumMap = {
  RunningLevel.beginner: 'beginner',
  RunningLevel.intermediate: 'intermediate',
  RunningLevel.advanced: 'advanced',
  RunningLevel.expert: 'expert',
};

const _$RunningTimeEnumMap = {
  RunningTime.earlyMorning: 'early_morning',
  RunningTime.morning: 'morning',
  RunningTime.afternoon: 'afternoon',
  RunningTime.evening: 'evening',
  RunningTime.night: 'night',
};

NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => NotificationSettings(
  runningReminders: json['runningReminders'] as bool,
  goalAchievements: json['goalAchievements'] as bool,
  weeklyReports: json['weeklyReports'] as bool,
  friendActivities: json['friendActivities'] as bool,
  marketing: json['marketing'] as bool,
  pushNotificationHour: (json['pushNotificationHour'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationSettingsToJson(
  NotificationSettings instance,
) => <String, dynamic>{
  'runningReminders': instance.runningReminders,
  'goalAchievements': instance.goalAchievements,
  'weeklyReports': instance.weeklyReports,
  'friendActivities': instance.friendActivities,
  'marketing': instance.marketing,
  'pushNotificationHour': instance.pushNotificationHour,
};

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      isProfilePublic: json['isProfilePublic'] as bool,
      isRunningHistoryPublic: json['isRunningHistoryPublic'] as bool,
      isLocationPublic: json['isLocationPublic'] as bool,
      allowFriendRequests: json['allowFriendRequests'] as bool,
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'isProfilePublic': instance.isProfilePublic,
      'isRunningHistoryPublic': instance.isRunningHistoryPublic,
      'isLocationPublic': instance.isLocationPublic,
      'allowFriendRequests': instance.allowFriendRequests,
    };
