# 🚀 빠른 해결 가이드 (Invalid API Key 오류)

## ❌ 오류 메시지

```
AuthApiException(message: Invalid API key, statusCode: 401, code: null)
```

## ✅ 해결 방법 (5분 소요)

### 1️⃣ `.env` 파일 열기

이미 열려있습니다! (또는 아래 명령어로 다시 열기)

```bash
open .env
```

### 2️⃣ 세 가지 값만 변경

**변경 전:**

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
GOOGLE_WEB_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
```

**변경 후:** (실제 값으로)

```env
SUPABASE_URL=https://실제프로젝트ID.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.실제키값...
GOOGLE_WEB_CLIENT_ID=123456789-실제아이디.apps.googleusercontent.com
```

### 3️⃣ 키 가져오는 방법

#### Supabase 키 가져오기:

1. https://supabase.com/dashboard 접속
2. 프로젝트 선택
3. **Settings** → **API**
4. 복사:
   - **Project URL**
   - **anon public** key

#### Google Web Client ID 가져오기:

1. https://console.cloud.google.com 접속
2. **APIs & Services** → **Credentials**
3. **OAuth 2.0 Client IDs** 섹션
4. **Web client** 찾기 (iOS/Android 아님!)
5. Client ID 복사

### 4️⃣ 저장 후 확인

```bash
# 환경 변수 확인
bash scripts/check_env.sh
```

**예상 출력:**

```
✅ SUPABASE_URL: https://abcdef...
✅ SUPABASE_ANON_KEY: eyJhbGciOiJIU...
✅ GOOGLE_WEB_CLIENT_ID: 123456789-abc...
✅ 모든 필수 환경 변수가 설정되었습니다!
```

### 5️⃣ 앱 재시작 (중요!)

```bash
# Hot Restart는 안됩니다! 완전 재시작 필요
flutter run
```

**성공 로그:**

```
✅ 환경 변수 로드 완료
✅ 환경 변수 검증 성공
✅ Supabase 초기화 완료
```

### 6️⃣ Google 로그인 테스트

이제 Google 로그인을 다시 시도하면 성공할 것입니다!

**성공 로그:**

```
[GoogleAuthService] === Google 네이티브 로그인 시작 ===
[GoogleAuthService] ✅ Google 인증 완료
[GoogleAuthService] ✅ Supabase 로그인 완료
[GoogleAuthService] === Google 로그인 완료 ===
```

## 🆘 여전히 안되나요?

### 문제 해결 체크리스트

- [ ] `.env` 파일이 프로젝트 루트에 있나요? (`pwd` 확인)
- [ ] 세 가지 필수 값을 모두 변경했나요?
- [ ] 값 앞뒤로 공백이 없나요?
- [ ] **Web** Client ID를 사용했나요? (iOS/Android 아님)
- [ ] Supabase **anon** key를 사용했나요? (service_role 아님)
- [ ] 앱을 **완전히** 재시작했나요? (Hot Restart X)

### 캐시 문제인 경우

```bash
flutter clean
flutter pub get
flutter run
```

## 📚 더 자세한 가이드

- `ENV_FIX_GUIDE.md` - 상세 문제 해결
- `ENV_CONFIG_GUIDE.md` - 환경 변수 전체 가이드

---

**소요 시간**: 5분  
**난이도**: ⭐ (매우 쉬움)  
**해결 확률**: 99%
