import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// 인증 서비스 클래스
class AuthService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  /// 현재 사용자 정보 가져오기
  static User? get currentUser => _supabase.auth.currentUser;

  /// 로그인 상태 확인
  static bool get isLoggedIn => currentUser != null;

  /// 이메일로 회원가입
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 이메일로 로그인
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// 비밀번호 재설정 이메일 발송
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// 사용자 프로필 업데이트
  static Future<UserResponse> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 인증 상태 변경 스트림
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
