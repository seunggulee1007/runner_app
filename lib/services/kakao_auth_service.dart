import 'dart:developer' as developer;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// 카카오 로그인 서비스 클래스
///
/// 카카오 SDK를 사용한 네이티브 로그인을 처리합니다.
class KakaoAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 카카오 SDK 초기화
  static Future<void> initialize() async {
    try {
      kakao.KakaoSdk.init(
        nativeAppKey: AppConfig.kakaoNativeAppKey,
        javaScriptAppKey: AppConfig.kakaoJavaScriptKey,
      );
      developer.log('✅ 카카오 SDK 초기화 완료', name: 'KakaoAuthService');
    } catch (e) {
      developer.log('⚠️ 카카오 SDK 초기화 실패: $e', name: 'KakaoAuthService');
    }
  }

  /// 카카오 로그인 (카카오톡 또는 카카오 계정)
  ///
  /// 1. 카카오톡이 설치되어 있으면 카카오톡으로 로그인
  /// 2. 설치되어 있지 않으면 카카오 계정으로 로그인
  /// 3. 카카오 액세스 토큰을 Supabase ID 토큰으로 교환
  Future<bool> signInWithKakao() async {
    try {
      developer.log('카카오 로그인 시작', name: 'KakaoAuthService');

      kakao.OAuthToken token;

      // 카카오톡 설치 여부 확인 (SDK 메서드 사용)
      if (await kakao.isKakaoTalkInstalled()) {
        developer.log('카카오톡으로 로그인 시도', name: 'KakaoAuthService');
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
          developer.log('카카오톡 로그인 성공', name: 'KakaoAuthService');
        } catch (e) {
          developer.log(
            '카카오톡 로그인 실패, 카카오 계정으로 전환: $e',
            name: 'KakaoAuthService',
          );
          // 카카오톡 로그인 실패 시 카카오 계정으로 로그인
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        developer.log('카카오 계정으로 로그인 시도', name: 'KakaoAuthService');
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        developer.log('카카오 계정 로그인 성공', name: 'KakaoAuthService');
      }

      developer.log(
        '카카오 액세스 토큰 획득: ${token.accessToken.substring(0, 10)}...',
        name: 'KakaoAuthService',
      );

      // Supabase에 카카오 토큰으로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: token.idToken!,
        accessToken: token.accessToken,
      );

      if (response.session != null) {
        developer.log(
          '✅ Supabase 로그인 성공: ${response.user?.email}',
          name: 'KakaoAuthService',
        );
        return true;
      }

      developer.log('⚠️ Supabase 세션 생성 실패', name: 'KakaoAuthService');
      return false;
    } catch (e) {
      developer.log('❌ 카카오 로그인 실패: $e', name: 'KakaoAuthService');
      return false;
    }
  }

  /// 현재 로그인한 카카오 사용자 정보 가져오기
  Future<kakao.User?> getCurrentUserInfo() async {
    try {
      final user = await kakao.UserApi.instance.me();
      developer.log(
        '카카오 사용자 정보: ${user.kakaoAccount?.profile?.nickname}',
        name: 'KakaoAuthService',
      );
      return user;
    } catch (e) {
      developer.log('카카오 사용자 정보 조회 실패: $e', name: 'KakaoAuthService');
      return null;
    }
  }

  /// 카카오 로그아웃
  Future<void> signOut() async {
    try {
      await kakao.UserApi.instance.logout();
      developer.log('✅ 카카오 로그아웃 완료', name: 'KakaoAuthService');
    } catch (e) {
      developer.log('카카오 로그아웃 실패: $e', name: 'KakaoAuthService');
    }
  }

  /// 카카오 연결 끊기 (회원 탈퇴)
  Future<void> unlink() async {
    try {
      await kakao.UserApi.instance.unlink();
      developer.log('✅ 카카오 연결 끊기 완료', name: 'KakaoAuthService');
    } catch (e) {
      developer.log('카카오 연결 끊기 실패: $e', name: 'KakaoAuthService');
    }
  }
}
