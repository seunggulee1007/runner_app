import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stride_note/screens/running_screen.dart';
import 'package:stride_note/services/location_service.dart';
import 'package:stride_note/services/database_service.dart';
import 'package:stride_note/widgets/running_stats.dart';

void main() {
  group('RunningScreen', () {
    testWidgets('should have map toggle button in app bar', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<LocationService>(create: (_) => LocationService()),
            Provider<DatabaseService>(create: (_) => DatabaseService()),
          ],
          child: const MaterialApp(home: RunningScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 지도 토글 버튼이 있는지 확인
      expect(find.byIcon(Icons.map), findsOneWidget);
    });

    testWidgets('should display running stats by default', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<LocationService>(create: (_) => LocationService()),
            Provider<DatabaseService>(create: (_) => DatabaseService()),
          ],
          child: const MaterialApp(home: RunningScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - 초기에는 통계 화면이 표시됨
      expect(find.byType(RunningStats), findsOneWidget);
    });

    testWidgets('should toggle to map view when map button is tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<LocationService>(create: (_) => LocationService()),
            Provider<DatabaseService>(create: (_) => DatabaseService()),
          ],
          child: const MaterialApp(home: RunningScreen()),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // 지도 버튼 탭
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();

      // Assert - 지도 화면으로 전환 (대체 UI 또는 실제 지도)
      expect(find.text('지도 기능'), findsOneWidget);
    });
  });
}
