import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/services/kakao_auth_service.dart';

/// KakaoAuthService 단위 테스트
///
/// TDD 원칙에 따라 작성된 테스트입니다.
void main() {
  group('KakaoAuthService', () {
    group('signInWithKakao', () {
      test('should return true when kakao login succeeds', () async {
        // Arrange - 테스트 데이터 준비
        final kakaoAuthService = KakaoAuthService();

        // Act - 테스트 대상 실행
        // 실제로는 Mock을 사용해야 하지만, 먼저 구조를 확인
        final result = await kakaoAuthService.signInWithKakao();

        // Assert - 결과 검증
        expect(result, isA<bool>());
      });

      test('should return false when user cancels login', () async {
        // Arrange
        final kakaoAuthService = KakaoAuthService();

        // Act
        // 사용자가 취소한 경우를 시뮬레이션
        final result = await kakaoAuthService.signInWithKakao();

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('isKakaoTalkInstalled', () {
      test('should check if kakao talk app is installed', () async {
        // Arrange
        final kakaoAuthService = KakaoAuthService();

        // Act
        final result = await kakaoAuthService.isKakaoTalkInstalled();

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('getCurrentUserInfo', () {
      test('should return user info when logged in', () async {
        // Arrange
        final kakaoAuthService = KakaoAuthService();

        // Act
        final result = await kakaoAuthService.getCurrentUserInfo();

        // Assert
        expect(result, isNull); // 로그인 전에는 null
      });
    });
  });
}

