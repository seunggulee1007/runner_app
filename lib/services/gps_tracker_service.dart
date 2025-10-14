import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// GPS 트래킹 서비스
///
/// Geolocator를 사용하여 실시간 위치 추적 및 거리/속도 계산을 담당
class GPSTrackerService {
  StreamSubscription<Position>? _locationSubscription;

  /// 위치 서비스 활성화 확인
  ///
  /// Returns: 위치 서비스가 활성화되어 있으면 true
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 위치 권한 요청
  ///
  /// Returns: 권한이 승인되면 true, 거부되면 false
  Future<bool> requestLocationPermission() async {
    // 현재 위치 서비스 상태 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 현재 권한 상태 확인
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 권한 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// 위치 스트림 시작
  ///
  /// Returns: Position 스트림
  Stream<Position> startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // 5미터마다 업데이트
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 위치 스트림 중지
  void stopLocationStream() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// 두 위치 간 거리 계산 (미터 단위)
  ///
  /// [start] 시작 위치
  /// [end] 종료 위치
  /// Returns: 거리 (미터)
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// 두 위치 간 속도 계산 (m/s 단위)
  ///
  /// [start] 시작 위치
  /// [end] 종료 위치
  /// Returns: 속도 (m/s)
  double calculateSpeed(Position start, Position end) {
    final distance = calculateDistance(start, end);
    final timeDiff = end.timestamp.difference(start.timestamp).inSeconds;

    if (timeDiff == 0) return 0.0;

    return distance / timeDiff;
  }

  /// 위치 목록의 총 거리 계산 (미터 단위)
  ///
  /// [positions] 위치 목록
  /// Returns: 총 거리 (미터)
  double calculateTotalDistance(List<Position> positions) {
    if (positions.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < positions.length - 1; i++) {
      totalDistance += calculateDistance(positions[i], positions[i + 1]);
    }

    return totalDistance;
  }
}
