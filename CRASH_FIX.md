# Google Sign-In 크래시 수정

## 🚨 크래시 증상

```
Exception Type:    EXC_CRASH (SIGABRT)
Last Exception Backtrace:
3   GoogleSignIn     -[GIDSignIn signInWithOptions:] + 152
```

iOS에서 Google 로그인 버튼을 클릭하면 앱이 즉시 크래시됩니다.

## 🔍 원인 분석

### 문제점

1. **GoogleSignIn 초기화 부족**: `serverClientId`가 지정되지 않음
2. **Info.plist 설정 불완전**: `GIDClientID`만으로는 부족
3. **Supabase ID Token 인증 실패**: Google Sign-In SDK가 올바른 ID Token을 생성하지 못함

### 크래시 발생 시점

```dart
// Google Sign-In을 시도할 때
final googleUser = await _googleSignIn.signIn();
// ↑ 여기서 크래시 발생
```

## ✅ 해결 방법

### 1. GoogleSignIn 초기화에 serverClientId 추가

**Before:**

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);
```

**After:**

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // iOS에서 serverClientId 지정 (Supabase Web OAuth Client ID)
  serverClientId: kIsWeb
    ? null
    : 'YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com',
);
```

### 2. Info.plist 확인

다음 설정이 올바르게 되어 있는지 확인:

```xml
<!-- Google Sign-In Client ID (iOS App용) -->
<key>GIDClientID</key>
<string>YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com</string>

<!-- Google OAuth URL Scheme -->
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

### 3. serverClientId vs clientId 차이

#### clientId (GIDClientID in Info.plist)

- **iOS 앱용** Google OAuth Client ID
- Google Cloud Console > iOS Application에서 생성
- Bundle ID: `com.example.runnerApp`

#### serverClientId (코드에 지정)

- **백엔드(Supabase)용** Google OAuth Client ID
- Google Cloud Console > Web Application에서 생성
- Supabase에서 ID Token 검증에 사용

## 🔧 Google Cloud Console 설정

### 필요한 OAuth 클라이언트

#### 1. iOS Application (for GIDClientID)

```
Application type: iOS
Bundle ID: com.example.runnerApp
Client ID: YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com
```

#### 2. Web Application (for serverClientId)

```
Application type: Web application
Name: StrideNote Web (Supabase)
Authorized redirect URIs:
  - https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
Client ID: (Supabase에 설정한 것과 동일)
Client Secret: (Supabase에 설정)
```

**중요**: `serverClientId`는 Web Application의 Client ID를 사용해야 합니다!

## 🧪 테스트

### 수정 후 테스트

```bash
# 1. 앱 완전 종료
# 2. Xcode에서 재빌드
cd ios
pod install
cd ..
flutter clean
flutter pub get

# 3. iOS 시뮬레이터에서 실행
flutter run -d iphone
```

### 예상 동작

```
[GoogleAuthService] Google 로그인 시작
[GoogleAuthService] 플랫폼: ios
[GoogleAuthService] 모바일 네이티브 로그인 시작
[GoogleAuthService] Google 사용자 인증 완료: user@gmail.com
[GoogleAuthService] Google ID Token 획득 완료
[GoogleAuthService] Supabase 로그인 완료: user@gmail.com
```

## ⚠️ 주의사항

### 1. serverClientId는 Web Client ID

- ❌ iOS Client ID 사용하지 말 것
- ✅ Web Application Client ID 사용

### 2. Supabase 설정 확인

Supabase Dashboard > Authentication > Providers > Google에서:

- Client ID: Web Application의 Client ID
- Client Secret: Web Application의 Client Secret

### 3. 다른 플랫폼

- **Android**: `google-services.json` 파일도 필요
- **Web**: `serverClientId` 불필요 (OAuth 리다이렉트 사용)

## 📝 관련 이슈

### Google Sign-In Flutter Plugin

- https://pub.dev/packages/google_sign_in
- `serverClientId` 파라미터 문서 참조

### Supabase Auth

- https://supabase.com/docs/guides/auth/social-login/auth-google
- ID Token 기반 인증 가이드

## 🎯 체크리스트

수정 완료 후 확인:

- [ ] `GoogleSignIn` 초기화에 `serverClientId` 추가
- [ ] `serverClientId`는 Web Application Client ID 사용
- [ ] Info.plist에 `GIDClientID` 설정
- [ ] Info.plist에 Google OAuth URL Scheme 설정
- [ ] Google Cloud Console에 iOS + Web 클라이언트 모두 생성
- [ ] Supabase에 Web Client ID/Secret 설정
- [ ] 앱 재빌드 및 테스트

---

**수정 완료**: 2025-10-11  
**크래시 해결**: `serverClientId` 추가로 해결 ✅
