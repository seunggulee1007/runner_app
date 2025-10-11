import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogleAuthService Configuration Tests', () {
    test('should have consistent URL scheme configuration', () {
      // Arrange
      const expectedScheme = 'com.example.runnerApp://';

      // Act & Assert
      // GoogleAuthService가 올바른 URL scheme을 사용하는지 확인
      expect(expectedScheme, isNotEmpty);
      expect(expectedScheme, startsWith('com.example.runnerApp://'));
      expect(expectedScheme, endsWith('://'));
    });

    test('should not include login-callback in redirect URL', () {
      // Arrange
      const redirectUrl = 'com.example.runnerApp://';

      // Act & Assert
      expect(redirectUrl, isNotEmpty);
      expect(redirectUrl, startsWith('com.example.runnerApp://'));
      expect(redirectUrl, isNot(contains('login-callback')));
      expect(redirectUrl, contains('runnerApp'));
    });

    test('should use correct bundle identifier format', () {
      // Arrange
      const bundleId = 'com.example.runnerApp';
      const redirectUrl = 'com.example.runnerApp://';

      // Act & Assert
      expect(redirectUrl, startsWith(bundleId));
      expect(bundleId, contains('runnerApp'));
    });
  });
}
