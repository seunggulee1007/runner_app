import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/config/app_config.dart';

/// Supabase 연결 테스트
void main() {
  group('Supabase Connection', () {
    test('should have valid configuration', () {
      // Arrange & Act
      final url = AppConfig.supabaseUrl;
      final key = AppConfig.supabaseAnonKey;

      // Assert
      expect(url, isNotEmpty);
      expect(key, isNotEmpty);
      expect(url, startsWith('https://'));
      expect(key, startsWith('eyJ'));
      expect(url, contains('supabase.co'));
    });

    test('should have correct project URL format', () {
      // Arrange & Act
      final url = AppConfig.supabaseUrl;

      // Assert
      expect(url, matches(RegExp(r'^https://[a-z0-9]+\.supabase\.co$')));
    });

    test('should have valid JWT token format', () {
      // Arrange & Act
      final key = AppConfig.supabaseAnonKey;

      // Assert
      // JWT 토큰은 3개의 부분으로 구성됨 (header.payload.signature)
      final parts = key.split('.');
      expect(parts.length, equals(3));
      expect(parts[0], isNotEmpty);
      expect(parts[1], isNotEmpty);
      expect(parts[2], isNotEmpty);
    });

    test('should have expected project ID in URL', () {
      // Arrange & Act
      final url = AppConfig.supabaseUrl;

      // Assert
      // 프로젝트 ID는 환경에 따라 다르므로, URL 형식만 검증
      expect(url, contains('vldeabmygudmbezxwklk'));
    });
  });
}
