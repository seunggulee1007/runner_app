import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stride_note/services/gps_tracker_service.dart';

/// GPS 트래킹 통합 테스트
///
/// TDD 원칙:
/// 1. RED: 실패하는 테스트 작성
/// 2. GREEN: 최소 구현으로 통과
/// 3. REFACTOR: 리팩터링
///
/// NOTE: 실제 GPS 하드웨어가 필요하므로 skip 설정
void main() {
  group('GPS Tracking Integration Tests', () {
    late GPSTrackerService service;

    setUp(() {
      service = GPSTrackerService();
    });

    tearDown(() {
      service.stopLocationStream();
    });

    test('should request location permission before tracking', () async {
      // Arrange & Act
      final granted = await service.requestLocationPermission();

      // Assert
      // 실제 기기에서는 사용자 승인 필요
      expect(granted, isA<bool>());
    }, skip: true); // Requires real device

    test('should start location stream and receive position updates', () async {
      // Arrange
      final stream = service.startLocationStream();

      // Act
      final position = await stream.first;

      // Assert
      expect(position, isA<Position>());
      expect(position.latitude, isNotNull);
      expect(position.longitude, isNotNull);
    }, skip: true); // Requires GPS hardware

    test('should calculate distance between two positions', () {
      // Arrange
      final seoul = Position(
        latitude: 37.5665,
        longitude: 126.9780,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final busan = Position(
        latitude: 35.1796,
        longitude: 129.0756,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Act
      final distance = service.calculateDistance(seoul, busan);

      // Assert
      // 서울-부산 거리는 약 325km
      expect(distance, greaterThan(300000)); // 300km 이상
      expect(distance, lessThan(400000)); // 400km 이하
    });

    test('should calculate speed between two positions', () {
      // Arrange
      final now = DateTime.now();
      final pos1 = Position(
        latitude: 37.5665,
        longitude: 126.9780,
        timestamp: now,
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final pos2 = Position(
        latitude: 37.5675, // 약 111m 북쪽
        longitude: 126.9780,
        timestamp: now.add(const Duration(seconds: 10)),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Act
      final speed = service.calculateSpeed(pos1, pos2);

      // Assert
      // 111m / 10s = 11.1 m/s
      expect(speed, greaterThan(10.0));
      expect(speed, lessThan(12.0));
    });

    test('should accumulate total distance from position list', () {
      // Arrange - 3개 지점 (직선)
      final positions = [
        Position(
          latitude: 37.5665,
          longitude: 126.9780,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
        Position(
          latitude: 37.5675,
          longitude: 126.9780,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
        Position(
          latitude: 37.5685,
          longitude: 126.9780,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
      ];

      // Act
      final totalDistance = service.calculateTotalDistance(positions);

      // Assert
      // 약 222m (111m + 111m)
      expect(totalDistance, greaterThan(200));
      expect(totalDistance, lessThan(250));
    });
  });
}
