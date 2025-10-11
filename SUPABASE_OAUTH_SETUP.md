# Supabase OAuth 설정 가이드

## 🔧 현재 문제 상황

Google 로그인 시 다음과 같은 오류가 발생하고 있습니다:

```
PlatformException(Error, Error while launching https://YOUR-PROJECT-ID.supabase.co/auth/v1/authorize?provider=google&redirect_to=com.example.runnerApp%3A%2F%2F&flow_type=pkce&code_challenge=...)
```

## 📋 해결 방법

### 1. Supabase 대시보드 설정

#### 1.1 Authentication > URL Configuration

1. Supabase 대시보드에 로그인
2. 프로젝트 선택: `YOUR-PROJECT-ID`
3. **Authentication** > **URL Configuration** 이동

#### 1.2 Site URL 설정

```
https://your-app-domain.com
```

또는 개발용으로:

```
http://localhost:3000
```

#### 1.3 Redirect URLs 설정

다음 URL들을 추가:

```
com.example.runnerApp://
https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
https://your-app-domain.com/auth/callback
```

### 2. Google OAuth Provider 설정

#### 2.1 Authentication > Providers

1. **Authentication** > **Providers** 이동
2. **Google** Provider 활성화

#### 2.2 Google OAuth 설정

- **Client ID**: Google Cloud Console에서 생성한 OAuth 2.0 클라이언트 ID
- **Client Secret**: Google Cloud Console에서 생성한 OAuth 2.0 클라이언트 시크릿

### 3. Google Cloud Console 설정

#### 3.1 OAuth 2.0 클라이언트 ID 생성

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 선택 또는 새 프로젝트 생성
3. **APIs & Services** > **Credentials** 이동
4. **Create Credentials** > **OAuth 2.0 Client ID** 선택

#### 3.2 애플리케이션 유형 설정

- **Application type**: `iOS` 또는 `Android` 선택
- **Bundle ID**: `com.example.runnerApp`

#### 3.3 Authorized redirect URIs 설정

다음 URI들을 추가:

```
https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
com.example.runnerApp://
```

### 4. 현재 앱 설정 확인

#### 4.1 Bundle ID

- **Android**: `com.example.runnerApp` (build.gradle.kts)
- **iOS**: `com.example.runnerApp` (Info.plist)

#### 4.2 URL Scheme

- **Android**: `com.example.runnerApp` (AndroidManifest.xml)
- **iOS**: `com.example.runnerApp` (Info.plist)

#### 4.3 Google OAuth Client ID

- **iOS**: `com.googleusercontent.apps.YOUR-GOOGLE-CLIENT-ID` (Info.plist)

## 🔍 설정 검증

앱을 실행하면 콘솔에 다음과 같은 검증 로그가 출력됩니다:

```
=== Supabase OAuth 설정 검증 시작 ===
✅ Supabase 클라이언트 초기화 완료
✅ Supabase URL: https://YOUR-PROJECT-ID.supabase.co
✅ Anonymous Key: YOUR-SUPABASE-ANON-KEY
✅ OAuth URL 구성: https://YOUR-PROJECT-ID.supabase.co/auth/v1/authorize?provider=google&redirect_to=com.example.runnerApp%3A%2F%2F&flow_type=pkce
=== 설정 확인 필요사항 ===
```

## 🚨 문제 해결 체크리스트

- [ ] Supabase Site URL이 올바르게 설정되어 있는가?
- [ ] Supabase Redirect URLs에 `com.example.runnerApp://`가 추가되어 있는가?
- [ ] Google OAuth Provider가 Supabase에서 활성화되어 있는가?
- [ ] Google Cloud Console에서 올바른 Bundle ID가 설정되어 있는가?
- [ ] Google Cloud Console에서 Authorized redirect URIs가 올바르게 설정되어 있는가?
- [ ] Google OAuth Client ID와 Secret이 Supabase에 올바르게 설정되어 있는가?

## 📞 추가 도움

설정 후에도 문제가 지속되면:

1. Supabase 대시보드의 Authentication 로그 확인
2. Google Cloud Console의 OAuth 동의 화면 설정 확인
3. 앱의 Bundle ID와 Google Cloud Console의 Bundle ID 일치 확인
