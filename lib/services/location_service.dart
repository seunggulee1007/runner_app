import 'dart:async';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/running_session.dart';

/// GPS 위치 추적 서비스
/// 러닝 중 실시간 위치 정보를 수집하고 관리
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  final List<GPSPoint> _gpsPoints = [];
  Timer? _locationTimer;

  /// 위치 추적 상태
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// GPS 포인트 스트림
  final StreamController<List<GPSPoint>> _gpsPointsController =
      StreamController<List<GPSPoint>>.broadcast();
  Stream<List<GPSPoint>> get gpsPointsStream => _gpsPointsController.stream;

  /// 현재 위치 스트림
  final StreamController<Position> _currentPositionController =
      StreamController<Position>.broadcast();
  Stream<Position> get currentPositionStream =>
      _currentPositionController.stream;

  /// 위치 권한 요청 및 확인
  Future<bool> requestLocationPermission() async {
    try {
      // 위치 권한 상태 확인
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // 권한이 거부된 경우 요청
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // 영구적으로 거부된 경우 설정으로 이동
        await openAppSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      developer.log('위치 권한 요청 오류: $e', name: 'LocationService');
      return false;
    }
  }

  /// 위치 서비스 활성화 확인
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      developer.log('위치 서비스 확인 오류: $e', name: 'LocationService');
      return false;
    }
  }

  /// 현재 위치 가져오기
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      developer.log('현재 위치 가져오기 오류: $e', name: 'LocationService');
      return null;
    }
  }

  /// 위치 추적 시작
  Future<bool> startTracking() async {
    try {
      if (_isTracking) return true;

      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('위치 권한이 필요합니다');
      }

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        throw Exception('위치 서비스를 활성화해주세요');
      }

      _gpsPoints.clear();
      _isTracking = true;

      // 위치 스트림 시작
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5, // 5미터마다 업데이트
              timeLimit: Duration(seconds: 30),
            ),
          ).listen(
            (Position position) {
              _onLocationUpdate(position);
            },
            onError: (error) {
              developer.log('위치 추적 오류: $error', name: 'LocationService');
            },
          );

      return true;
    } catch (e) {
      developer.log('위치 추적 시작 오류: $e', name: 'LocationService');
      _isTracking = false;
      return false;
    }
  }

  /// 위치 추적 중지
  Future<void> stopTracking() async {
    try {
      _isTracking = false;
      await _positionStream?.cancel();
      _positionStream = null;
      _locationTimer?.cancel();
      _locationTimer = null;
    } catch (e) {
      developer.log('위치 추적 중지 오류: $e', name: 'LocationService');
    }
  }

  /// 위치 업데이트 처리
  void _onLocationUpdate(Position position) {
    if (!_isTracking) return;

    final gpsPoint = GPSPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      speed: position.speed,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );

    _gpsPoints.add(gpsPoint);

    // 현재 위치 스트림에 전송
    _currentPositionController.add(position);

    // GPS 포인트 스트림에 전송
    _gpsPointsController.add(List.from(_gpsPoints));
  }

  /// 수집된 GPS 포인트 가져오기
  List<GPSPoint> get gpsPoints => List.from(_gpsPoints);

  /// 총 거리 계산 (미터)
  double calculateTotalDistance() {
    if (_gpsPoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < _gpsPoints.length; i++) {
      final prevPoint = _gpsPoints[i - 1];
      final currentPoint = _gpsPoints[i];

      final distance = Geolocator.distanceBetween(
        prevPoint.latitude,
        prevPoint.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );

      totalDistance += distance;
    }

    return totalDistance;
  }

  /// 평균 속도 계산 (km/h)
  double calculateAverageSpeed() {
    if (_gpsPoints.length < 2) return 0.0;

    final totalDistance = calculateTotalDistance();
    final firstPoint = _gpsPoints.first;
    final lastPoint = _gpsPoints.last;

    final duration = lastPoint.timestamp.difference(firstPoint.timestamp);
    final durationInHours = duration.inSeconds / 3600.0;

    if (durationInHours == 0) return 0.0;

    return (totalDistance / 1000.0) / durationInHours; // km/h
  }

  /// 최고 속도 계산 (km/h)
  double calculateMaxSpeed() {
    if (_gpsPoints.isEmpty) return 0.0;

    double maxSpeed = 0.0;
    for (final point in _gpsPoints) {
      if (point.speed != null && point.speed! > maxSpeed) {
        maxSpeed = point.speed!;
      }
    }

    return maxSpeed * 3.6; // m/s to km/h
  }

  /// 고도 변화 계산
  Map<String, double> calculateElevationChange() {
    if (_gpsPoints.isEmpty) return {'gain': 0.0, 'loss': 0.0};

    double elevationGain = 0.0;
    double elevationLoss = 0.0;

    for (int i = 1; i < _gpsPoints.length; i++) {
      final prevAltitude = _gpsPoints[i - 1].altitude;
      final currentAltitude = _gpsPoints[i].altitude;

      if (prevAltitude != null && currentAltitude != null) {
        final elevationDiff = currentAltitude - prevAltitude;
        if (elevationDiff > 0) {
          elevationGain += elevationDiff;
        } else {
          elevationLoss += elevationDiff.abs();
        }
      }
    }

    return {'gain': elevationGain, 'loss': elevationLoss};
  }

  /// 리소스 정리
  void dispose() {
    stopTracking();
    _gpsPointsController.close();
    _currentPositionController.close();
  }
}
