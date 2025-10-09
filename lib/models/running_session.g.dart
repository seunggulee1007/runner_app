// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunningSession _$RunningSessionFromJson(Map<String, dynamic> json) =>
    RunningSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalDuration: (json['totalDuration'] as num).toInt(),
      averagePace: (json['averagePace'] as num).toDouble(),
      maxSpeed: (json['maxSpeed'] as num).toDouble(),
      averageHeartRate: (json['averageHeartRate'] as num?)?.toInt(),
      maxHeartRate: (json['maxHeartRate'] as num?)?.toInt(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt(),
      elevationGain: (json['elevationGain'] as num?)?.toDouble(),
      elevationLoss: (json['elevationLoss'] as num?)?.toDouble(),
      gpsPoints: (json['gpsPoints'] as List<dynamic>)
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
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'totalDistance': instance.totalDistance,
      'totalDuration': instance.totalDuration,
      'averagePace': instance.averagePace,
      'maxSpeed': instance.maxSpeed,
      'averageHeartRate': instance.averageHeartRate,
      'maxHeartRate': instance.maxHeartRate,
      'caloriesBurned': instance.caloriesBurned,
      'elevationGain': instance.elevationGain,
      'elevationLoss': instance.elevationLoss,
      'gpsPoints': instance.gpsPoints,
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
