# 🎯 Google 네이티브 로그인 완전 가이드

## ✅ 완료된 리팩터링

### 🏗️ 아키텍처

```
사용자 → Google Sign-In SDK (네이티브) → ID Token → Supabase signInWithIdToken → 세션 유지
```

**특징:**

- ✅ **브라우저 열리지 않음** (100% 네이티브/인앱)
- ✅ **딥링크 불필요** (redirectTo 완전 제거)
- ✅ **자동 세션 유지** (Supabase 자동 처리)
- ✅ **자동 프로필 생성/업데이트**
- ✅ **3개 플랫폼 동일 로직** (iOS/Android/Web)

---

## 📱 플랫폼별 동작

### iOS

1. 네이티브 Google Sign-In UI 표시
2. 사용자 Google 계정 선택
3. ID Token 발급
4. Supabase 인증
5. 프로필 자동 생성/업데이트
6. 앱으로 복귀 (즉시)

### Android

1. Google Play Services 네이티브 로그인
2. 사용자 Google 계정 선택
3. ID Token 발급
4. Supabase 인증
5. 프로필 자동 생성/업데이트
6. 앱 내에서 완료

### Web

1. Google Sign-In Web SDK 팝업
2. 사용자 Google 계정 선택
3. ID Token 발급
4. Supabase 인증
5. 프로필 자동 생성/업데이트
6. 페이지 새로고침 없음

---

## 🔧 코어 코드

### GoogleAuthService (완전 리팩터링)

**위치**: `lib/services/google_auth_service.dart`

**주요 기능**:

- `signInWithGoogle()`: 네이티브 Google 로그인 (모든 플랫폼)
- `signOut()`: 로그아웃 (Google + Supabase 동시)
- `getCurrentGoogleUser()`: 현재 Google 계정 확인
- `disconnect()`: Google 계정 연결 완전 해제

**핵심 로직**:

```dart
// 1. Google Sign-In (네이티브)
final googleUser = await _googleSignIn.signIn();

// 2. ID Token 가져오기
final googleAuth = await googleUser.authentication;
final idToken = googleAuth.idToken;
final accessToken = googleAuth.accessToken;

// 3. Supabase 인증
await SupabaseConfig.client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
  accessToken: accessToken,
);

// 4. 자동 프로필 처리
await _handleUserProfile(currentUser, googleUser);
```

---

## 📦 필수 설정

### 1. iOS 설정

**파일**: `ios/Runner/Info.plist`

```xml
<!-- Google Sign-In Client ID -->
<key>GIDClientID</key>
<string>YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com</string>

<!-- URL Scheme (Google 리버스) -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-GOOGLE-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

### 2. Android 설정

**파일**: `android/app/build.gradle.kts`

```kotlin
android {
    defaultConfig {
        applicationId = "com.example.runnerApp"
    }
}
```

**SHA-1 등록** (Google Cloud Console):

```bash
cd android && ./gradlew signingReport
```

### 3. Web 설정

**자동 처리됨** (추가 설정 불필요)

### 4. Google Cloud Console

1. **OAuth 2.0 클라이언트 ID 생성**

   - Web Application: `YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com`
   - iOS Application: Bundle ID 등록
   - Android Application: SHA-1 등록

2. **Authorized redirect URIs** (Web용)
   - `https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback`

### 5. Supabase Dashboard

1. **Authentication > Providers > Google**
   - Enabled: ✅
   - Client ID: (Web OAuth Client ID)
   - Client Secret: (Web OAuth Client Secret)

---

## 🚀 사용 방법

### 로그인

```dart
import 'package:stride_note/services/google_auth_service.dart';

// 로그인
try {
  final success = await GoogleAuthService.signInWithGoogle();

  if (success) {
    print('✅ 로그인 성공!');
    // 세션 자동 유지됨
    // 프로필 자동 생성/업데이트됨
  } else {
    print('❌ 사용자가 취소했습니다');
  }
} catch (e) {
  print('❌ 로그인 오류: $e');
}
```

### 로그아웃

```dart
// 로그아웃
await GoogleAuthService.signOut();
```

### 계정 연결 해제

```dart
// Google 계정 완전 연결 해제
await GoogleAuthService.disconnect();
```

---

## 🔍 문제 해결

### iOS: "Google Sign-In failed"

**원인**: `GIDClientID` 누락 또는 잘못된 Client ID

**해결**:

1. `Info.plist`에 `GIDClientID` 확인
2. Google Cloud Console에서 iOS Client 등록 확인
3. Bundle ID 일치 확인 (`com.example.runnerApp`)

### Android: "Sign-In Error"

**원인**: SHA-1 미등록 또는 Application ID 불일치

**해결**:

1. `./gradlew signingReport`로 SHA-1 확인
2. Google Cloud Console에 SHA-1 등록
3. `applicationId` 일치 확인

### Web: "popup_closed_by_user"

**원인**: 사용자가 팝업을 닫음

**해결**: 정상 동작 (오류 아님)

### Supabase: "Invalid ID Token"

**원인**: Google OAuth Client ID/Secret 불일치

**해결**:

1. Supabase Dashboard에서 Google Provider 설정 확인
2. **Web Application** Client ID/Secret 사용 확인
3. Google Cloud Console에서 Client ID 확인

### "Nonces mismatch"

**원인**: Google Sign-In SDK가 `serverClientId` 사용 시 nonce를 자동 생성

**해결**:

- ✅ **serverClientId 제거** (현재 구현)
- ✅ **nonce 파라미터 없이 signInWithIdToken 호출**
- ✅ 플랫폼별 Client ID는 네이티브 설정에서 자동 사용

**상세 가이드**: `NONCE_ISSUE_SOLVED.md` 참조

---

## 📊 테스트

### 단위 테스트

```bash
flutter test test/unit/services/google_auth_native_test.dart
```

### 통합 테스트 (실제 기기)

```bash
# iOS
flutter run -d iPhone

