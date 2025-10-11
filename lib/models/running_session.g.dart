// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunningSession _$RunningSessionFromJson(Map<String, dynamic> json) =>
    RunningSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      totalDistance: (json['total_distance'] as num).toDouble(),
      totalDuration: (json['total_duration'] as num).toInt(),
      averagePace: (json['average_pace'] as num).toDouble(),
      maxSpeed: (json['max_speed'] as num).toDouble(),
      averageHeartRate: (json['average_heart_rate'] as num?)?.toInt(),
      maxHeartRate: (json['max_heart_rate'] as num?)?.toInt(),
      caloriesBurned: (json['calories_burned'] as num?)?.toInt(),
      elevationGain: (json['elevation_gain'] as num?)?.toDouble(),
      elevationLoss: (json['elevation_loss'] as num?)?.toDouble(),
      gpsPoints: (json['gps_points'] as List<dynamic>)
          .map((e) => GPSPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: $enumDecode(_$RunningTypeEnumMap, json['type']),
      weather: json['weather'] == null
          ? null
          : WeatherInfo.fromJson(json['weather'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$RunningSessionToJson(RunningSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'total_distance': instance.totalDistance,
      'total_duration': instance.totalDuration,
      'average_pace': instance.averagePace,
      'max_speed': instance.maxSpeed,
      'average_heart_rate': instance.averageHeartRate,
      'max_heart_rate': instance.maxHeartRate,
      'calories_burned': instance.caloriesBurned,
      'elevation_gain': instance.elevationGain,
      'elevation_loss': instance.elevationLoss,
      'gps_points': instance.gpsPoints,
      'type': _$RunningTypeEnumMap[instance.type]!,
      'weather': instance.weather,
      'notes': instance.notes,
    };

const _$RunningTypeEnumMap = {
  RunningType.free: 'free',
  RunningType.interval: 'interval',
  RunningType.targetPace: 'target_pace',
  RunningType.endurance: 'endurance',
  RunningType.speed: 'speed',
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
