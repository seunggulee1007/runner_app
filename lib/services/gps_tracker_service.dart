import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// GPS 위치 추적 서비스
///
/// 위치 권한 요청, 실시간 위치 추적, 거리/속도 계산을 담당합니다.
class GPSTrackerService {
  StreamSubscription<Position>? _locationSubscription;
  bool _isTracking = false;

  /// 위치 추적 중인지 여부
  bool get isTracking => _isTracking;

  /// 위치 권한 요청
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// 위치 권한 확인
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// 현재 위치 가져오기
  Future<Position> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
    } catch (e) {
      throw Exception('Failed to get current position: $e');
    }
  }

  /// 위치 스트림 시작
  Stream<Position> startLocationStream() {
    _isTracking = true;

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // 5m 이상 이동 시 업데이트
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 위치 스트림 중지
  void stopLocationStream() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTracking = false;
  }

  /// 두 위치 사이의 거리 계산 (미터)
  double calculateDistance(Position start, Position end) {
    try {
      return Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// 두 위치 사이의 속도 계산 (m/s)
  double calculateSpeed(Position start, Position end) {
    try {
      final distance = calculateDistance(start, end);
      final timeDiff = end.timestamp.difference(start.timestamp).inSeconds;

      if (timeDiff == 0) return 0.0;

      return distance / timeDiff;
    } catch (e) {
      return 0.0;
    }
  }

  /// 위치 목록으로부터 총 거리 계산 (미터)
  double calculateTotalDistance(List<Position> positions) {
    if (positions.length < 2) return 0.0;

    double totalDistance = 0.0;

    for (int i = 0; i < positions.length - 1; i++) {
      totalDistance += calculateDistance(positions[i], positions[i + 1]);
    }

    return totalDistance;
  }

  /// 위치 서비스 활성화 여부 확인
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// 위치 정확도 설정 가져오기
  LocationAccuracy getLocationAccuracy() {
    return LocationAccuracy.high;
  }

  /// 리소스 정리
  void dispose() {
    stopLocationStream();
  }
}
