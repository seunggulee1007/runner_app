import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/config/app_config.dart';
import 'package:stride_note/services/supabase_oauth_validator.dart';

void main() {
  group('Google OAuth URL Tests', () {
    test('should have valid Supabase URL format', () {
      // Arrange
      const expectedUrl = 'https://vldeabmygudmbezxwklk.supabase.co';

      // Act
      final supabaseUrl = AppConfig.supabaseUrl;

      // Assert
      expect(supabaseUrl, equals(expectedUrl));
      expect(supabaseUrl, startsWith('https://'));
      expect(supabaseUrl, contains('supabase.co'));
    });

    test('should have valid anonymous key format', () {
      // Arrange & Act
      final anonKey = AppConfig.supabaseAnonKey;

      // Assert
      expect(anonKey, isNotEmpty);
      expect(anonKey, startsWith('eyJ'));
      expect(anonKey.split('.').length, equals(3)); // JWT 토큰 형식
    });

    test('should construct valid OAuth URL', () {
      // Arrange
      const baseUrl = 'https://vldeabmygudmbezxwklk.supabase.co';
      const redirectUrl = 'com.example.stride_note://';
      const expectedPath = '/auth/v1/authorize';

      // Act
      final oauthUrl =
          '$baseUrl$expectedPath?provider=google&redirect_to=${Uri.encodeComponent(redirectUrl)}&flow_type=pkce';

      // Assert
      expect(oauthUrl, contains(baseUrl));
      expect(oauthUrl, contains('provider=google'));
      expect(oauthUrl, contains('redirect_to='));
      expect(oauthUrl, contains('flow_type=pkce'));
      expect(oauthUrl, contains(Uri.encodeComponent(redirectUrl)));
    });

    test('should have valid Google OAuth client ID format', () {
      // Arrange & Act
      final clientId = SupabaseOAuthValidator.getGoogleOAuthClientId();

      // Assert
      expect(clientId, isNotNull);
      expect(clientId, startsWith('com.googleusercontent.apps.'));
      expect(clientId, contains('174121824357'));
    });

    test('should generate correct Supabase callback URL', () {
      // Arrange & Act
      final callbackUrl = SupabaseOAuthValidator.getSupabaseCallbackUrl();

      // Assert
      expect(
        callbackUrl,
        startsWith('https://vldeabmygudmbezxwklk.supabase.co'),
      );
      expect(callbackUrl, endsWith('/auth/v1/callback'));
    });
  });
}
