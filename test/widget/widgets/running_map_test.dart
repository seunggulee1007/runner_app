import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/widgets/running_map.dart';
import 'package:stride_note/models/running_session.dart';

void main() {
  group('RunningMap', () {
    testWidgets(
      'should not overflow when displayed in fixed height container',
      (tester) async {
        // Arrange - 고정 높이 컨테이너에서 지도 위젯 테스트
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 180, // 러닝 화면에서 사용하는 고정 높이
                child: RunningMap(
                  gpsPoints: [
                    GPSPoint(
                      latitude: 37.5665,
                      longitude: 126.9780,
                      timestamp: DateTime.now(),
                      accuracy: 5.0,
                    ),
                  ],
                  isRunning: false,
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert - 오버플로우가 발생하지 않는지 확인
        expect(tester.takeException(), isNull);

        // 지도 대체 UI가 표시되는지 확인
        expect(find.text('지도 기능'), findsOneWidget);
        expect(find.text('GPS 경로: 1개 포인트'), findsOneWidget);
      },
    );

    testWidgets('should handle empty GPS points without overflow', (
      tester,
    ) async {
      // Arrange - 빈 GPS 포인트로 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 180,
              child: RunningMap(gpsPoints: [], isRunning: false),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 오버플로우가 발생하지 않는지 확인
      expect(tester.takeException(), isNull);

      // 빈 GPS 포인트 메시지 확인
      expect(find.text('GPS 경로: 0개 포인트'), findsOneWidget);
    });

    testWidgets('should handle very small container without overflow', (
      tester,
    ) async {
      // Arrange - 매우 작은 컨테이너에서 테스트
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 120, // 더 작은 높이
              child: RunningMap(
                gpsPoints: [
                  GPSPoint(
                    latitude: 37.5665,
                    longitude: 126.9780,
                    timestamp: DateTime.now(),
                    accuracy: 5.0,
                  ),
                ],
                isRunning: false,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 오버플로우가 발생하지 않는지 확인
      expect(tester.takeException(), isNull);
    });
  });
}

