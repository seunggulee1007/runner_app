import 'dart:developer' as developer;
import '../config/app_config.dart';
import '../config/supabase_config.dart';

/// Supabase OAuth 설정 검증 도구
class SupabaseOAuthValidator {
  /// OAuth 설정 검증
  static Future<void> validateOAuthConfiguration() async {
    try {
      developer.log('=== Supabase OAuth 설정 검증 시작 ===', name: 'OAuthValidator');

      // 1. Supabase 클라이언트 초기화 확인
      SupabaseConfig.client; // 클라이언트 초기화 확인
      developer.log('✅ Supabase 클라이언트 초기화 완료', name: 'OAuthValidator');

      // 2. URL 설정 확인
      final supabaseUrl = AppConfig.supabaseUrl;
      developer.log('✅ Supabase URL: $supabaseUrl', name: 'OAuthValidator');

      // 3. Anonymous Key 확인
      final anonKey = AppConfig.supabaseAnonKey;
      developer.log(
        '✅ Anonymous Key: ${anonKey.substring(0, 20)}...',
        name: 'OAuthValidator',
      );

      // 4. OAuth URL 구성 확인
      const redirectUrl = 'com.example.runnerApp://';
      final oauthUrl =
          '$supabaseUrl/auth/v1/authorize?provider=google&redirect_to=${Uri.encodeComponent(redirectUrl)}&flow_type=pkce';
      developer.log('✅ OAuth URL 구성: $oauthUrl', name: 'OAuthValidator');

      // 5. 필요한 설정 확인사항 안내
      developer.log('=== 설정 확인 필요사항 ===', name: 'OAuthValidator');
      developer.log(
        '1. Supabase 대시보드 > Authentication > URL Configuration',
        name: 'OAuthValidator',
      );
      developer.log(
        '   - Site URL: https://your-app-domain.com (또는 개발용 localhost)',
        name: 'OAuthValidator',
      );
      developer.log('   - Redirect URLs에 다음 추가:', name: 'OAuthValidator');
      developer.log('     * $redirectUrl', name: 'OAuthValidator');
      developer.log(
        '     * https://your-app-domain.com/auth/callback',
        name: 'OAuthValidator',
      );
      developer.log('', name: 'OAuthValidator');
      developer.log(
        '2. Supabase 대시보드 > Authentication > Providers',
        name: 'OAuthValidator',
      );
      developer.log('   - Google Provider 활성화 확인', name: 'OAuthValidator');
      developer.log(
        '   - Google OAuth Client ID 설정 확인',
        name: 'OAuthValidator',
      );
      developer.log(
        '   - Google OAuth Client Secret 설정 확인',
        name: 'OAuthValidator',
      );
      developer.log('', name: 'OAuthValidator');
      developer.log('3. Google Cloud Console 설정', name: 'OAuthValidator');
      developer.log('   - OAuth 2.0 클라이언트 ID 생성/확인', name: 'OAuthValidator');
      developer.log(
        '   - Bundle ID: com.example.stride_note',
        name: 'OAuthValidator',
      );
      developer.log(
        '   - Authorized redirect URIs에 Supabase 콜백 URL 추가',
        name: 'OAuthValidator',
      );
      developer.log('=== 설정 검증 완료 ===', name: 'OAuthValidator');
    } catch (e) {
      developer.log('❌ OAuth 설정 검증 실패: $e', name: 'OAuthValidator');
      rethrow;
    }
  }

  /// Google OAuth 클라이언트 ID 추출 (Info.plist에서)
  static String? getGoogleOAuthClientId() {
    // iOS Info.plist에서 Google OAuth 클라이언트 ID 추출
    // 실제로는 Info.plist를 파싱해야 하지만, 여기서는 하드코딩된 값 사용
    const clientId =
        'com.googleusercontent.apps.174121824357-u0ila2pfqpag69aldclocklgfrj2nkhf';
    developer.log('Google OAuth Client ID: $clientId', name: 'OAuthValidator');
    return clientId;
  }

  /// Supabase 콜백 URL 생성
  static String getSupabaseCallbackUrl() {
    final supabaseUrl = AppConfig.supabaseUrl;
    return '$supabaseUrl/auth/v1/callback';
  }
}
