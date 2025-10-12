# 🔴 Invalid API Key 오류 해결 가이드

## ❌ 문제 상황

```
AuthApiException(message: Invalid API key, statusCode: 401, code: null)
```

Google 로그인은 성공했지만 Supabase 인증 시 위 오류가 발생합니다.

## 🔍 원인

`.env` 파일이 없거나 비어있어서 Supabase API 키가 로드되지 않았습니다.

## ✅ 해결 방법

### 1단계: Supabase 키 확인

1. **Supabase Dashboard** 접속: https://supabase.com/dashboard
2. **프로젝트 선택**
3. **Settings** → **API** 메뉴로 이동
4. 다음 정보를 복사해두세요:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 2단계: Google Web Client ID 확인

1. **Google Cloud Console** 접속: https://console.cloud.google.com
2. **APIs & Services** → **Credentials**
3. **OAuth 2.0 Client IDs** 섹션에서:
   - **Web client (auto created by Google Service)** 찾기
   - 클릭하여 **Client ID** 복사
   - 형식: `xxxxx-xxxxx.apps.googleusercontent.com`

⚠️ **주의**: iOS나 Android Client ID가 아닌 **Web Client ID**를 사용해야 합니다!

### 3단계: `.env` 파일 편집

프로젝트 루트에 생성된 `.env` 파일을 열어서 실제 값으로 변경하세요:

```bash
# VS Code에서 열기
code .env

# 또는 텍스트 에디터로
open .env
```

다음과 같이 실제 값을 입력하세요:

```env
# ======================================
# Supabase Configuration (필수)
# ======================================

SUPABASE_URL=https://your-actual-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-actual-key...

# ======================================
# Google OAuth Configuration (필수)
# ======================================

GOOGLE_WEB_CLIENT_ID=123456789-abcdefg.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=123456789-hijklmn.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=123456789-opqrstu.apps.googleusercontent.com

# ======================================
# App Configuration
# ======================================

BUNDLE_ID=com.example.runnerApp
```

### 4단계: 앱 완전 재시작

⚠️ **Hot Restart는 안됩니다!** 앱을 완전히 종료하고 다시 실행해야 합니다.

```bash
# 1. 실행 중인 앱 종료 (Ctrl+C 또는 Stop)

# 2. 캐시 삭제 (선택사항, 문제가 지속되면 실행)
flutter clean

# 3. 의존성 재설치
flutter pub get

# 4. 앱 재실행
flutter run
```

### 5단계: 환경 변수 로드 확인

앱 시작 시 다음 로그를 확인하세요:

```
✅ 환경 변수 로드 완료
✅ 환경 변수 검증 성공
=== 앱 설정 정보 ===
Supabase URL: https://xxxxx.supabase.co
Supabase Anon Key: eyJhbGciOi...xxxxx
Google Web Client ID: 123456789...xxxxx
==================
✅ Supabase 초기화 완료
```

❌ 만약 다음과 같은 로그가 보이면:

```
⚠️ 환경 변수 검증 실패:
SUPABASE_URL이 설정되지 않았습니다
```

→ `.env` 파일의 값을 다시 확인하고 앱을 완전히 재시작하세요.

## 🧪 테스트

### 1. Google 로그인 테스트

```
[GoogleAuthService] === Google 네이티브 로그인 시작 ===
[GoogleAuthService] ✅ Google 인증 완료: your-email@gmail.com
[GoogleAuthService] ✅ Google ID Token 획득
[GoogleAuthService] 🔐 Supabase 인증 시작...
[GoogleAuthService] ✅ Supabase 로그인 완료: your-email@gmail.com
[GoogleAuthService] === Google 로그인 완료 ===
```

### 2. 설정 검증 스크립트

터미널에서 다음 명령어를 실행하여 환경 변수를 확인할 수 있습니다:

```bash
# .env 파일 내용 확인 (민감한 정보 주의!)
cat .env
```

## 🔒 보안 주의사항

### ✅ DO (해야 할 것)