# Android
flutter run -d <android-device-id>

# Web
flutter run -d chrome
```

**테스트 시나리오**:

1. ✅ Google 로그인 버튼 클릭
2. ✅ Google 계정 선택
3. ✅ 앱으로 즉시 복귀 (브라우저 없음)
4. ✅ 홈 화면에서 사용자 정보 표시
5. ✅ 로그아웃 후 로그인 화면으로 이동
6. ✅ 앱 재시작 후 세션 유지 확인

---

## 📝 변경 사항 요약

### 삭제된 기능

- ❌ `signInWithOAuth` (OAuth 리다이렉트)
- ❌ `redirectTo` 파라미터
- ❌ Deep Link 처리
- ❌ URL Scheme 복잡한 설정
- ❌ `LaunchMode.externalApplication`
- ❌ `SupabaseOAuthValidator` (불필요)

### 추가된 기능

- ✅ 네이티브 Google Sign-In (모든 플랫폼)
- ✅ `signInWithIdToken` (ID Token 직접 전달)
- ✅ 자동 프로필 생성/업데이트
- ✅ `getCurrentGoogleUser` (Silent Sign-In)
- ✅ `disconnect` (계정 연결 해제)

### 개선된 사항

- 🚀 브라우저 없음 (100% 네이티브)
- 🚀 딥링크 불필요
- 🚀 설정 단순화
- 🚀 오류 처리 개선
- 🚀 로그 강화

---

## 🎓 학습 포인트

### Why Google Sign-In SDK?

**Before (OAuth)**:

```
앱 → 브라우저 → Google → 리다이렉트 → 앱 (딥링크)
```

**After (Native SDK)**:

```
앱 → Google SDK (네이티브) → ID Token → Supabase
```

**장점**:

1. **UX 개선**: 브라우저 없음, 빠른 로그인
2. **보안 강화**: 네이티브 플로우, 피싱 방지
3. **설정 단순화**: redirectTo/딥링크 불필요
4. **신뢰성 향상**: OAuth 리다이렉트 오류 제거

### Why signInWithIdToken?

**Supabase의 `signInWithOAuth`**:

- 브라우저 필수
- 리다이렉트 필요
- 모바일에서 복잡

**Supabase의 `signInWithIdToken`**:

- ID Token만 필요
- 직접 인증
- 모든 플랫폼 동일

---

## 🔐 보안 고려사항

### serverClientId

```dart
serverClientId: 'YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com'
```

**역할**: ID Token 검증

**주의**:

- ✅ **Web Application** Client ID 사용
- ❌ iOS/Android Client ID 사용 금지
- 🔒 Client Secret은 백엔드에만 저장

### ID Token

**특징**:

- 짧은 수명 (1시간)
- Supabase가 검증
- 사용자 정보 포함 (JWT)

**안전한 이유**:

- Google이 서명
- Supabase가 검증
- 재사용 불가

---

## 📚 참고 자료

- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Supabase Auth - Google](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart)

---

## ✨ 다음 단계

### 권장 추가 기능

1. **Biometric Authentication**

   ```dart
   // Face ID / Touch ID / Fingerprint
   await LocalAuthentication().authenticate();
   ```

2. **Offline Support**

   ```dart
   // Supabase Realtime + Local DB
   await SupabaseConfig.client.realtime.channel('changes');
   ```

3. **Multi-Account Support**

   ```dart
   // Google Sign-In 멀티 계정
   await _googleSignIn.signIn(); // 계정 선택 UI
   ```

4. **Apple Sign In**
   ```dart
   // Apple Sign In 추가
   await SignInWithApple.getAppleIDCredential();
   ```

---

## 🎉 완료!

이제 앱에서 **브라우저 없이, 딥링크 없이, 즉시 로그인**이 가능합니다!

모든 플랫폼에서 동일한 로직으로 안전하고 빠르게 Google 로그인을 제공합니다.

**테스트해보세요**: `flutter run` → Google 로그인 버튼 클릭 → 즉시 로그인 완료! 🚀
