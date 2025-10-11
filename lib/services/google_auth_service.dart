import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import 'dart:developer' as developer;
import '../config/supabase_config.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';

/// Google 네이티브 로그인 서비스 (모든 플랫폼 지원)
///
/// 플랫폼별 동작:
/// - iOS/Android: 네이티브 Google Sign-In → ID Token → Supabase
/// - Web: Google Sign-In Web SDK → ID Token → Supabase
///
/// ⚠️ 브라우저를 열지 않고, 모두 네이티브/인앱으로 처리됩니다.
class GoogleAuthService {
  // Google Sign-In 설정 (모든 플랫폼)
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // ⚠️ serverClientId를 제거하면 nonce가 생성되지 않음
    // 하지만 ID Token은 여전히 발급됨 (플랫폼별 Client ID 사용)
  );

  /// Google 로그인 (브라우저 없음, 네이티브만)
  ///
  /// 반환값:
  /// - true: 로그인 성공
  /// - false: 사용자 취소
  /// - throw: 오류 발생
  static Future<bool> signInWithGoogle() async {
    try {
      developer.log('=== Google 네이티브 로그인 시작 ===', name: 'GoogleAuthService');
      developer.log(
        '플랫폼: ${kIsWeb ? 'Web' : Platform.operatingSystem}',
        name: 'GoogleAuthService',
      );

      // 1. Google Sign-In으로 사용자 인증 (네이티브 UI)
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        developer.log('❌ 사용자가 로그인을 취소했습니다', name: 'GoogleAuthService');
        return false;
      }

      developer.log(
        '✅ Google 인증 완료: ${googleUser.email}',
        name: 'GoogleAuthService',
      );

      // 2. Google 인증 토큰 가져오기
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google ID Token을 가져올 수 없습니다');
      }

      developer.log('✅ Google ID Token 획득', name: 'GoogleAuthService');

      // 3. Supabase 인증 (nonce 없이)
      developer.log('🔐 Supabase 인증 시작...', name: 'GoogleAuthService');

      // ⚠️ nonce 없이 signInWithIdToken 호출
      // GIDClientID 제거로 nonce가 생성되지 않음
      await SupabaseConfig.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
        // nonce 파라미터 없음
      );

      // 4. 현재 사용자 확인
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('로그인 후 사용자 정보를 가져올 수 없습니다');
      }

      developer.log(
        '✅ Supabase 로그인 완료: ${currentUser.email}',
        name: 'GoogleAuthService',
      );

      // 5. 사용자 프로필 자동 생성/업데이트
      await _handleUserProfile(currentUser, googleUser);

      developer.log('=== Google 로그인 완료 ===', name: 'GoogleAuthService');
      return true;
    } on PlatformException catch (e) {
      developer.log(
        '❌ PlatformException: ${e.code}',
        name: 'GoogleAuthService',
      );
      developer.log('   메시지: ${e.message}', name: 'GoogleAuthService');

      if (e.code == 'sign_in_canceled') {
        return false; // 사용자 취소는 오류가 아님
      }

      rethrow;
    } catch (e) {
      developer.log('❌ Google 로그인 오류: $e', name: 'GoogleAuthService');
      rethrow;
    }
  }

  /// 사용자 프로필 자동 생성/업데이트
  static Future<void> _handleUserProfile(
    User supabaseUser,
    GoogleSignInAccount googleUser,
  ) async {
    try {
      developer.log('📝 사용자 프로필 처리 중...', name: 'GoogleAuthService');

      // 기존 프로필 확인 (null 안전 처리)
      UserProfile? existingProfile;
      try {
        existingProfile = await UserProfileService.getCurrentUserProfile();
      } catch (e) {
        developer.log('⚠️ 프로필 조회 오류 (무시): $e', name: 'GoogleAuthService');
        existingProfile = null;
      }

      if (existingProfile == null) {
        // 신규 사용자: 프로필 생성
        developer.log('✨ 신규 사용자, 프로필 생성', name: 'GoogleAuthService');

        try {
          await UserProfileService.createUserProfile(
            email: supabaseUser.email ?? googleUser.email,
            displayName: googleUser.displayName,
            avatarUrl: googleUser.photoUrl,
          );

          developer.log('✅ 프로필 생성 완료', name: 'GoogleAuthService');
        } on PostgrestException catch (e) {
          // 중복 키 오류는 무시 (이미 프로필 존재)
          if (e.code == '23505') {
            developer.log(
              'ℹ️ 프로필이 이미 존재합니다 (중복 생성 스킵)',
              name: 'GoogleAuthService',
            );
          } else {
            rethrow;
          }
        }
      } else {
        // 기존 사용자: 프로필 업데이트 (필요시)
        developer.log('♻️ 기존 사용자, 프로필 확인', name: 'GoogleAuthService');

        bool needsUpdate = false;

        // 디스플레이 네임이 없으면 업데이트
        if (existingProfile.displayName == null &&
            googleUser.displayName != null) {
          needsUpdate = true;
        }

        // 프로필 사진이 없으면 업데이트
        if (existingProfile.avatarUrl == null && googleUser.photoUrl != null) {
          needsUpdate = true;
        }

        if (needsUpdate) {
          developer.log('🔄 프로필 정보 업데이트', name: 'GoogleAuthService');

          await UserProfileService.updateUserProfile(
            displayName: googleUser.displayName ?? existingProfile.displayName,
            avatarUrl: googleUser.photoUrl ?? existingProfile.avatarUrl,
          );

          developer.log('✅ 프로필 업데이트 완료', name: 'GoogleAuthService');
        } else {
          developer.log('✓ 프로필 업데이트 불필요', name: 'GoogleAuthService');
        }
      }
    } catch (e) {
      developer.log('⚠️ 프로필 처리 오류: $e', name: 'GoogleAuthService');
      // 프로필 오류는 로그인 실패로 이어지지 않음
    }
  }

  /// Google 로그아웃
  ///
  /// Google Sign-In 세션과 Supabase 세션을 모두 종료합니다.
  static Future<void> signOut() async {
    try {
      developer.log('🚪 로그아웃 시작', name: 'GoogleAuthService');

      // Google Sign-In 로그아웃
      try {
        await _googleSignIn.signOut();
        developer.log('✅ Google Sign-In 로그아웃', name: 'GoogleAuthService');
      } catch (e) {
        developer.log(
          '⚠️ Google Sign-In 로그아웃 실패: $e',
          name: 'GoogleAuthService',
        );
      }

      // Supabase 로그아웃
      await SupabaseConfig.client.auth.signOut();
      developer.log('✅ Supabase 로그아웃', name: 'GoogleAuthService');

      developer.log('🚪 로그아웃 완료', name: 'GoogleAuthService');
    } catch (e) {
      developer.log('❌ 로그아웃 오류: $e', name: 'GoogleAuthService');
      rethrow;
    }
  }

  /// 현재 Google 계정 확인
  ///
  /// Google Sign-In 상태를 확인합니다.
  /// Supabase 세션과 별개로 동작합니다.
  static Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      developer.log('⚠️ Silent sign-in 실패: $e', name: 'GoogleAuthService');
      return null;
    }
  }

  /// Google Sign-In 연결 해제
  ///
  /// Google 계정 연결을 완전히 해제합니다.
  /// 다음 로그인 시 다시 권한 요청이 표시됩니다.
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      developer.log('🔌 Google 계정 연결 해제', name: 'GoogleAuthService');
    } catch (e) {
      developer.log('⚠️ 연결 해제 실패: $e', name: 'GoogleAuthService');
      rethrow;
    }
  }
}
