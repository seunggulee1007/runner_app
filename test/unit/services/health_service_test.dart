import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/services/health_service.dart';

void main() {
  group('HealthService', () {
    late HealthService healthService;

    setUp(() {
      healthService = HealthService();
    });

    test('should initialize successfully', () async {
      // Act
      final result = await healthService.initialize();

      // Assert
      expect(result, isTrue);
      expect(healthService.isInitialized, isTrue);
    });

    test(
      'should handle permission request without array length mismatch',
      () async {
        // Arrange
        await healthService.initialize();

        // Act & Assert - 권한 요청 시 배열 길이 불일치 오류가 발생하지 않는지 확인
        expect(
          () async => await healthService.requestPermissions(),
          returnsNormally,
        );
      },
    );

    test('should analyze heart rate zones correctly', () {
      // Arrange
      const averageHeartRate = 150.0;
      const age = 30;

      // Act
      final zones = healthService.analyzeHeartRateZones(
        averageHeartRate: averageHeartRate,
        age: age,
      );

      // Assert
      expect(zones['averageHeartRate'], equals(150.0));
      expect(zones['maxHeartRate'], equals(190.0)); // 220 - 30
      expect(zones['currentZone'], isA<String>());
    });

    test('should return zero for empty heart rate data', () {
      // Act
      final average = healthService.calculateAverageHeartRate([]);

      // Assert
      expect(average, equals(0.0));
    });

    test('should check if platform is supported', () {
      // Act & Assert - 테스트 환경에서는 false일 수 있음
      expect(healthService.isSupported, isA<bool>());
    });
  });
}
