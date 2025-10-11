// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  birthDate: json['birth_date'] == null
      ? null
      : DateTime.parse(json['birth_date'] as String),
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  height: (json['height'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  fitnessLevel: $enumDecodeNullable(
    _$FitnessLevelEnumMap,
    json['fitness_level'],
  ),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'birth_date': instance.birthDate?.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender],
      'height': instance.height,
      'weight': instance.weight,
      'fitness_level': _$FitnessLevelEnumMap[instance.fitnessLevel],
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const _$FitnessLevelEnumMap = {
  FitnessLevel.beginner: 'beginner',
  FitnessLevel.intermediate: 'intermediate',
  FitnessLevel.advanced: 'advanced',
};
