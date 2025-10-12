import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/utils/profile_validator.dart';

void main() {
  group('ProfileValidator', () {
    group('validateDisplayName', () {
      test('should return true when valid display name provided', () {
        // Arrange
        const displayName = 'John Doe';

        // Act
        final result = ProfileValidator.validateDisplayName(displayName);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when display name is empty', () {
        // Arrange
        const displayName = '';

        // Act
        final result = ProfileValidator.validateDisplayName(displayName);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when display name is too long', () {
        // Arrange
        final displayName = 'a' * 51; // 51자

        // Act
        final result = ProfileValidator.validateDisplayName(displayName);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when display name is exactly 50 characters', () {
        // Arrange
        final displayName = 'a' * 50; // 50자 (경계값)

        // Act
        final result = ProfileValidator.validateDisplayName(displayName);

        // Assert
        expect(result, isTrue);
      });
    });

    group('validateHeight', () {
      test('should return true when valid height provided', () {
        // Arrange
        const height = 175;

        // Act
        final result = ProfileValidator.validateHeight(height);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when height is too low', () {
        // Arrange
        const height = 49; // 50 미만

        // Act
        final result = ProfileValidator.validateHeight(height);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when height is too high', () {
        // Arrange
        const height = 301; // 300 초과

        // Act
        final result = ProfileValidator.validateHeight(height);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when height is exactly 50 cm (lower bound)', () {
        // Arrange
        const height = 50; // 경계값

        // Act
        final result = ProfileValidator.validateHeight(height);

        // Assert
        expect(result, isTrue);
      });

      test(
        'should return true when height is exactly 300 cm (upper bound)',
        () {
          // Arrange
          const height = 300; // 경계값

          // Act
          final result = ProfileValidator.validateHeight(height);

          // Assert
          expect(result, isTrue);
        },
      );
    });

    group('validateWeight', () {
      test('should return true when valid weight provided', () {
        // Arrange
        const weight = 70.5;

        // Act
        final result = ProfileValidator.validateWeight(weight);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when weight is too low', () {
        // Arrange
        const weight = 19.9; // 20 미만

        // Act
        final result = ProfileValidator.validateWeight(weight);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when weight is too high', () {
        // Arrange
        const weight = 300.1; // 300 초과

        // Act
        final result = ProfileValidator.validateWeight(weight);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when weight is exactly 20 kg (lower bound)', () {
        // Arrange
        const weight = 20.0; // 경계값

        // Act
        final result = ProfileValidator.validateWeight(weight);

        // Assert
        expect(result, isTrue);
      });

      test(
        'should return true when weight is exactly 300 kg (upper bound)',
        () {
          // Arrange
          const weight = 300.0; // 경계값

          // Act
          final result = ProfileValidator.validateWeight(weight);

          // Assert
          expect(result, isTrue);
        },
      );
    });

    group('validateEmail', () {
      test('should return true when valid email provided', () {
        // Arrange
        const email = 'test@example.com';

        // Act
        final result = ProfileValidator.validateEmail(email);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when email is invalid', () {
        // Arrange
        const email = 'invalid-email';

        // Act
        final result = ProfileValidator.validateEmail(email);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when email is empty', () {
        // Arrange
        const email = '';

        // Act
        final result = ProfileValidator.validateEmail(email);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when email has subdomain', () {
        // Arrange
        const email = 'user@mail.example.com';

        // Act
        final result = ProfileValidator.validateEmail(email);

        // Assert
        expect(result, isTrue);
      });
    });
  });
}
