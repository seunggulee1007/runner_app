import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stride_note/providers/auth_provider.dart';
import 'package:stride_note/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets(
      'should not overflow when stat chips are displayed in small screen',
      (tester) async {
        // Arrange - 작은 화면 크기로 설정
        await tester.binding.setSurfaceSize(const Size(320, 600));

        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        );

        // Act - 화면이 완전히 렌더링될 때까지 대기
        await tester.pumpAndSettle();

        // Assert - 오버플로우가 발생하지 않는지 확인
        expect(tester.takeException(), isNull);

        // 통계 칩들이 화면에 표시되는지 확인
        expect(find.text('거리: 5.2km'), findsOneWidget);
        expect(find.text('시간: 28:45'), findsOneWidget);
        expect(find.text('페이스: 5:32'), findsOneWidget);
      },
    );

    testWidgets(
      'should display all stat chips without overflow in very small screen',
      (tester) async {
        // Arrange - 매우 작은 화면 크기로 설정 (iPhone SE 크기)
        await tester.binding.setSurfaceSize(const Size(320, 568));

        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert - 오버플로우가 발생하지 않는지 확인
        expect(tester.takeException(), isNull);

        // 모든 통계 칩이 표시되는지 확인 (여러 개의 세션 카드가 있으므로 여러 개 찾기)
        expect(find.textContaining('거리:'), findsWidgets);
        expect(find.textContaining('시간:'), findsWidgets);
        expect(find.textContaining('페이스:'), findsWidgets);
      },
    );

    testWidgets(
      'should handle multiple recent session cards without overflow',
      (tester) async {
        // Arrange
        await tester.binding.setSurfaceSize(const Size(320, 600));

        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert - 여러 세션 카드가 모두 표시되는지 확인
        expect(find.text('2024년 1월 15일'), findsOneWidget);
        expect(find.text('2024년 1월 13일'), findsOneWidget);
        expect(find.text('2024년 1월 11일'), findsOneWidget);

        // 오버플로우가 발생하지 않는지 확인
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('should handle very long text in stat chips without overflow', (
      tester,
    ) async {
      // Arrange - 매우 작은 화면 크기로 설정
      await tester.binding.setSurfaceSize(const Size(280, 600));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 오버플로우가 발생하지 않는지 확인
      expect(tester.takeException(), isNull);

      // 모든 통계 칩이 표시되는지 확인
      expect(find.textContaining('거리:'), findsWidgets);
      expect(find.textContaining('시간:'), findsWidgets);
      expect(find.textContaining('페이스:'), findsWidgets);
    });

    testWidgets('should display greeting message correctly', (tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 인사말이 표시되는지 확인
      expect(find.textContaining('오늘도 건강한 러닝을 시작해보세요'), findsOneWidget);

      // 오버플로우가 발생하지 않는지 확인
      expect(tester.takeException(), isNull);
    });
  });
}
