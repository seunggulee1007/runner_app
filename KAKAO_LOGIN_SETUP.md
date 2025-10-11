# Kakao 로그인 설정 가이드

## 📋 개요

이 문서는 Flutter 러너 앱에 Kakao 로그인을 통합하는 방법을 설명합니다.

## 🔑 Kakao 키 정보

현재 프로젝트에 설정된 카카오 키:
- **Native App Key**: `d7a87c8733aa4ee7aa0f4fcba19a009b`
- **REST API Key**: `03c8088acc40dc2b110c337916294a67`
- **JavaScript Key**: `2504155c2e6be5726314246e1bfaeb7c`

## 🛠️ 설정 방법

### 1. 환경 변수 설정

`.env` 파일에 다음을 추가합니다:

```bash
# Kakao OAuth Configuration
KAKAO_NATIVE_APP_KEY=d7a87c8733aa4ee7aa0f4fcba19a009b
KAKAO_REST_API_KEY=03c8088acc40dc2b110c337916294a67
KAKAO_JAVASCRIPT_KEY=2504155c2e6be5726314246e1bfaeb7c
```

### 2. Android 설정

#### AndroidManifest.xml

`android/app/src/main/AndroidManifest.xml`에 다음을 추가:

```xml
<!-- Kakao Native App Key -->
<meta-data
    android:name="com.kakao.sdk.AppKey"
    android:value="d7a87c8733aa4ee7aa0f4fcba19a009b" />
```

### 3. iOS 설정

#### Info.plist

`ios/Runner/Info.plist`에 다음을 추가:

```xml
<!-- Kakao Native App Key -->
<key>KAKAO_APP_KEY</key>
<string>d7a87c8733aa4ee7aa0f4fcba19a009b</string>

<!-- Kakao LSApplicationQueriesSchemes -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
</array>

<!-- Kakao URL Scheme -->
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>kakaod7a87c8733aa4ee7aa0f4fcba19a009b</string>
    </array>
</dict>
```

## 📱 사용 방법

### 기본 로그인

```dart
import 'package:stride_note/services/auth_service.dart';

// 카카오 로그인
final success = await AuthService.signInWithKakao();
if (success) {
  print('카카오 로그인 성공!');
}
```

### Provider를 사용한 로그인

```dart
import 'package:provider/provider.dart';
import 'package:stride_note/providers/auth_provider.dart';

// 카카오 로그인
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.signInWithKakao();
```

## 🔄 로그인 플로우

1. **카카오톡 앱 확인**: 사용자 기기에 카카오톡이 설치되어 있는지 확인
2. **로그인 방식 선택**:
   - 카카오톡이 설치된 경우: 카카오톡으로 로그인
   - 설치되지 않은 경우: 카카오 계정으로 로그인
3. **토큰 교환**: 카카오 액세스 토큰을 Supabase ID 토큰으로 교환
4. **사용자 프로필 생성**: Supabase에 사용자 프로필 자동 생성

## ⚠️ 주의사항

### Supabase 설정

Supabase Dashboard에서 Kakao OAuth Provider를 활성화해야 합니다:

1. Supabase Dashboard → Authentication → Providers
2. Kakao 선택 및 활성화
3. Kakao REST API Key 입력: `03c8088acc40dc2b110c337916294a67`
4. Redirect URL 설정: `https://[your-project-ref].supabase.co/auth/v1/callback`

### 카카오 개발자 콘솔 설정

1. [Kakao Developers](https://developers.kakao.com/) 접속
2. 앱 설정 → 플랫폼 추가
3. Android/iOS 플랫폼 등록
4. 리다이렉트 URI 설정

## 🧪 테스트

```bash
# 테스트 실행
flutter test test/unit/services/kakao_auth_service_test.dart

# 전체 테스트
flutter test
```

## 🐛 트러블슈팅

### 문제: 카카오톡 로그인이 실패합니다

**해결 방법**:
1. AndroidManifest.xml의 Native App Key 확인
2. Info.plist의 KAKAO_APP_KEY 확인
3. 카카오 개발자 콘솔에서 플랫폼 등록 확인

### 문제: Supabase 토큰 교환 실패

**해결 방법**:
1. Supabase Dashboard에서 Kakao Provider 활성화 확인
2. REST API Key 일치 여부 확인
3. Redirect URL 설정 확인

## 📚 참고 문서

- [Kakao Flutter SDK](https://developers.kakao.com/docs/latest/ko/sdk-download/flutter)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [카카오 로그인](https://developers.kakao.com/docs/latest/ko/kakaologin/common)

