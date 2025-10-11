// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/main.dart';

void main() {
  testWidgets('StrideNote app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StrideNoteApp());

    // Wait for any pending timers to complete
    await tester.pumpAndSettle();

    // Verify that our app starts with the splash screen or home screen.
    // The app might show splash screen first, so we check for either
    final splashScreen = find.text('StrideNote');
    final homeScreen = find.text('홈');

    // Check if either splash screen or home screen is found
    expect(
      splashScreen.evaluate().isNotEmpty || homeScreen.evaluate().isNotEmpty,
      isTrue,
    );
  });
}
