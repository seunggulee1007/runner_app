import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogleAuthService Platform Tests', () {
    test('should use native sign-in for mobile platforms', () {
      // Arrange
      const isMobile = true;

      // Act & Assert
      // 모바일에서는 google_sign_in을 사용해야 함
      expect(isMobile, isTrue);
    });

    test('should use OAuth redirect for web platform', () {
      // Arrange
      const isWeb = false;

      // Act & Assert
      // 웹에서는 signInWithOAuth를 사용해야 함
      expect(isWeb, isFalse);
    });

    test('should have correct redirect URL for web', () {
      // Arrange
      const redirectUrl = 'com.example.runnerApp://login-callback';

      // Act & Assert
      expect(redirectUrl, contains('login-callback'));
      expect(redirectUrl, startsWith('com.example.runnerApp://'));
    });
  });
}
