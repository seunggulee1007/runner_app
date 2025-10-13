import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/services/gps_tracker_service.dart';
import 'package:geolocator/geolocator.dart';

/// GPSTrackerService 테스트
void main() {
  group('GPSTrackerService', () {
    late GPSTrackerService service;

    setUp(() {
      service = GPSTrackerService();
    });

    group('Permission Handling', () {
      test('should request location permission', () async {
        // Arrange & Act
        final hasPermission = await service.requestLocationPermission();

        // Assert
        expect(hasPermission, isA<bool>());
      });

      test('should check if location permission is granted', () async {
        // Arrange & Act
        final isGranted = await service.hasLocationPermission();

        // Assert
        expect(isGranted, isA<bool>());
      });
    });

    group('Location Tracking', () {
      test(
        'should get current position',
        () async {
          // NOTE: 실제 플랫폼 바인딩이 필요하므로 통합 테스트로 이동 필요
          // 단위 테스트에서는 메서드 존재 여부만 확인
          expect(service.getCurrentPosition, isA<Function>());
        },
        skip: 'Requires platform binding - moved to integration tests',
      );

      test('should start location stream', () async {
        // Arrange & Act
        final stream = service.startLocationStream();

        // Assert
        expect(stream, isA<Stream<Position>>());
      });

      test('should stop location stream', () async {
        // Arrange
        service.startLocationStream();

        // Act
        service.stopLocationStream();

        // Assert
        // 스트림이 취소되었는지 확인
        expect(service.isTracking, isFalse);
      });

      test('should calculate distance between two positions in meters', () {
        // Arrange
        final position1 = Position(
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

        final position2 = Position(
          latitude: 37.5675,
          longitude: 126.9790,
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
        final distance = service.calculateDistance(position1, position2);

        // Assert
        expect(distance, greaterThan(0)); // 거리는 양수
        expect(distance, lessThan(200)); // 서울 시내 짧은 거리 (~150m)
      });

      test('should return 0 when calculating distance for same position', () {
        // Arrange
        final position = Position(
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

        // Act
        final distance = service.calculateDistance(position, position);

        // Assert
        expect(distance, equals(0));
      });

      test('should calculate speed from two positions in m/s', () {
        // Arrange
        final now = DateTime.now();
        final position1 = Position(
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

        final position2 = Position(
          latitude: 37.5675,
          longitude: 126.9790,
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
        final speed = service.calculateSpeed(position1, position2);

        // Assert
        expect(speed, greaterThan(0)); // 속도는 양수
        expect(speed, lessThan(50)); // 현실적인 러닝 속도 (< 180 km/h)
      });

      test('should return 0 speed when time difference is 0', () {
        // Arrange
        final now = DateTime.now();
        final position1 = Position(
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

        final position2 = Position(
          latitude: 37.5675,
          longitude: 126.9790,
          timestamp: now, // 같은 시간
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        // Act
        final speed = service.calculateSpeed(position1, position2);

        // Assert
        expect(speed, equals(0));
      });

      test('should accumulate total distance from position list', () {
        // Arrange
        final now = DateTime.now();
        final positions = [
          Position(
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
          ),
          Position(
            latitude: 37.5675,
            longitude: 126.9790,
            timestamp: now.add(const Duration(seconds: 10)),
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
            longitude: 126.9800,
            timestamp: now.add(const Duration(seconds: 20)),
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
        expect(totalDistance, greaterThan(0));
        expect(totalDistance, lessThan(500)); // 3개 지점 총 거리 < 500m
      });

      test('should return 0 for empty position list', () {
        // Arrange
        final positions = <Position>[];

        // Act
        final totalDistance = service.calculateTotalDistance(positions);

        // Assert
        expect(totalDistance, equals(0));
      });

      test('should return 0 for single position', () {
        // Arrange
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
        ];

        // Act
        final totalDistance = service.calculateTotalDistance(positions);

        // Assert
        expect(totalDistance, equals(0));
      });
    });

    group('Location Settings', () {
      test('should check if location service is enabled', () async {
        // Arrange & Act
        final isEnabled = await service.isLocationServiceEnabled();

        // Assert
        expect(isEnabled, isA<bool>());
      });

      test('should get location accuracy settings', () {
        // Arrange & Act
        final accuracy = service.getLocationAccuracy();

        // Assert
        expect(accuracy, isA<LocationAccuracy>());
      });
    });
  });
}
