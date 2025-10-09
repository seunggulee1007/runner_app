import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 설정 클래스
class SupabaseConfig {
  // Supabase 프로젝트 URL과 API 키를 여기에 입력하세요
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Supabase 초기화
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Supabase 클라이언트 인스턴스
  static SupabaseClient get client => Supabase.instance.client;
}
