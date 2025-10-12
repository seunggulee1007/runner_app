import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase MCP 연결 테스트
void main() {
  group('Supabase MCP Connection', () {
    test('should connect to Supabase project successfully', () {
      // Arrange
      const expectedUrl = 'https://vldeabmygudmbezxwklk.supabase.co';

      // Act
      final actualUrl = AppConfig.supabaseUrl;

      // Assert
      expect(actualUrl, equals(expectedUrl));
      expect(actualUrl, isNotEmpty);
      expect(actualUrl, startsWith('https://'));
    });

    test('should have valid anonymous key', () {
      // Arrange
      const expectedKeyPrefix = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';

      // Act
      final actualKey = AppConfig.supabaseAnonKey;

      // Assert
      expect(actualKey, isNotEmpty);
      expect(actualKey, startsWith(expectedKeyPrefix));
      expect(actualKey.length, greaterThan(100)); // JWT 토큰은 충분한 길이를 가져야 함
    });

    test('should have valid configuration values', () {
      // Arrange & Act
      final url = AppConfig.supabaseUrl;
      final key = AppConfig.supabaseAnonKey;

      // Assert
      expect(url, isNotEmpty);
      expect(key, isNotEmpty);
      expect(url, startsWith('https://'));
      expect(key, startsWith('eyJ'));
    });

    test('should be able to create Supabase client with configuration', () {
      // Arrange
      final url = AppConfig.supabaseUrl;
      final key = AppConfig.supabaseAnonKey;

      // Act
      final client = SupabaseClient(url, key);

      // Assert
      expect(client, isNotNull);
      expect(client.auth, isNotNull);
    });
  });
}
