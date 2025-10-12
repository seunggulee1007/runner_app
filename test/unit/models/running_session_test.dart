import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/models/running_session.dart';

/// RunningSession 모델 테스트
void main() {
  group('RunningSession', () {
    // 테스트용 기본 데이터
    final testStartTime = DateTime(2025, 10, 12, 10, 0, 0);
    final testEndTime = DateTime(2025, 10, 12, 10, 30, 0);

    group('Constructor', () {
      test('should create RunningSession with required fields', () {
        // Arrange & Act
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Assert
        expect(session.id, equals('test-id'));
        expect(session.userId, equals('user-id'));
        expect(session.startTime, equals(testStartTime));
        expect(session.status, equals(RunningSessionStatus.inProgress));
      });

      test('should create RunningSession with all optional fields', () {
        // Arrange & Act
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          endTime: testEndTime,
          duration: 1800, // 30분
          totalDuration: 1900,
          distance: 5000.0, // 5km
          avgPace: 360.0, // 6분/km
          maxSpeed: 12.0,
          avgSpeed: 10.0,
          calories: 300,
          avgHeartRate: 150,
          maxHeartRate: 170,
          elevationGain: 50.0,
          elevationLoss: 45.0,
          status: RunningSessionStatus.completed,
          createdAt: testStartTime,
          updatedAt: testEndTime,
        );

        // Assert
        expect(session.endTime, equals(testEndTime));
        expect(session.duration, equals(1800));
        expect(session.distance, equals(5000.0));
        expect(session.status, equals(RunningSessionStatus.completed));
      });
    });

    group('fromJson', () {
      test('should create RunningSession from JSON', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'user_id': 'user-id',
          'start_time': testStartTime.toIso8601String(),
          'end_time': testEndTime.toIso8601String(),
          'duration': 1800,
          'distance': 5000.0,
          'status': 'completed',
          'created_at': testStartTime.toIso8601String(),
          'updated_at': testEndTime.toIso8601String(),
        };

        // Act
        final session = RunningSession.fromJson(json);

        // Assert
        expect(session.id, equals('test-id'));
        expect(session.userId, equals('user-id'));
        expect(session.duration, equals(1800));
        expect(session.distance, equals(5000.0));
      });

      test('should handle null optional fields in JSON', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'user_id': 'user-id',
          'start_time': testStartTime.toIso8601String(),
          'created_at': testStartTime.toIso8601String(),
          'updated_at': testStartTime.toIso8601String(),
        };

        // Act
        final session = RunningSession.fromJson(json);

        // Assert
        expect(session.endTime, isNull);
        expect(session.duration, isNull);
        expect(session.distance, isNull);
      });
    });

    group('toJson', () {
      test('should convert RunningSession to JSON', () {
        // Arrange
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          duration: 1800,
          distance: 5000.0,
          status: RunningSessionStatus.completed,
          createdAt: testStartTime,
          updatedAt: testEndTime,
        );

        // Act
        final json = session.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['user_id'], equals('user-id'));
        expect(json['duration'], equals(1800));
        expect(json['distance'], equals(5000.0));
        expect(json['status'], equals('completed'));
      });
    });

    group('Calculated Properties', () {
      test(
        'should calculate avgPacePerKm when distance and duration available',
        () {
          // Arrange
          final session = RunningSession(
            id: 'test-id',
            userId: 'user-id',
            startTime: testStartTime,
            duration: 1800, // 30분 = 1800초
            distance: 5000.0, // 5km
            createdAt: testStartTime,
            updatedAt: testStartTime,
          );

          // Act
          final avgPacePerKm = session.avgPacePerKm;

          // Assert
          // 1800초 / 5km = 360초/km = 6분/km
          expect(avgPacePerKm, equals(360.0));
        },
      );

      test('should return null for avgPacePerKm when distance is null', () {
        // Arrange
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          duration: 1800,
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Act
        final avgPacePerKm = session.avgPacePerKm;

        // Assert
        expect(avgPacePerKm, isNull);
      });

      test('should return null for avgPacePerKm when distance is zero', () {
        // Arrange
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          duration: 1800,
          distance: 0.0,
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Act
        final avgPacePerKm = session.avgPacePerKm;

        // Assert
        expect(avgPacePerKm, isNull);
      });

      test('should calculate distanceInKm', () {
        // Arrange
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          distance: 5230.5, // 5.2305km
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Act
        final distanceInKm = session.distanceInKm;

        // Assert
        expect(distanceInKm, equals(5.23)); // 소수점 2자리
      });

      test('should return null for distanceInKm when distance is null', () {
        // Arrange
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Act
        final distanceInKm = session.distanceInKm;

        // Assert
        expect(distanceInKm, isNull);
      });

      test('should format duration as HH:MM:SS', () {
        // Arrange
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          duration: 3665, // 1시간 1분 5초
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Act
        final formatted = session.formattedDuration;

        // Assert
        expect(formatted, equals('01:01:05'));
      });

      test('should format pace as MM:SS per km', () {
        // Arrange
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          duration: 1800, // 30분
          distance: 5000.0, // 5km
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Act
        final formatted = session.formattedPace;

        // Assert
        // 360초/km = 6분 0초/km
        expect(formatted, equals('06:00/km'));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        final original = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: testStartTime,
          distance: 5000.0,
          createdAt: testStartTime,
          updatedAt: testStartTime,
        );

        // Act
        final updated = original.copyWith(
          distance: 6000.0,
          status: RunningSessionStatus.completed,
        );

        // Assert
        expect(updated.id, equals('test-id'));
        expect(updated.distance, equals(6000.0));
        expect(updated.status, equals(RunningSessionStatus.completed));
      });
    });
  });

  group('RunningSessionStatus', () {
    test('should have correct enum values', () {
      // Assert
      expect(RunningSessionStatus.inProgress.value, equals('in_progress'));
      expect(RunningSessionStatus.paused.value, equals('paused'));
      expect(RunningSessionStatus.completed.value, equals('completed'));
      expect(RunningSessionStatus.cancelled.value, equals('cancelled'));
    });

    test('should have Korean display names', () {
      // Assert
      expect(RunningSessionStatus.inProgress.displayName, equals('진행 중'));
      expect(RunningSessionStatus.paused.displayName, equals('일시정지'));
      expect(RunningSessionStatus.completed.displayName, equals('완료'));
      expect(RunningSessionStatus.cancelled.displayName, equals('취소됨'));
    });
  });
}
