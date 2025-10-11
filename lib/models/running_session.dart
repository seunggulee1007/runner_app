import 'package:json_annotation/json_annotation.dart';

part 'running_session.g.dart';

/// 러닝 세션 데이터 모델
/// GPS 기반 거리, 페이스, 시간, 고도 추적 정보를 포함
@JsonSerializable(fieldRename: FieldRename.snake)
class RunningSession {
  /// 세션 고유 ID
  final String id;

  /// 시작 시간
  final DateTime startTime;

  /// 종료 시간
  final DateTime? endTime;

  /// 총 거리 (미터)
  final double totalDistance;

  /// 총 시간 (초)
  final int totalDuration;

  /// 평균 페이스 (분/킬로미터)
  final double averagePace;

  /// 최고 속도 (km/h)
  final double maxSpeed;

  /// 평균 심박수 (BPM)
  final int? averageHeartRate;

  /// 최고 심박수 (BPM)
  final int? maxHeartRate;

  /// 칼로리 소모량
  final int? caloriesBurned;

  /// 고도 정보
  final double? elevationGain;
  final double? elevationLoss;

  /// GPS 좌표 리스트
  final List<GPSPoint> gpsPoints;

  /// 러닝 타입 (자유주행, 인터벌, 타겟페이스 등)
  final RunningType type;

  /// 날씨 정보
  final WeatherInfo? weather;

  /// 메모
  final String? notes;

  /// 생성자
  const RunningSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.totalDuration,
    required this.averagePace,
    required this.maxSpeed,
    this.averageHeartRate,
    this.maxHeartRate,
    this.caloriesBurned,
    this.elevationGain,
    this.elevationLoss,
    required this.gpsPoints,
    required this.type,
    this.weather,
    this.notes,
  });

  /// JSON에서 객체 생성
  factory RunningSession.fromJson(Map<String, dynamic> json) =>
      _$RunningSessionFromJson(json);

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$RunningSessionToJson(this);

  /// 거리를 킬로미터로 반환
  double get distanceInKm => totalDistance / 1000;

  /// 시간을 시:분:초 형식으로 반환
  String get formattedDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final seconds = totalDuration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 페이스를 분:초 형식으로 반환
  String get formattedPace {
    final minutes = averagePace.floor();
    final seconds = ((averagePace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 세션이 진행 중인지 확인
  bool get isActive => endTime == null;

  /// 세션 복사본 생성 (일부 필드 수정)
  RunningSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? totalDistance,
    int? totalDuration,
    double? averagePace,
    double? maxSpeed,
    int? averageHeartRate,
    int? maxHeartRate,
    int? caloriesBurned,
    double? elevationGain,
    double? elevationLoss,
    List<GPSPoint>? gpsPoints,
    RunningType? type,
    WeatherInfo? weather,
    String? notes,
  }) {
    return RunningSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      averagePace: averagePace ?? this.averagePace,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      gpsPoints: gpsPoints ?? this.gpsPoints,
      type: type ?? this.type,
      weather: weather ?? this.weather,
      notes: notes ?? this.notes,
    );
  }
}

/// GPS 좌표점
@JsonSerializable()
class GPSPoint {
  /// 위도
  final double latitude;

  /// 경도
  final double longitude;

  /// 고도 (미터)
  final double? altitude;

  /// 속도 (m/s)
  final double? speed;

  /// 정확도 (미터)
  final double? accuracy;

  /// 타임스탬프
  final DateTime timestamp;

  const GPSPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.accuracy,
    required this.timestamp,
  });

  factory GPSPoint.fromJson(Map<String, dynamic> json) =>
      _$GPSPointFromJson(json);

  Map<String, dynamic> toJson() => _$GPSPointToJson(this);
}

/// 러닝 타입 열거형
enum RunningType {
  @JsonValue('free')
  free, // 자유주행

  @JsonValue('interval')
  interval, // 인터벌

  @JsonValue('target_pace')
  targetPace, // 타겟페이스

  @JsonValue('endurance')
  endurance, // 지구력

  @JsonValue('speed')
  speed, // 스피드
}

/// 날씨 정보
@JsonSerializable()
class WeatherInfo {
  /// 온도 (섭씨)
  final double temperature;

  /// 습도 (%)
  final double humidity;

  /// 날씨 상태
  final String condition;

  /// 풍속 (m/s)
  final double? windSpeed;

  const WeatherInfo({
    required this.temperature,
    required this.humidity,
    required this.condition,
    this.windSpeed,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherInfoToJson(this);
}
