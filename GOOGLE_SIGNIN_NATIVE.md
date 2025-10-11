# Google 네이티브 로그인 가이드

## 🎯 개요

이 앱은 **플랫폼별로 최적화된 Google 로그인**을 제공합니다:

- **모바일 (iOS/Android)**: 네이티브 Google Sign-In → Supabase ID Token 인증
- **웹**: Supabase OAuth 리다이렉트 인증

## 🏗️ 아키텍처

### 모바일 플로우

```
사용자 → Google Sign-In SDK → Google 인증
→ ID Token 획득 → Supabase signInWithIdToken
→ 로그인 완료
```

### 웹 플로우

```
사용자 → Supabase OAuth → Google 인증 페이지
→ 리다이렉트 → Supabase 세션 생성
→ 로그인 완료
```

## 📋 구현 상세

### GoogleAuthService 구조

```dart
class GoogleAuthService {
  // Google Sign-In 초기화 (serverClientId 필수!)
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: 'YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com',
  );

  // 플랫폼 분기
  static Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return await _signInWithGoogleWeb();
    } else {
      return await _signInWithGoogleMobile();
    }
  }

  // 웹: OAuth 리다이렉트
  static Future<bool> _signInWithGoogleWeb() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'com.example.runnerApp://login-callback',
    );
  }

  // 모바일: 네이티브 + ID Token
  static Future<bool> _signInWithGoogleMobile() async {
    // 1. Google Sign-In
    final googleUser = await _googleSignIn.signIn();

    // 2. ID Token 획득
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    // 3. Supabase 인증
    await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }
}
```

## 🔧 설정

### 1. iOS 설정

#### Info.plist

```xml
<!-- Google Sign-In Client ID -->
<key>GIDClientID</key>
<string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>

<!-- URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
  <!-- Google OAuth -->
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>

  <!-- Supabase OAuth -->
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.example.runnerApp</string>
    </array>
  </dict>
</array>
```

### 2. Android 설정

#### AndroidManifest.xml

```xml
<!-- Supabase OAuth -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="com.example.runnerApp"
    android:host="login-callback" />
</intent-filter>
```

#### google-services.json (선택사항)

Google Cloud Console에서 다운로드하여 `android/app/` 디렉토리에 배치

### 3. Google Cloud Console 설정

#### iOS OAuth Client

- Application type: **iOS**
- Bundle ID: `com.example.runnerApp`

#### Android OAuth Client

- Application type: **Android**
- Package name: `com.example.stride_note`
- SHA-1 certificate fingerprint: (개발/배포 인증서)

#### Web OAuth Client (Supabase용)

- Application type: **Web application**
- Authorized redirect URIs:
  ```
  https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
  ```

### 4. Supabase 설정

#### Authentication > Providers > Google

- **Enable Sign in with Google**: ✅
- **Client ID (for OAuth)**: Web 클라이언트 ID
- **Client Secret (for OAuth)**: Web 클라이언트 Secret

#### Authentication > URL Configuration

- **Redirect URLs**:
  ```
  com.example.runnerApp://login-callback
  https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
  ```

## 🧪 테스트

### 단위 테스트

```bash
flutter test test/unit/services/google_auth_platform_test.dart
```

### 통합 테스트

```bash
# 모바일 (iOS)
flutter run -d iphone

# 모바일 (Android)
flutter run -d android

# 웹
flutter run -d chrome
```

## 🎯 사용자 경험

### 모바일

1. "Google로 계속하기" 버튼 클릭
2. 네이티브 Google 계정 선택 화면 (앱 내)
3. 권한 동의 (필요시)
4. 즉시 앱으로 복귀 및 로그인 완료

### 웹

1. "Google로 계속하기" 버튼 클릭
2. Google 로그인 페이지로 리다이렉트 (새 탭)
3. 계정 선택 및 권한 동의
4. 앱으로 리다이렉트 및 로그인 완료

## 🚨 문제 해결

### 모바일: 앱 크래시 (EXC_CRASH SIGABRT)

**원인**: `GoogleSignIn` 초기화 시 `serverClientId` 누락

**해결**:

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: 'YOUR-WEB-CLIENT-ID.apps.googleusercontent.com', // 필수!
);
```

**주의**: `serverClientId`는 **Web Application** Client ID를 사용!

### 모바일: "Google Sign-In failed"

→ iOS Info.plist의 `GIDClientID` 확인
→ Google Cloud Console의 iOS 클라이언트 Bundle ID 확인
→ `serverClientId`가 Web Client ID인지 확인

### 모바일: "ID Token is null"

→ `serverClientId` 설정 확인 (가장 흔한 원인)
→ Google Cloud Console의 Web OAuth Client 설정 확인
→ Supabase에 올바른 Web Client ID/Secret 설정 확인

### 웹: "redirect_uri_mismatch"

→ Google Cloud Console의 Authorized redirect URIs 확인
→ Supabase 콜백 URL 추가 확인

### 모든 플랫폼: "Supabase signInWithIdToken failed"

→ Supabase Google Provider 활성화 확인
→ Google OAuth Client ID/Secret 설정 확인

## 📊 장점

### 모바일 네이티브 로그인

✅ 더 나은 UX (앱 내에서 완결)
✅ 빠른 인증 (브라우저 전환 불필요)
✅ 더 안정적 (URL Scheme 이슈 없음)
✅ 더 안전함 (ID Token 직접 검증)

### 웹 OAuth 리다이렉트

✅ 표준 OAuth 플로우
✅ 추가 SDK 불필요
✅ Supabase 네이티브 지원
✅ 간단한 설정

## 🔄 로그아웃

```dart
await GoogleAuthService.signOut();
```

- 모바일: Google Sign-In SDK 로그아웃 + Supabase 로그아웃
- 웹: Supabase 로그아웃만 수행

## 📝 참고 문서

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Supabase Auth with Google](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
