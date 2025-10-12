import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/models/user_profile.dart';

/// 프로필 완성도 테스트
void main() {
  group('UserProfile Completion', () {
    // 테스트용 기본 UserProfile
    final baseProfile = UserProfile(
      id: 'test-id',
      email: 'test@example.com',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('completionPercentage', () {
      test('should return 0% when no optional fields are filled', () {
        // Arrange
        final profile = baseProfile;

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(0), reason: '선택 필드가 모두 null이면 0%');
      });

      test('should return 17% when only displayName is filled (1/6)', () {
        // Arrange
        final profile = baseProfile.copyWith(displayName: 'Test User');

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(17), reason: '1/6 = 16.67% ≈ 17%');
      });

      test('should return 33% when 2 fields are filled (2/6)', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
        );

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(33), reason: '2/6 = 33.33% ≈ 33%');
      });

      test('should return 50% when 3 fields are filled (3/6)', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
        );

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(50), reason: '3/6 = 50%');
      });

      test('should return 67% when 4 fields are filled (4/6)', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
          height: 175,
        );

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(67), reason: '4/6 = 66.67% ≈ 67%');
      });

      test('should return 83% when 5 fields are filled (5/6)', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
          height: 175,
          weight: 70.0,
        );

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(83), reason: '5/6 = 83.33% ≈ 83%');
      });

      test('should return 100% when all 6 fields are filled', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
          height: 175,
          weight: 70.0,
          fitnessLevel: FitnessLevel.intermediate,
        );

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(100), reason: '6/6 = 100%');
      });

      test('should return 0% when displayName is empty string', () {
        // Arrange
        final profile = baseProfile.copyWith(displayName: '');

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(0), reason: '빈 문자열은 미입력으로 간주');
      });

      test('should return 0% when displayName is whitespace only', () {
        // Arrange
        final profile = baseProfile.copyWith(displayName: '   ');

        // Act
        final percentage = profile.completionPercentage;

        // Assert
        expect(percentage, equals(0), reason: '공백만 있으면 미입력으로 간주');
      });
    });

    group('completionMessage', () {
      test('should return appropriate message for 0%', () {
        // Arrange
        final profile = baseProfile;

        // Act
        final message = profile.completionMessage;

        // Assert
        expect(message, contains('프로필을 완성해주세요'));
      });

      test('should return appropriate message for partial completion', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
        );

        // Act
        final message = profile.completionMessage;

        // Assert
        expect(message, contains('2/6'));
      });

      test('should return appropriate message for 100%', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
          height: 175,
          weight: 70.0,
          fitnessLevel: FitnessLevel.intermediate,
        );

        // Act
        final message = profile.completionMessage;

        // Assert
        expect(message, contains('완성'));
      });
    });

    group('incompleteFields', () {
      test('should return all 6 fields when nothing is filled', () {
        // Arrange
        final profile = baseProfile;

        // Act
        final incomplete = profile.incompleteFields;

        // Assert
        expect(incomplete.length, equals(6));
        expect(incomplete, contains('닉네임'));
        expect(incomplete, contains('생년월일'));
        expect(incomplete, contains('성별'));
        expect(incomplete, contains('키'));
        expect(incomplete, contains('몸무게'));
        expect(incomplete, contains('체력 수준'));
      });

      test('should return 5 fields when 1 field is filled', () {
        // Arrange
        final profile = baseProfile.copyWith(displayName: 'Test User');

        // Act
        final incomplete = profile.incompleteFields;

        // Assert
        expect(incomplete.length, equals(5));
        expect(incomplete, isNot(contains('닉네임')));
        expect(incomplete, contains('생년월일'));
        expect(incomplete, contains('성별'));
        expect(incomplete, contains('키'));
        expect(incomplete, contains('몸무게'));
        expect(incomplete, contains('체력 수준'));
      });

      test('should return empty list when all fields are filled', () {
        // Arrange
        final profile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
          height: 175,
          weight: 70.0,
          fitnessLevel: FitnessLevel.intermediate,
        );

        // Act
        final incomplete = profile.incompleteFields;

        // Assert
        expect(incomplete, isEmpty);
      });

      test('should include 닉네임 when displayName is empty string', () {
        // Arrange
        final profile = baseProfile.copyWith(displayName: '');

        // Act
        final incomplete = profile.incompleteFields;

        // Assert
        expect(incomplete, contains('닉네임'));
        expect(incomplete.length, equals(6));
      });

      test('should include 닉네임 when displayName is whitespace only', () {
        // Arrange
        final profile = baseProfile.copyWith(displayName: '   ');

        // Act
        final incomplete = profile.incompleteFields;

        // Assert
        expect(incomplete, contains('닉네임'));
        expect(incomplete.length, equals(6));
      });
    });

    group('isComplete backward compatibility', () {
      test('should match completionPercentage == 100', () {
        // Arrange
        final completeProfile = baseProfile.copyWith(
          displayName: 'Test User',
          birthDate: DateTime(1990, 1, 1),
          gender: Gender.male,
          height: 175,
          weight: 70.0,
          fitnessLevel: FitnessLevel.intermediate,
        );

        // Act & Assert
        expect(completeProfile.isComplete, isTrue);
        expect(completeProfile.completionPercentage, equals(100));
      });

      test('should not be complete when percentage < 100', () {
        // Arrange
        final incompleteProfile = baseProfile.copyWith(
          displayName: 'Test User',
        );

        // Act & Assert
        expect(incompleteProfile.isComplete, isFalse);
        expect(incompleteProfile.completionPercentage, lessThan(100));
      });
    });
  });
}
