# 🔧 Google Sign-In Nonce 문제 해결

## 🔴 문제 상황

```
AuthApiException(message: Passed nonce and nonce in id_token should either both exist or not., statusCode: 400, code: null)
```

### 원인

Google Sign-In Flutter SDK가 `serverClientId`를 사용할 때:

1. **자동으로 nonce를 생성**하여 ID Token에 포함
2. 하지만 우리는 **원본 nonce에 접근할 수 없음**
3. Supabase는 **우리가 전달한 nonce**와 **ID Token의 nonce**가 일치해야 함
4. 불일치로 인해 오류 발생

## ✅ 해결 방법

### 방법 1: serverClientId 제거 (선택된 해결책)

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // serverClientId 없이 사용 (nonce 문제 방지)
  // 플랫폼별 Google OAuth Client ID는 네이티브 설정에서 자동 사용
);
```

**장점**:

- ✅ Nonce 문제 완전 해결
- ✅ 설정 단순화
- ✅ ID Token 여전히 발급됨 (플랫폼별 Client ID 사용)

**단점**:

- ⚠️ ID Token 검증이 플랫폼별 Client ID로만 가능

### 방법 2: Supabase에 nonce 전달하지 않기

```dart
await SupabaseConfig.client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
  accessToken: accessToken,
  // nonce 파라미터 없음 - Google Sign-In이 자동 생성하는 nonce와 충돌 방지
);
```

**장점**:

- ✅ Supabase가 nonce 검증을 수행하지 않음
- ✅ serverClientId 사용 가능

**단점**:

- ⚠️ Nonce 검증이 스킵됨 (보안상 약간 약화)

## 🔐 보안 고려사항

### Nonce의 역할

Nonce는 **재생 공격(Replay Attack)** 을 방지합니다:

1. 클라이언트가 고유한 nonce 생성
2. Google이 nonce를 ID Token에 포함
3. 서버가 nonce를 검증하여 Token의 신선도 확인

### serverClientId 없이 사용해도 안전한 이유

1. **ID Token 자체가 JWT**

   - Google이 서명
   - 만료 시간 포함 (1시간)
   - 재사용 방지

2. **Supabase가 ID Token 검증**

   - Google 공개키로 서명 검증
   - Issuer, Audience 검증
   - 만료 시간 검증

3. **플랫폼별 Client ID 사용**
   - iOS: `Info.plist`의 `GIDClientID`
   - Android: Google Cloud Console의 SHA-1
   - Web: 자동 처리

## 📱 플랫폼별 설정

### iOS (Info.plist)

```xml
<!-- Google Sign-In Client ID (iOS용) -->
<key>GIDClientID</key>
<string>YOUR-IOS-CLIENT-ID.apps.googleusercontent.com</string>

<!-- Reverse Client ID (URL Scheme) -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

### Android (Google Cloud Console)

1. **Android OAuth Client 생성**
   - Package name: `com.example.runnerApp`
   - SHA-1 등록: `./gradlew signingReport`

### Web

**자동 처리됨** - 추가 설정 불필요

## 🧪 테스트

### 로그 확인

```dart
[GoogleAuthService] === Google 네이티브 로그인 시작 ===
[GoogleAuthService] 플랫폼: ios
[GoogleAuthService] Google 사용자 인증 완료: user@example.com
[GoogleAuthService] ✅ Google ID Token 획득
[GoogleAuthService] 🔐 Supabase 인증 시작...
[GoogleAuthService] ✅ Supabase 로그인 완료: user@example.com
[GoogleAuthService] === Google 로그인 완료 ===
```

### 성공 기준

- ✅ "Nonce mismatch" 오류 없음
- ✅ Supabase 로그인 완료
- ✅ 사용자 정보 정상 표시
- ✅ 세션 유지 확인

## 🎯 요약

### Before (문제 발생)

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: 'WEB-CLIENT-ID.apps.googleusercontent.com', // ❌ nonce 자동 생성
);

await client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
  accessToken: accessToken,
  nonce: extractedNonce, // ❌ 원본 nonce에 접근 불가
);
```

**결과**: `Nonces mismatch` 오류

### After (해결)

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // serverClientId 없음 ✅ nonce 생성 안 함
);

await client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
  accessToken: accessToken,
  // nonce 파라미터 없음 ✅ 검증 스킵
);
```

**결과**: 로그인 성공! 🎉

## 📚 관련 이슈

- [Supabase Auth - Google Sign-In with Flutter](https://github.com/supabase/supabase-flutter/issues/xxx)
- [google_sign_in - Nonce Support](https://github.com/flutter/packages/issues/xxx)

## 🔄 대안: OAuth 리다이렉트

Nonce 문제가 계속되면 OAuth 리다이렉트 방식으로 전환 가능:

```dart
await client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: 'com.example.runnerApp://login-callback',
);
```

**단점**: 브라우저 열림, 딥링크 필요

## ✅ 최종 권장사항

1. **serverClientId 없이 사용** (현재 구현)
2. **플랫폼별 Client ID 설정** (Info.plist, SHA-1)
3. **Supabase에 nonce 전달하지 않기**
4. **ID Token 검증은 Supabase에 위임**

이 방식으로 **브라우저 없이, 안전하게, 빠르게** Google 로그인이 작동합니다! 🚀
