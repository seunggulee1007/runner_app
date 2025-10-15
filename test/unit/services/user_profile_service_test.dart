import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/models/user_profile.dart';

/// UserProfile 모델 단위 테스트
void main() {
  group('UserProfile Model', () {
    test('should create UserProfile with all required fields', () {
      // Arrange
      const id = 'test-user-id';
      const email = 'test@example.com';
      const displayName = 'Test User';
      final birthDate = DateTime(1990, 1, 1);
      const gender = Gender.male;
      const height = 175;
      const weight = 70.0;
      const fitnessLevel = FitnessLevel.intermediate;
      final createdAt = DateTime.now();
      final updatedAt = DateTime.now();

      // Act
      final profile = UserProfile(
        id: id,
        email: email,
        displayName: displayName,
        birthDate: birthDate,
        gender: gender,
        height: height,
        weight: weight,
        fitnessLevel: fitnessLevel,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(profile.id, equals(id));
      expect(profile.email, equals(email));
      expect(profile.displayName, equals(displayName));
      expect(profile.birthDate, equals(birthDate));
      expect(profile.gender, equals(gender));
      expect(profile.height, equals(height));
      expect(profile.weight, equals(weight));
      expect(profile.fitnessLevel, equals(fitnessLevel));
      expect(profile.createdAt, equals(createdAt));
      expect(profile.updatedAt, equals(updatedAt));
    });

    test('should calculate BMI correctly', () {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        height: 175,
        weight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final bmi = profile.bmi;

      // Assert
      expect(bmi, isNotNull);
      expect(bmi, closeTo(22.86, 0.01)); // 70 / (1.75 * 1.75) = 22.86
    });

    test('should return null BMI when height or weight is missing', () {
      // Arrange
      final profileWithoutHeight = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        weight: 70.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final profileWithoutWeight = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        height: 175,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(profileWithoutHeight.bmi, isNull);
      expect(profileWithoutWeight.bmi, isNull);
    });

    test('should calculate age correctly', () {
      // Arrange
      final birthDate = DateTime(1990, 1, 1);
      final profile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        birthDate: birthDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final age = profile.age;

      // Assert
      expect(age, isNotNull);
      expect(age, greaterThan(30)); // 1990년생이므로 30세 이상
    });

    test('should return null age when birthDate is missing', () {
      // Arrange
      final profile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(profile.age, isNull);
    });

    test('should check profile completeness correctly', () {
      // Arrange - 완전한 프로필
      final completeProfile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        birthDate: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175,
        weight: 70.0,
        fitnessLevel: FitnessLevel.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Arrange - 불완전한 프로필
      final incompleteProfile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(completeProfile.isComplete, isTrue);
      expect(incompleteProfile.isComplete, isFalse);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final originalProfile = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Original Name',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final updatedProfile = originalProfile.copyWith(
        displayName: 'Updated Name',
        height: 180,
      );

      // Assert
      expect(updatedProfile.displayName, equals('Updated Name'));
      expect(updatedProfile.height, equals(180));
      expect(updatedProfile.email, equals('test@example.com')); // 변경되지 않음
      expect(updatedProfile.id, equals('test-id')); // 변경되지 않음
    });
  });

  group('Gender Extension', () {
    test('should return correct display names', () {
      // Act & Assert
      expect(Gender.male.displayName, equals('남성'));
      expect(Gender.female.displayName, equals('여성'));
      expect(Gender.other.displayName, equals('기타'));
    });
  });

  group('FitnessLevel Extension', () {
    test('should return correct display names', () {
      // Act & Assert
      expect(FitnessLevel.beginner.displayName, equals('초급'));
      expect(FitnessLevel.intermediate.displayName, equals('중급'));
      expect(FitnessLevel.advanced.displayName, equals('고급'));
    });
  });
}
