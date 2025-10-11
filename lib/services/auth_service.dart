import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../config/supabase_config.dart';
import 'google_auth_service.dart';
import 'user_profile_service.dart';

/// 인증 서비스 클래스
class AuthService {
  static SupabaseClient get _supabase {
    try {
      return SupabaseConfig.client;
    } catch (e) {
      throw Exception(
        'Supabase not initialized. Call SupabaseConfig.initialize() first.',
      );
    }
  }

  /// 현재 사용자 정보 가져오기
  static User? get currentUser {
    try {
      return _supabase.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// 로그인 상태 확인
  static bool get isLoggedIn {
    try {
      return currentUser != null;
    } catch (e) {
      return false;
    }
  }

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

      // 회원가입 성공 시 사용자 프로필 생성
      if (response.user != null) {
        await _createUserProfileFromEmailSignup(response.user!, name);
      }

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

      // 로그인 성공 시 프로필 확인 및 생성
      if (response.user != null) {
        await _ensureUserProfileExists(response.user!);
      }

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

  /// Google 로그인
  static Future<bool> signInWithGoogle() async {
    try {
      return await GoogleAuthService.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  /// Google 로그아웃
  static Future<void> signOutGoogle() async {
    try {
      await GoogleAuthService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// 인증 상태 변경 스트림
  static Stream<AuthState> get authStateChanges {
    try {
      return _supabase.auth.onAuthStateChange;
    } catch (e) {
      // Supabase가 초기화되지 않은 경우 빈 스트림 반환
      return Stream.empty();
    }
  }

  /// 이메일 회원가입으로부터 사용자 프로필 생성
  static Future<void> _createUserProfileFromEmailSignup(
    User user,
    String? name,
  ) async {
    try {
      developer.log('이메일 회원가입 사용자 프로필 생성: ${user.email}', name: 'AuthService');

      await UserProfileService.createUserProfile(
        email: user.email ?? '',
        displayName: name ?? '사용자',
        avatarUrl: null,
        birthDate: null,
        gender: null,
        height: null,
        weight: null,
        fitnessLevel: null,
      );

      developer.log('이메일 회원가입 사용자 프로필 생성 완료', name: 'AuthService');
    } catch (e) {
      developer.log('이메일 회원가입 사용자 프로필 생성 오류: $e', name: 'AuthService');
    }
  }

  /// 사용자 프로필이 존재하는지 확인하고 없으면 생성
  static Future<void> _ensureUserProfileExists(User user) async {
    try {
      final existingProfile = await UserProfileService.getCurrentUserProfile();

      if (existingProfile == null) {
        developer.log('기존 프로필이 없어서 새로 생성: ${user.email}', name: 'AuthService');

        await UserProfileService.createUserProfile(
          email: user.email ?? '',
          displayName: user.userMetadata?['name'] ?? '사용자',
          avatarUrl: user.userMetadata?['avatar_url'],
          birthDate: null,
          gender: null,
          height: null,
          weight: null,
          fitnessLevel: null,
        );

        developer.log('사용자 프로필 생성 완료', name: 'AuthService');
      } else {
        developer.log(
          '기존 프로필이 존재합니다: ${existingProfile.email}',
          name: 'AuthService',
        );
      }
    } catch (e) {
      developer.log('사용자 프로필 확인/생성 오류: $e', name: 'AuthService');
    }
  }
}
