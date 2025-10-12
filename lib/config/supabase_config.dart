import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'app_config.dart';

/// Supabase 설정 클래스
///
/// 모든 설정값은 AppConfig에서 중앙 관리됩니다.
class SupabaseConfig {
  /// Supabase 초기화
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    developer.log('✅ Supabase 초기화 완료', name: 'SupabaseConfig');
    developer.log('   URL: ${AppConfig.supabaseUrl}', name: 'SupabaseConfig');
  }

  /// Supabase 클라이언트 인스턴스
  static SupabaseClient get client => Supabase.instance.client;
}
