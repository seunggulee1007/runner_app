# Google 로그인 설정 체크리스트

## 📝 빠른 설정 가이드

이 체크리스트를 따라 Google 로그인을 설정하세요.

---

## ✅ 1. Supabase 대시보드 설정

### 1.1 URL Configuration

- [ ] [Supabase 대시보드](https://supabase.com/dashboard) 접속
- [ ] 프로젝트 선택: `runner-app`
- [ ] **Authentication** > **URL Configuration** 이동
- [ ] **Site URL** 설정:
  ```
  http://localhost:3000
  ```
- [ ] **Redirect URLs**에 추가:
  ```
  com.example.runnerApp://
  com.example.runnerApp://login-callback
  https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
  ```
- [ ] **Save** 클릭

### 1.2 Google Provider 설정 (나중에)

- [ ] **Authentication** > **Providers** 이동
- [ ] **Google** Provider 찾기
- [ ] **Enable Sign in with Google** 토글 켜기 (Client ID/Secret 필요 - 다음 단계에서 얻음)

---

## ✅ 2. Google Cloud Console 설정

### 2.1 OAuth 동의 화면

- [ ] [Google Cloud Console](https://console.cloud.google.com/) 접속
- [ ] **APIs & Services** > **OAuth consent screen** 이동
- [ ] User Type: **External** 선택
- [ ] 앱 정보 입력:
  - App name: `StrideNote`
  - User support email: (본인 이메일)
  - Developer contact email: (본인 이메일)
- [ ] **Save and Continue** 클릭
- [ ] Scopes: 기본값 유지 후 **Save and Continue**
- [ ] Test users: 본인 이메일 추가 후 **Save and Continue**

### 2.2 Web 클라이언트 생성 (Supabase용)

- [ ] **APIs & Services** > **Credentials** 이동
- [ ] **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID** 선택
- [ ] Application type: **Web application**
- [ ] Name: `StrideNote Web (Supabase)`
- [ ] **Authorized redirect URIs**에 추가:
  ```
  https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
  ```
- [ ] **CREATE** 클릭
- [ ] **Client ID** 복사 → 메모장에 저장
- [ ] **Client Secret** 복사 → 메모장에 저장

### 2.3 iOS 클라이언트 생성 (선택사항)

- [ ] **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID** 선택
- [ ] Application type: **iOS**
- [ ] Name: `StrideNote iOS`
- [ ] Bundle ID: `com.example.runnerApp`
- [ ] **CREATE** 클릭

---

## ✅ 3. Supabase에 Google 설정 입력

- [ ] Supabase 대시보드로 돌아가기
- [ ] **Authentication** > **Providers** > **Google** 선택
- [ ] **Client ID (for OAuth)**: 2.2에서 복사한 Web Client ID 입력
- [ ] **Client Secret (for OAuth)**: 2.2에서 복사한 Web Client Secret 입력
- [ ] **Save** 클릭

---

## ✅ 4. 앱 테스트

- [ ] 앱 완전히 종료
- [ ] 앱 재실행
- [ ] Google 로그인 버튼 클릭
- [ ] Google 계정 선택 화면 확인
- [ ] 로그인 성공 확인

---

## 🎯 성공 시 예상 동작

1. ✅ Google 로그인 버튼 클릭
2. ✅ Safari/Chrome이 열리면서 Google 로그인 페이지 표시
3. ✅ Google 계정 선택
4. ✅ 권한 동의 화면
5. ✅ 앱으로 리다이렉트
6. ✅ 홈 화면으로 이동

---

## ❌ 실패 시 확인 사항

### "Error while launching" 오류

→ Supabase Google Provider가 활성화되지 않았거나 Client ID/Secret이 잘못됨

### "redirect_uri_mismatch" 오류

→ Google Cloud Console의 Authorized redirect URIs에 Supabase 콜백 URL 추가 필요

### "access_denied" 오류

→ OAuth 동의 화면이 Testing 상태이고 테스트 사용자로 추가되지 않음

---

## 📞 도움이 필요하면

`GOOGLE_LOGIN_FIX_GUIDE.md` 파일에서 더 자세한 설명을 확인하세요.
