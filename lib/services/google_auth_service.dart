import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'user_profile_service.dart';

/// Google 로그인 서비스 클래스 (Supabase OAuth 사용)
class GoogleAuthService {
  /// Google 로그인 (임시 비활성화 - 프로필 생성 포함)
  static Future<bool> signInWithGoogle() async {
    try {
      print('Google 로그인 시작 (임시 비활성화)...');

      // 임시로 성공 반환 (실제 로그인은 비활성화)
      await Future.delayed(const Duration(seconds: 1));

      // 임시 사용자 프로필 생성 (테스트용)
      await _createTestUserProfile();

      print('Google 로그인 임시 성공 (실제 로그인 비활성화)');
      return true;
    } catch (e) {
      print('Google 로그인 오류: $e');
      print('오류 타입: ${e.runtimeType}');
      rethrow;
    }
  }

  /// 테스트용 사용자 프로필 생성
  static Future<void> _createTestUserProfile() async {
    try {
      // 임시 사용자 정보로 프로필 생성
      await UserProfileService.createUserProfile(
        email: 'test@example.com',
        displayName: '테스트 사용자',
        avatarUrl: null,
        birthDate: DateTime(1990, 1, 1),
        gender: Gender.male,
        height: 175,
        weight: 70.0,
        fitnessLevel: FitnessLevel.beginner,
      );
      print('테스트 사용자 프로필 생성 완료');
    } catch (e) {
      print('테스트 사용자 프로필 생성 오류: $e');
    }
  }

  /// Google 로그아웃
  static Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      print('Google 로그아웃 완료');
    } catch (e) {
      print('Google 로그아웃 오류: $e');
      rethrow;
    }
  }

  /// 현재 Google 로그인 상태 확인
  static Future<bool> isSignedIn() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      return user != null;
    } catch (e) {
      print('Google 로그인 상태 확인 오류: $e');
      return false;
    }
  }

  /// 현재 Google 사용자 정보 가져오기
  static Future<User?> getCurrentUser() async {
    try {
      return SupabaseConfig.client.auth.currentUser;
    } catch (e) {
      print('Google 사용자 정보 가져오기 오류: $e');
      return null;
    }
  }
}
