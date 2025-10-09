import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase 설정 클래스
class SupabaseConfig {
  // ⚠️ 보안 주의: 실제 배포 시에는 환경 변수나 안전한 방법으로 관리하세요
  // 현재는 개발용으로만 사용하며, 프로덕션에서는 반드시 환경 변수로 관리해야 합니다

  /// Supabase URL 가져오기
  static String get supabaseUrl {
    // 환경 변수에서 가져오기 시도, 없으면 기본값 사용
    return dotenv.env['SUPABASE_URL'] ??
        'https://azhddbeeyzrlqlqbcpzg.supabase.co';
  }

  /// Supabase Anonymous Key 가져오기
  static String get supabaseAnonKey {
    // 환경 변수에서 가져오기 시도, 없으면 기본값 사용
    return dotenv.env['SUPABASE_ANON_KEY'] ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF6aGRkYmVleXpybHFscWJjcHpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5OTc2MzIsImV4cCI6MjA3NTU3MzYzMn0.Vo3vHCxLyGmafDdbHBasVUbSV5XOJJx7K1FbkB3s2vk';
  }

  /// Supabase 초기화
  static Future<void> initialize() async {
    // 환경 변수 파일 로드
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Supabase 클라이언트 인스턴스
  static SupabaseClient get client => Supabase.instance.client;
}
