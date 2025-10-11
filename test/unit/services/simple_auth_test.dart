import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stride_note/services/auth_service.dart';

void main() {
  group('AuthService - Simple Tests', () {
    test('should have currentUser getter', () {
      // Arrange & Act
      final currentUser = AuthService.currentUser;

      // Assert
      expect(currentUser, isA<User?>());
    });

    test('should have isLoggedIn getter', () {
      // Arrange & Act
      final isLoggedIn = AuthService.isLoggedIn;

      // Assert
      expect(isLoggedIn, isA<bool>());
    });

    test('should have authStateChanges stream', () {
      // Arrange & Act
      final authStateChanges = AuthService.authStateChanges;

      // Assert
      expect(authStateChanges, isA<Stream<AuthState>>());
    });
  });
}
