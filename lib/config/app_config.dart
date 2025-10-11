import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

/// 앱 환경 설정 중앙 관리 클래스
///
/// 모든 민감한 키와 설정값을 환경 변수로 관리합니다.
/// .env 파일에서 값을 읽어오며, 없으면 기본값을 사용합니다.
class AppConfig {
  static bool _isInitialized = false;

  /// 앱 초기화
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      _isInitialized = true;
      developer.log('✅ 환경 변수 로드 완료', name: 'AppConfig');
    } catch (e) {
      developer.log('⚠️ .env 파일을 찾을 수 없습니다. 기본값을 사용합니다: $e', name: 'AppConfig');
      _isInitialized = true; // 기본값 사용을 위해 true로 설정
    }
  }

  /// 환경 변수 값을 안전하게 가져오기
  static String _getEnvValue(String key, String defaultValue) {
    try {
      if (_isInitialized && dotenv.isInitialized) {
        final value = dotenv.env[key];
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    } catch (e) {
      developer.log('⚠️ 환경 변수 접근 실패 ($key): $e', name: 'AppConfig');
    }
    return defaultValue;
  }

  // ============================================================
  // Supabase 설정
  // ============================================================

  /// Supabase URL
  ///
  /// ⚠️ 반드시 .env 파일에 실제 값을 설정하세요.
  static String get supabaseUrl {
    return _getEnvValue(
      'SUPABASE_URL',
      '', // 환경 변수에서 읽어오기
    );
  }

  /// Supabase Anonymous Key
  ///
  /// ⚠️ 반드시 .env 파일에 실제 값을 설정하세요.
  static String get supabaseAnonKey {
    return _getEnvValue(
      'SUPABASE_ANON_KEY',
      '', // 환경 변수에서 읽어오기
    );
  }

  // ============================================================
  // Google OAuth 설정
  // ============================================================

  /// Google Web Client ID (Supabase 연동용)
  ///
  /// ⚠️ 반드시 .env 파일에 실제 값을 설정하세요.
  static String get googleWebClientId {
    return _getEnvValue(
      'GOOGLE_WEB_CLIENT_ID',
      '', // 환경 변수에서 읽어오기
    );
  }

  /// Google iOS Client ID
  static String get googleIosClientId {
    return _getEnvValue(
      'GOOGLE_IOS_CLIENT_ID',
      '', // iOS에서는 Info.plist에서 읽음
    );
  }

  /// Google Android Client ID
  static String get googleAndroidClientId {
    return _getEnvValue(
      'GOOGLE_ANDROID_CLIENT_ID',
      '', // Android에서는 google-services.json에서 읽음
    );
  }

  // ============================================================
  // 앱 설정
  // ============================================================

  /// Bundle Identifier (iOS) / Application ID (Android)
  static String get bundleId {
    return _getEnvValue('BUNDLE_ID', 'com.example.runnerApp');
  }

  // ============================================================
  // 유틸리티 메서드
  // ============================================================

  /// 모든 필수 환경 변수가 설정되었는지 확인
  static bool validateConfig() {
    final errors = <String>[];

    // Supabase 필수 체크
    if (supabaseUrl.isEmpty || supabaseUrl.contains('your-project-id')) {
      errors.add('SUPABASE_URL이 설정되지 않았습니다');
    }
    if (supabaseAnonKey.isEmpty || supabaseAnonKey.contains('your-supabase')) {
      errors.add('SUPABASE_ANON_KEY가 설정되지 않았습니다');
    }

    // Google OAuth 필수 체크
    if (googleWebClientId.isEmpty ||
        googleWebClientId.contains('your-google')) {
      errors.add('GOOGLE_WEB_CLIENT_ID가 설정되지 않았습니다');
    }

    if (errors.isNotEmpty) {
      developer.log('⚠️ 환경 변수 검증 실패:\n${errors.join('\n')}', name: 'AppConfig');
      return false;
    }

    developer.log('✅ 환경 변수 검증 성공', name: 'AppConfig');
    return true;
  }

  /// 설정 정보 출력 (디버깅용, 민감한 정보는 마스킹)
  static void printConfig() {
    developer.log('=== 앱 설정 정보 ===', name: 'AppConfig');
    developer.log('Supabase URL: $supabaseUrl', name: 'AppConfig');
    developer.log(
      'Supabase Anon Key: ${_maskKey(supabaseAnonKey)}',
      name: 'AppConfig',
    );
    developer.log(
      'Google Web Client ID: ${_maskKey(googleWebClientId)}',
      name: 'AppConfig',
    );
    developer.log('Bundle ID: $bundleId', name: 'AppConfig');
    developer.log('==================', name: 'AppConfig');
  }

  /// 키 마스킹 (앞 10자, 뒤 5자만 표시)
  static String _maskKey(String key) {
    if (key.isEmpty) return '(비어있음)';
    if (key.length <= 15) return '***';
    return '${key.substring(0, 10)}...${key.substring(key.length - 5)}';
  }
}
