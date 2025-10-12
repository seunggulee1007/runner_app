// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunningSession _$RunningSessionFromJson(Map<String, dynamic> json) =>
    RunningSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      duration: (json['duration'] as num?)?.toInt(),
      totalDuration: (json['total_duration'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      avgPace: (json['avg_pace'] as num?)?.toDouble(),
      maxSpeed: (json['max_speed'] as num?)?.toDouble(),
      avgSpeed: (json['avg_speed'] as num?)?.toDouble(),
      calories: (json['calories'] as num?)?.toInt(),
      avgHeartRate: (json['avg_heart_rate'] as num?)?.toInt(),
      maxHeartRate: (json['max_heart_rate'] as num?)?.toInt(),
      gpsData: json['gps_data'] as Map<String, dynamic>?,
      elevationGain: (json['elevation_gain'] as num?)?.toDouble(),
      elevationLoss: (json['elevation_loss'] as num?)?.toDouble(),
      status:
          $enumDecodeNullable(_$RunningSessionStatusEnumMap, json['status']) ??
          RunningSessionStatus.inProgress,
      weatherCondition: json['weather_condition'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$RunningSessionToJson(RunningSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'duration': instance.duration,
      'total_duration': instance.totalDuration,
      'distance': instance.distance,
      'avg_pace': instance.avgPace,
      'max_speed': instance.maxSpeed,
      'avg_speed': instance.avgSpeed,
      'calories': instance.calories,
      'avg_heart_rate': instance.avgHeartRate,
      'max_heart_rate': instance.maxHeartRate,
      'gps_data': instance.gpsData,
      'elevation_gain': instance.elevationGain,
      'elevation_loss': instance.elevationLoss,
      'status': _$RunningSessionStatusEnumMap[instance.status]!,
      'weather_condition': instance.weatherCondition,
      'temperature': instance.temperature,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$RunningSessionStatusEnumMap = {
  RunningSessionStatus.inProgress: 'in_progress',
  RunningSessionStatus.paused: 'paused',
  RunningSessionStatus.completed: 'completed',
  RunningSessionStatus.cancelled: 'cancelled',
};

GPSPoint _$GPSPointFromJson(Map<String, dynamic> json) => GPSPoint(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$GPSPointToJson(GPSPoint instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'altitude': instance.altitude,
  'speed': instance.speed,
  'accuracy': instance.accuracy,
  'timestamp': instance.timestamp.toIso8601String(),
};

WeatherInfo _$WeatherInfoFromJson(Map<String, dynamic> json) => WeatherInfo(
  temperature: (json['temperature'] as num).toDouble(),
  humidity: (json['humidity'] as num).toDouble(),
  condition: json['condition'] as String,
  windSpeed: (json['windSpeed'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WeatherInfoToJson(WeatherInfo instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'condition': instance.condition,
      'windSpeed': instance.windSpeed,
    };
