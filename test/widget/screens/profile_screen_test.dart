import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/screens/profile_screen.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    testWidgets('should display profile screen with edit button', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('프로필'), findsOneWidget);
      expect(find.text('편집'), findsOneWidget);
    });

    testWidgets('should disable all input fields when not in edit mode', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Act
      final nicknameField = tester.widget<TextField>(
        find.widgetWithText(TextField, '닉네임').first,
      );
      final heightFields = tester.widgetList<TextField>(find.byType(TextField));

      // Assert - 닉네임 필드는 비활성화되어야 함
      expect(
        nicknameField.enabled,
        isFalse,
        reason: '편집 모드가 아닐 때 닉네임 필드는 비활성화되어야 함',
      );

      // Assert - 키/몸무게 필드도 비활성화되어야 함
      for (final field in heightFields) {
        if (field.decoration?.labelText == '키 (cm)' ||
            field.decoration?.labelText == '몸무게 (kg)') {
          expect(
            field.enabled,
            isFalse,
            reason: '편집 모드가 아닐 때 신체 정보 필드는 비활성화되어야 함',
          );
        }
      }
    });

    testWidgets('should enable all input fields when in edit mode', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Act - 편집 버튼 클릭
      await tester.tap(find.text('편집'));
      await tester.pumpAndSettle();

      // Assert - 저장 버튼이 표시되어야 함
      expect(find.text('저장'), findsOneWidget);
      expect(find.text('편집'), findsNothing);

      // Assert - 모든 필드가 활성화되어야 함
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final field in textFields) {
        expect(field.enabled, isTrue, reason: '편집 모드에서 모든 필드는 활성화되어야 함');
      }
    });

    testWidgets('should show save button only in edit mode', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Assert - 초기에는 편집 버튼만 표시
      expect(find.text('편집'), findsOneWidget);
      expect(find.text('저장'), findsNothing);

      // Act - 편집 모드로 전환
      await tester.tap(find.text('편집'));
      await tester.pumpAndSettle();

      // Assert - 편집 모드에서는 저장 버튼만 표시
      expect(find.text('편집'), findsNothing);
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('should be able to select birth date in edit mode', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Act - 편집 모드로 전환
      await tester.tap(find.text('편집'));
      await tester.pumpAndSettle();

      // Assert - 생년월일 필드가 있어야 함
      expect(find.text('생년월일'), findsOneWidget);

      // Note: DatePicker 테스트는 통합 테스트에서 수행
    });

    testWidgets('should be able to select gender in edit mode', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Act - 편집 모드로 전환
      await tester.tap(find.text('편집'));
      await tester.pumpAndSettle();

      // Assert - 성별 드롭다운이 있어야 함
      expect(
        find.widgetWithText(DropdownButtonFormField<dynamic>, '성별'),
        findsOneWidget,
      );
    });

    testWidgets('should be able to select fitness level in edit mode', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      // Act - 편집 모드로 전환
      await tester.tap(find.text('편집'));
      await tester.pumpAndSettle();

      // Assert - 체력 수준 드롭다운이 있어야 함
      expect(
        find.widgetWithText(DropdownButtonFormField<dynamic>, '체력 수준'),
        findsOneWidget,
      );
    });
  });
}
