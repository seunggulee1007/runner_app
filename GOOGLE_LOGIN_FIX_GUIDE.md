# Google 로그인 문제 해결 가이드

## 🚨 현재 상황

Google 로그인 시 다음 오류가 발생하고 있습니다:

```
PlatformException(Error, Error while launching https://YOUR-PROJECT-ID.supabase.co/auth/v1/authorize?provider=google...)
```

이 오류는 **Supabase Google OAuth Provider 설정이 완료되지 않았을 때** 발생합니다.

## ✅ 해결 방법 (단계별)

### 1단계: Supabase 대시보드 접속

1. [Supabase 대시보드](https://supabase.com/dashboard) 접속
2. 프로젝트 선택: `runner-app` (ID: `YOUR-PROJECT-ID`)

### 2단계: URL Configuration 설정

1. 좌측 메뉴에서 **Authentication** 클릭
2. **URL Configuration** 탭 선택
3. 다음 설정 추가:

#### Site URL

```
http://localhost:3000
```

또는 배포된 앱의 도메인:

```
https://your-app-domain.com
```

#### Redirect URLs

다음 URL들을 **하나씩** 추가:

```
com.example.runnerApp://
com.example.runnerApp://login-callback
https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
```

**중요**: 각 URL을 엔터로 구분하여 추가하고 **Save** 버튼 클릭

### 3단계: Google Cloud Console 설정

#### 3.1 프로젝트 생성 또는 선택

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 기존 프로젝트 선택 또는 새 프로젝트 생성

#### 3.2 OAuth 동의 화면 설정

1. **APIs & Services** > **OAuth consent screen** 이동
2. User Type: **External** 선택 (내부 사용자만이면 Internal)
3. 앱 정보 입력:
   - App name: `StrideNote` 또는 원하는 이름
   - User support email: 본인 이메일
   - Developer contact email: 본인 이메일
4. **Save and Continue** 클릭
5. Scopes 단계: 기본값 유지 후 **Save and Continue**
6. Test users 추가 (개발 중에만 필요)
7. **Save and Continue** 클릭

#### 3.3 OAuth 2.0 클라이언트 ID 생성

1. **APIs & Services** > **Credentials** 이동
2. **+ CREATE CREDENTIALS** 클릭
3. **OAuth 2.0 Client ID** 선택

#### iOS 클라이언트 생성:

1. Application type: **iOS**
2. Name: `StrideNote iOS`
3. Bundle ID: `com.example.runnerApp`
4. **CREATE** 클릭
5. 생성된 **Client ID** 복사 (나중에 사용)

#### Android 클라이언트 생성 (선택사항):

1. Application type: **Android**
2. Name: `StrideNote Android`
3. Package name: `com.example.runnerApp`
4. SHA-1 certificate fingerprint: 개발/배포 인증서의 SHA-1
   ```bash
   # 디버그 인증서 SHA-1 얻기
   cd android
   ./gradlew signingReport
   ```
5. **CREATE** 클릭

#### Web 클라이언트 생성 (Supabase용):

1. Application type: **Web application**
2. Name: `StrideNote Web (Supabase)`
3. Authorized redirect URIs에 다음 추가:
   ```
   https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
   ```
4. **CREATE** 클릭
5. 생성된 **Client ID**와 **Client Secret** 복사

### 4단계: Supabase Google Provider 설정

1. Supabase 대시보드로 돌아가기
2. **Authentication** > **Providers** 탭 선택
3. **Google** Provider 찾기
4. **Enable Sign in with Google** 토글 켜기
5. 설정 입력:
   - **Client ID (for OAuth)**: Web 클라이언트의 Client ID 입력
   - **Client Secret (for OAuth)**: Web 클라이언트의 Client Secret 입력
6. **Save** 버튼 클릭

### 5단계: iOS Info.plist 업데이트 (이미 완료됨)

✅ 이미 올바르게 설정되어 있습니다:

- Bundle ID: `com.example.runnerApp`
- URL Scheme: `com.example.runnerApp`

### 6단계: Android 설정 확인 (이미 완료됨)

✅ 이미 올바르게 설정되어 있습니다:

- Package name: `com.example.runnerApp`
- URL Scheme: `com.example.runnerApp`

## 🧪 테스트

설정 완료 후:

1. 앱을 완전히 종료
2. 앱 재실행
3. Google 로그인 버튼 클릭
4. Google 계정 선택 화면이 나타나는지 확인

### 예상되는 동작:

1. Google 로그인 버튼 클릭
2. Safari/Chrome이 열리면서 Google 로그인 페이지 표시
3. Google 계정 선택
4. 권한 동의 화면
5. 앱으로 리다이렉트
6. 로그인 완료

## 🔍 문제 해결 체크리스트

- [ ] Supabase Site URL이 설정되어 있는가?
- [ ] Supabase Redirect URLs에 `com.example.runnerApp://`가 추가되어 있는가?
- [ ] Google Cloud Console에서 OAuth 동의 화면이 설정되어 있는가?
- [ ] Google Cloud Console에서 Web 클라이언트가 생성되어 있는가?
- [ ] Supabase Google Provider가 활성화되어 있는가?
- [ ] Supabase Google Provider에 올바른 Client ID/Secret이 입력되어 있는가?
- [ ] Google Cloud Console의 Authorized redirect URIs에 Supabase 콜백 URL이 추가되어 있는가?

## ⚠️ 주의사항

### 1. OAuth 동의 화면 상태

- **Testing**: 추가된 테스트 사용자만 로그인 가능
- **In Production**: 모든 Google 계정 사용자 로그인 가능

개발 중에는 Testing 상태로 두고, 본인 이메일을 테스트 사용자로 추가하세요.

### 2. Client ID/Secret

- **Web 클라이언트**의 Client ID/Secret을 Supabase에 입력해야 합니다
- iOS/Android 클라이언트 ID는 앱에 직접 사용하지 않습니다 (Supabase가 처리)

### 3. Bundle ID 일치

- Google Cloud Console의 Bundle ID: `com.example.runnerApp`
- iOS Info.plist의 Bundle ID: `com.example.runnerApp`
- Android build.gradle의 Package name: `com.example.runnerApp`

모두 일치해야 합니다.

## 📞 추가 도움

설정 후에도 문제가 지속되면:

1. **Supabase 로그 확인**:

   - Dashboard > Settings > API > Auth logs

2. **Google Cloud Console 로그 확인**:

   - APIs & Services > Credentials > OAuth 2.0 Client IDs

3. **앱 로그 확인**:
   - Xcode Console 또는 Android Logcat에서 상세 오류 확인

## 🎯 성공 시 예상 로그

```
[GoogleAuthService] Supabase 네이티브 Google 로그인 시작
[OAuthValidator] === Supabase OAuth 설정 검증 시작 ===
[OAuthValidator] ✅ Supabase 클라이언트 초기화 완료
[OAuthValidator] ✅ Supabase URL: https://YOUR-PROJECT-ID.supabase.co
[GoogleAuthService] Google OAuth 응답: true
[AuthProvider] Auth state changed: your-email@gmail.com
[GoogleAuthService] 로그인 성공 처리 시작: your-email@gmail.com
```
