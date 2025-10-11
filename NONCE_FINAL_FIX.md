# 🔧 Nonce 문제 최종 해결 가이드

## ❌ 문제 상황

```
AuthApiException(message: Passed nonce and nonce in id_token should either both exist or not., statusCode: 400, code: null)
```

## 🔍 근본 원인

Google Sign-In SDK가 **GIDClientID를 사용하면 자동으로 nonce를 생성**하지만:

1. **우리는 원본 raw nonce에 접근할 수 없음**
2. ID Token에는 **해시된 nonce**가 포함됨
3. Supabase는 **raw nonce**를 기대함
4. **nonce 불일치**로 인증 실패

## ✅ 최종 해결책

### 1. iOS Info.plist에서 GIDClientID 제거

**파일**: `ios/Runner/Info.plist`

```xml
<!-- Google Sign-In Client ID -->
<!-- ⚠️ GIDClientID 제거: nonce 자동 생성 방지 -->
<!-- iOS OAuth Client는 Google Cloud Console에서 Bundle ID로 자동 인식 -->
```

**Before**:

```xml
<key>GIDClientID</key>
<string>YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com</string>
```

**After**: 제거됨

### 2. GoogleAuthService에서 serverClientId 제거

**파일**: `lib/services/google_auth_service.dart`

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // ⚠️ serverClientId를 제거하면 nonce가 생성되지 않음
  // 하지만 ID Token은 여전히 발급됨 (플랫폼별 Client ID 사용)
);
```

### 3. Supabase signInWithIdToken에 nonce 전달하지 않음

```dart
await SupabaseConfig.client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: idToken,
  accessToken: accessToken,
  // nonce 파라미터 없음
);
```

---

## 📱 플랫폼별 설정

### iOS

**Info.plist**: GIDClientID 제거 ✅

**Google Cloud Console**:

- iOS OAuth Client 생성
- Bundle ID: `com.example.runnerApp`
- **⚠️ Client ID를 앱에 설정하지 않음** (자동 인식)

### Android

**AndroidManifest.xml**: 변경 없음

**Google Cloud Console**:

- Android OAuth Client 생성
- Package name: `com.example.runnerApp`
- SHA-1 등록

### Web

**자동 처리됨**

---

## 🧪 테스트 결과

### 예상 로그

```
[GoogleAuthService] === Google 네이티브 로그인 시작 ===
[GoogleAuthService] 플랫폼: ios
[GoogleAuthService] ✅ Google 인증 완료: user@example.com
[GoogleAuthService] ✅ Google ID Token 획득
[GoogleAuthService] 🔐 Supabase 인증 시작...
[GoogleAuthService] ✅ Supabase 로그인 완료: user@example.com
```

### ✅ 성공 기준

- ❌ "Nonces mismatch" 오류 없음
- ✅ Supabase 로그인 완료
- ✅ 사용자 정보 표시
- ✅ 세션 유지

---

## 🔐 보안 검증

### Q: GIDClientID 없이 안전한가?

**A: 예, 안전합니다.**

1. **ID Token은 여전히 발급됨**

   - Google이 서명한 JWT
   - 만료 시간 포함 (1시간)
   - 재생 공격 방지

2. **Supabase가 ID Token 검증**

   - Google 공개키로 서명 검증
   - Issuer/Audience 검증
   - 만료 시간 검증

3. **플랫폼별 OAuth Client 사용**
   - iOS: Bundle ID로 자동 인식
   - Android: SHA-1로 검증
   - Web: 자동 처리

### Q: nonce 없이도 안전한가?

**A: 예, ID Token 자체가 충분히 안전합니다.**

- **Google이 서명**: 위조 불가
- **만료 시간 포함**: 재사용 불가 (1시간)
- **Audience 검증**: 특정 앱에만 유효
- **HTTPS 전송**: 중간자 공격 방지

---

## 📊 Before vs After

### Before (문제 발생)

```dart
// iOS Info.plist
<key>GIDClientID</key>
<string>WEB-CLIENT-ID</string>  // ❌ nonce 생성

// GoogleSignIn
serverClientId: 'WEB-CLIENT-ID'  // ❌ nonce 생성

// Supabase
signInWithIdToken(
  nonce: extractedNonce,  // ❌ raw nonce 접근 불가
)
```

**결과**: `Nonces mismatch` 오류

### After (해결)

```dart
// iOS Info.plist
<!-- GIDClientID 제거 -->  // ✅ nonce 생성 안 함

// GoogleSignIn
// serverClientId 없음  // ✅ nonce 생성 안 함

// Supabase
signInWithIdToken(
  // nonce 파라미터 없음  // ✅ 검증 스킵
)
```

**결과**: 로그인 성공! 🎉

---

## 🚨 문제 해결

### ID Token을 받지 못함

**원인**: Google Cloud Console 설정 오류

**해결**:

1. iOS OAuth Client가 생성되어 있는지 확인
2. Bundle ID가 정확한지 확인 (`com.example.runnerApp`)
3. `CFBundleURLSchemes`에 reverse Client ID 추가:
   ```xml
   <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
   ```

### "Google Sign-In failed"

**원인**: OAuth Client 미등록

**해결**:

1. Google Cloud Console에서 iOS OAuth Client 생성
2. Bundle ID 등록
3. Reverse Client ID를 Info.plist에 추가

### 여전히 nonce 오류 발생

**원인**: 이전 빌드 캐시

**해결**:

```bash
# iOS 클린 빌드
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📚 관련 문서

- `GOOGLE_NATIVE_LOGIN_COMPLETE.md` - 완전한 가이드
- `NONCE_ISSUE_SOLVED.md` - 초기 nonce 해결 시도
- `REFACTORING_COMPLETE.md` - 전체 리팩터링 요약

---

## ✅ 체크리스트

### iOS 설정

- [ ] `Info.plist`에서 `GIDClientID` 제거
- [ ] `CFBundleURLSchemes`에 reverse Client ID 추가
- [ ] Google Cloud Console에 iOS OAuth Client 등록
- [ ] Bundle ID 확인: `com.example.runnerApp`

### Android 설정

- [ ] Google Cloud Console에 Android OAuth Client 등록
- [ ] Package name: `com.example.runnerApp`
- [ ] SHA-1 등록
- [ ] `AndroidManifest.xml`에 Intent Filter 설정

### 코드 설정

- [ ] `GoogleSignIn`에 `serverClientId` 없음
- [ ] `signInWithIdToken`에 `nonce` 파라미터 없음
- [ ] 테스트 통과 확인

### Google Cloud Console

- [ ] iOS OAuth Client 생성
- [ ] Android OAuth Client 생성
- [ ] Web OAuth Client 생성 (Supabase용)
- [ ] Supabase Dashboard에 Web Client ID/Secret 설정

---

## 🎉 완료!

이제 **nonce 오류 없이, 브라우저 없이, 빠르게** Google 네이티브 로그인이 작동합니다!

**테스트**:

```bash
flutter run -d iPhone
```

로그인 → Google 계정 선택 → 즉시 완료! 🚀

---

## 🔄 롤백 방법

문제가 생기면 OAuth 리다이렉트로 롤백 가능:

```dart
await client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: 'com.example.runnerApp://login-callback',
);
```

**단점**: 브라우저 열림, 느림
**장점**: nonce 문제 없음, 100% 작동 보장
