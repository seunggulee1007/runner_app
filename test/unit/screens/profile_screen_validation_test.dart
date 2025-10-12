import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/utils/profile_validator.dart';

/// 프로필 화면 입력 검증 테스트
void main() {
  group('Profile Input Validation', () {
    group('Height validation', () {
      test('should return false when input is not a number', () {
        // Arrange
        const invalidInput = 'abc';

        // Act
        final parsedHeight = int.tryParse(invalidInput);
        final isValid = parsedHeight != null;

        // Assert
        expect(isValid, isFalse, reason: '숫자가 아닌 입력은 유효하지 않음');
      });

      test('should return false when input is empty', () {
        // Arrange
        const emptyInput = '';

        // Act
        final parsedHeight = int.tryParse(emptyInput);
        final isValid = parsedHeight != null;

        // Assert
        expect(isValid, isFalse, reason: '빈 입력은 유효하지 않음');
      });

      test('should return true when input is valid number', () {
        // Arrange
        const validInput = '175';

        // Act
        final parsedHeight = int.tryParse(validInput);
        final isValid =
            parsedHeight != null &&
            ProfileValidator.validateHeight(parsedHeight);

        // Assert
        expect(isValid, isTrue);
      });

      test('should return false when number is out of range', () {
        // Arrange
        const outOfRangeInput = '400';

        // Act
        final parsedHeight = int.tryParse(outOfRangeInput);
        final isValid =
            parsedHeight != null &&
            ProfileValidator.validateHeight(parsedHeight);

        // Assert
        expect(isValid, isFalse, reason: '범위를 벗어난 숫자는 유효하지 않음');
      });
    });

    group('Weight validation', () {
      test('should return false when input is not a number', () {
        // Arrange
        const invalidInput = 'xyz';

        // Act
        final parsedWeight = double.tryParse(invalidInput);
        final isValid = parsedWeight != null;

        // Assert
        expect(isValid, isFalse, reason: '숫자가 아닌 입력은 유효하지 않음');
      });

      test('should return false when input is empty', () {
        // Arrange
        const emptyInput = '';

        // Act
        final parsedWeight = double.tryParse(emptyInput);
        final isValid = parsedWeight != null;

        // Assert
        expect(isValid, isFalse, reason: '빈 입력은 유효하지 않음');
      });

      test('should return true when input is valid number', () {
        // Arrange
        const validInput = '70.5';

        // Act
        final parsedWeight = double.tryParse(validInput);
        final isValid =
            parsedWeight != null &&
            ProfileValidator.validateWeight(parsedWeight);

        // Assert
        expect(isValid, isTrue);
      });

      test('should return false when number is out of range', () {
        // Arrange
        const outOfRangeInput = '500';

        // Act
        final parsedWeight = double.tryParse(outOfRangeInput);
        final isValid =
            parsedWeight != null &&
            ProfileValidator.validateWeight(parsedWeight);

        // Assert
        expect(isValid, isFalse, reason: '범위를 벗어난 숫자는 유효하지 않음');
      });
    });

    group('Input parsing logic', () {
      test('should distinguish between empty and invalid input for height', () {
        // Arrange
        const emptyInput = '';
        const invalidInput = 'abc';
        const validInput = '175';

        // Act & Assert
        expect(emptyInput.isEmpty, isTrue);
        expect(int.tryParse(emptyInput), isNull);

        expect(invalidInput.isNotEmpty, isTrue);
        expect(int.tryParse(invalidInput), isNull);

        expect(validInput.isNotEmpty, isTrue);
        expect(int.tryParse(validInput), isNotNull);
      });

      test('should distinguish between empty and invalid input for weight', () {
        // Arrange
        const emptyInput = '';
        const invalidInput = 'xyz';
        const validInput = '70.5';

        // Act & Assert
        expect(emptyInput.isEmpty, isTrue);
        expect(double.tryParse(emptyInput), isNull);

        expect(invalidInput.isNotEmpty, isTrue);
        expect(double.tryParse(invalidInput), isNull);

        expect(validInput.isNotEmpty, isTrue);
        expect(double.tryParse(validInput), isNotNull);
      });
    });
  });
}
