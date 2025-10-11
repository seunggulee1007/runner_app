import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/services/auth_service.dart';

void main() {
  group('AuthService', () {
    group('Static Methods', () {
      test('should have currentUser getter', () {
        // Act & Assert
        expect(AuthService.currentUser, isA<dynamic>());
      });

      test('should have isLoggedIn getter', () {
        // Act & Assert
        expect(AuthService.isLoggedIn, isA<bool>());
      });

      test('should have authStateChanges stream', () {
        // Act & Assert
        expect(AuthService.authStateChanges, isA<Stream>());
      });
    });

    group('Method Signatures', () {
      test('should have signUpWithEmail method', () {
        // Act & Assert
        expect(AuthService.signUpWithEmail, isA<Function>());
      });

      test('should have signInWithEmail method', () {
        // Act & Assert
        expect(AuthService.signInWithEmail, isA<Function>());
      });

      test('should have signInWithGoogle method', () {
        // Act & Assert
        expect(AuthService.signInWithGoogle, isA<Function>());
      });

      test('should have signOut method', () {
        // Act & Assert
        expect(AuthService.signOut, isA<Function>());
      });
    });
  });
}