- `.env` 파일에 실제 키 저장
- `.gitignore`에 `.env` 등록 (이미 완료됨)
- 팀원들에게 `.env.example` 공유
- 각자 자신의 `.env` 파일 생성

### ❌ DON'T (하지 말아야 할 것)

- `.env` 파일을 Git에 커밋하지 마세요
- 코드에 키를 하드코딩하지 마세요
- 공개 채널에 키를 공유하지 마세요
- 스크린샷에 키가 보이지 않도록 주의하세요

## 📋 체크리스트

완료된 항목을 체크하세요:

- [ ] Supabase Dashboard에서 Project URL 복사
- [ ] Supabase Dashboard에서 anon public key 복사
- [ ] Google Cloud Console에서 Web Client ID 복사
- [ ] `.env` 파일 생성 확인 (`ls -la | grep .env`)
- [ ] `.env` 파일에 실제 값 입력
- [ ] 앱 완전 종료
- [ ] `flutter clean` 실행 (선택사항)
- [ ] `flutter pub get` 실행
- [ ] `flutter run` 실행
- [ ] 환경 변수 로드 로그 확인
- [ ] Google 로그인 테스트
- [ ] 로그인 성공 확인

## 🆘 여전히 문제가 있나요?

### 문제 1: `.env` 파일이 읽히지 않음

**증상**:

```
⚠️ .env 파일을 찾을 수 없습니다. 기본값을 사용합니다.
```

**해결**:

```bash
# 1. 파일 위치 확인
pwd  # /Users/nhn/Desktop/DEV/flutter-workspace/runner_app 이어야 함

# 2. .env 파일 존재 확인
ls -la .env

# 3. 파일 내용 확인
cat .env

# 4. 파일 권한 확인
chmod 644 .env
```

### 문제 2: 환경 변수 검증 실패

**증상**:

```
⚠️ 환경 변수 검증 실패:
GOOGLE_WEB_CLIENT_ID가 설정되지 않았습니다
```

**해결**:

- `.env` 파일에서 해당 변수가 `your-google-web-client-id`로 시작하는지 확인
- 실제 값으로 변경했는지 확인
- 줄 끝에 불필요한 공백이 없는지 확인

### 문제 3: Invalid API key 오류가 계속됨

**확인 사항**:

1. **올바른 Supabase 키 사용 확인**:

   - ❌ Service Role Key (절대 사용 금지!)
   - ✅ anon public key 사용

2. **Supabase URL 형식 확인**:

   - ✅ `https://xxxxx.supabase.co`
   - ❌ `https://xxxxx.supabase.co/` (마지막 슬래시 제거)

3. **키에 공백이 없는지 확인**:

   ```env
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   # 앞뒤로 공백 없어야 함
   ```

4. **캐시 완전 삭제**:
   ```bash
   flutter clean
   rm -rf build/
   flutter pub get
   flutter run
   ```

### 문제 4: Google 로그인 후 Supabase 인증 실패

**확인 사항**:

1. **Supabase Dashboard**에서 Google Provider 활성화 확인:

   - **Authentication** → **Providers** → **Google**
   - **Enable Sign in with Google** 체크
   - **Authorized Client IDs**에 Web Client ID 추가

2. **Google Cloud Console**에서 Authorized redirect URIs 확인:
   - `https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback`
   - `http://localhost:54321/auth/v1/callback` (로컬 개발용)

## 📚 관련 문서

- `ENV_CONFIG_GUIDE.md` - 환경 변수 상세 가이드
- `GOOGLE_NATIVE_LOGIN_COMPLETE.md` - Google 로그인 설정
- `DATABASE_SETUP.md` - 데이터베이스 설정
- `SETUP_CHECKLIST.md` - 전체 설정 체크리스트

## 🎯 다음 단계

환경 변수 설정이 완료되면:

1. ✅ Google 로그인 테스트
2. ✅ 이메일/비밀번호 로그인 테스트
3. ✅ 사용자 프로필 생성/조회 테스트
4. ✅ 로그아웃/로그인 반복 테스트

---

**마지막 수정**: 2025-10-12  
**문제 해결**: Invalid API key (401 오류)  
**상태**: ✅ 해결 완료
