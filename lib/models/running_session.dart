import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'running_session.g.dart';

/// 러닝 세션 모델
/// Supabase running_sessions 테이블과 1:1 매핑
@JsonSerializable(fieldRename: FieldRename.snake)
class RunningSession {
  /// 세션 고유 ID
  final String id;

  /// 사용자 ID
  final String userId;

  /// 시작 시간
  final DateTime startTime;

  /// 종료 시간
  final DateTime? endTime;

  /// 실제 러닝 시간 (초, 일시정지 제외)
  final int? duration;

  /// 전체 시간 (초, 일시정지 포함)
  final int? totalDuration;

  /// 거리 (미터)
  final double? distance;

  /// 평균 페이스 (초/km)
  final double? avgPace;

  /// 최고 속도 (km/h)
  final double? maxSpeed;

  /// 평균 속도 (km/h)
  final double? avgSpeed;

  /// 소모 칼로리
  final int? calories;

  /// 평균 심박수 (bpm)
  final int? avgHeartRate;

  /// 최대 심박수 (bpm)
  final int? maxHeartRate;

  /// GPS 데이터 (JSONB)
  final Map<String, dynamic>? gpsData;

  /// 누적 상승 고도 (m)
  final double? elevationGain;

  /// 누적 하강 고도 (m)
  final double? elevationLoss;

  /// 세션 상태
  final RunningSessionStatus status;

  /// 날씨 상태
  final String? weatherCondition;

  /// 온도 (°C)
  final double? temperature;

  /// 사용자 메모
  final String? notes;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  /// 생성자
  const RunningSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.duration,
    this.totalDuration,
    this.distance,
    this.avgPace,
    this.maxSpeed,
    this.avgSpeed,
    this.calories,
    this.avgHeartRate,
    this.maxHeartRate,
    this.gpsData,
    this.elevationGain,
    this.elevationLoss,
    this.status = RunningSessionStatus.inProgress,
    this.weatherCondition,
    this.temperature,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 RunningSession 생성
  factory RunningSession.fromJson(Map<String, dynamic> json) =>
      _$RunningSessionFromJson(json);

  /// RunningSession을 JSON으로 변환
  Map<String, dynamic> toJson() => _$RunningSessionToJson(this);

  /// 평균 페이스 (초/km) 계산
  /// distance와 duration이 있을 때만 계산 가능
  double? get avgPacePerKm {
    if (distance == null || duration == null || distance == 0) {
      return null;
    }
    // 거리(미터)를 km로 변환
    final distanceInKm = distance! / 1000.0;
    // 초 / km
    return duration! / distanceInKm;
  }

  /// 거리를 km로 반환 (소수점 2자리)
  double? get distanceInKm {
    if (distance == null) return null;
    return double.parse((distance! / 1000.0).toStringAsFixed(2));
  }

  /// 시간을 HH:MM:SS 형식으로 반환
  String get formattedDuration {
    if (duration == null) return '00:00:00';

    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    final seconds = duration! % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// 페이스를 MM:SS/km 형식으로 반환
  String get formattedPace {
    final pace = avgPacePerKm;
    if (pace == null) return '--:--/km';

    final minutes = pace ~/ 60;
    final seconds = (pace % 60).round();

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}/km';
  }

  /// 평균 페이스 포맷 (M'SS"/km)
  String get formattedAvgPace {
    if (avgPace == null || avgPace! <= 0) return '--\'--"';

    final minutes = avgPace! ~/ 60;
    final seconds = (avgPace! % 60).round();

    return '$minutes\'${seconds.toString().padLeft(2, '0')}"';
  }

  /// 경로 포인트 (LatLng 리스트)
  List<LatLng> get routePoints {
    if (gpsData == null) return [];

    try {
      // gpsData는 List<Map<String, dynamic>> 형태
      final points = gpsData!['points'] as List<dynamic>?;
      if (points == null) return [];

      return points.map((point) {
        final p = point as Map<String, dynamic>;
        return LatLng(p['latitude'] as double, p['longitude'] as double);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 세션 복사본 생성 (일부 필드 수정)
  RunningSession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    int? totalDuration,
    double? distance,
    double? avgPace,
    double? maxSpeed,
    double? avgSpeed,
    int? calories,
    int? avgHeartRate,
    int? maxHeartRate,
    Map<String, dynamic>? gpsData,
    double? elevationGain,
    double? elevationLoss,
    RunningSessionStatus? status,
    String? weatherCondition,
    double? temperature,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RunningSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      totalDuration: totalDuration ?? this.totalDuration,
      distance: distance ?? this.distance,
      avgPace: avgPace ?? this.avgPace,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      calories: calories ?? this.calories,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      gpsData: gpsData ?? this.gpsData,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      status: status ?? this.status,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: temperature ?? this.temperature,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 러닝 세션 상태 열거형
enum RunningSessionStatus {
  /// 진행 중
  @JsonValue('in_progress')
  inProgress,

  /// 일시정지
  @JsonValue('paused')
  paused,

  /// 완료
  @JsonValue('completed')
  completed,

  /// 취소됨
  @JsonValue('cancelled')
  cancelled,
}

/// RunningSessionStatus 확장 메서드
extension RunningSessionStatusExtension on RunningSessionStatus {
  /// 데이터베이스 저장용 값
  String get value {
    switch (this) {
      case RunningSessionStatus.inProgress:
        return 'in_progress';
      case RunningSessionStatus.paused:
        return 'paused';
      case RunningSessionStatus.completed:
        return 'completed';
      case RunningSessionStatus.cancelled:
        return 'cancelled';
    }
  }

  /// 한글 표시명
  String get displayName {
    switch (this) {
      case RunningSessionStatus.inProgress:
        return '진행 중';
      case RunningSessionStatus.paused:
        return '일시정지';
      case RunningSessionStatus.completed:
        return '완료';
      case RunningSessionStatus.cancelled:
        return '취소됨';
    }
  }
}

/// GPS 좌표점 (레거시 호환성)
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

/// 러닝 타입 열거형 (레거시 호환성)
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

/// 날씨 정보 (레거시 호환성)
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

/// 레거시 호환성을 위한 RunningSession 확장
extension RunningSessionLegacy on RunningSession {
  /// 총 거리 (레거시 필드명)
  double? get totalDistance => distance;

  /// 평균 페이스 (레거시 필드명)
  double? get averagePace => avgPace;

  /// 평균 심박수 (레거시 필드명)
  int? get averageHeartRate => avgHeartRate;

  /// 칼로리 소모량 (레거시 필드명)
  int? get caloriesBurned => calories;

  /// GPS 좌표 리스트 (빈 리스트 반환, 새 구조에서는 JSONB로 저장)
  List<GPSPoint> get gpsPoints => [];

  /// 러닝 타입 (기본값: 자유주행)
  RunningType get type => RunningType.free;

  /// 날씨 정보 (null 반환, 새 구조에서는 별도 필드로 저장)
  WeatherInfo? get weather => null;
}
