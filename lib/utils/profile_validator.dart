/// 프로필 데이터 검증 유틸리티
///
/// 사용자 프로필 업데이트 시 입력값을 검증합니다.
class ProfileValidator {
  // Private constructor to prevent instantiation
  ProfileValidator._();

  // === 검증 상수 ===

  /// 이름 최대 길이
  static const int maxDisplayNameLength = 50;

  /// 키 최소값 (cm)
  static const int minHeight = 50;

  /// 키 최대값 (cm)
  static const int maxHeight = 300;

  /// 몸무게 최소값 (kg)
  static const double minWeight = 20.0;

  /// 몸무게 최대값 (kg)
  static const double maxWeight = 300.0;

  /// 이메일 정규식 패턴
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // === 검증 메서드 ===

  /// 이름 검증
  ///
  /// - 빈 문자열 불가
  /// - 최대 50자
  static bool validateDisplayName(String displayName) {
    return displayName.isNotEmpty && displayName.length <= maxDisplayNameLength;
  }

  /// 키 검증 (cm)
  ///
  /// - 범위: 50-300 cm
  static bool validateHeight(int height) {
    return height >= minHeight && height <= maxHeight;
  }

  /// 몸무게 검증 (kg)
  ///
  /// - 범위: 20-300 kg
  static bool validateWeight(double weight) {
    return weight >= minWeight && weight <= maxWeight;
  }

  /// 이메일 검증
  ///
  /// - 기본 이메일 형식 검증
  static bool validateEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }
}
