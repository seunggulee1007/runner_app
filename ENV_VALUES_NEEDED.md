# 🔑 필수: 실제 키 값 입력 필요

## ❌ 현재 문제

`.env` 파일에 템플릿 값이 그대로 있어서 앱이 다음 URL에 접속 시도:

```
https://your-project-id.supabase.co  ← 이건 존재하지 않는 주소!
```

따라서 에러 발생:

```
Failed host lookup: 'your-project-id.supabase.co'
```

## ✅ 해결: 실제 키 입력

다음 3가지 **실제 값**을 입력해야 합니다:

### 1️⃣ Supabase Project URL

**어디서 가져오나요?**

1. 브라우저에서 열기: https://supabase.com/dashboard
2. 로그인 후 프로젝트 선택
3. 왼쪽 메뉴: **Settings** (톱니바퀴 아이콘)
4. **API** 클릭
5. **Project URL** 복사
   - 형식: `https://xktqfxjbmxqzuvwmfuae.supabase.co`
   - 15-20자 정도의 랜덤 ID가 포함됨

📋 **복사한 값**:

```
SUPABASE_URL=
```

---

### 2️⃣ Supabase Anon Key

**어디서 가져오나요?**

1. 같은 페이지 (Settings → API)
2. **Project API keys** 섹션
3. **anon** **public** 키 복사 (매우 긴 문자열)
   - ⚠️ `service_role` 키가 아님!
   - 형식: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (200자 이상)

📋 **복사한 값**:

```
SUPABASE_ANON_KEY=
```

---

### 3️⃣ Google Web Client ID

**어디서 가져오나요?**

1. 브라우저에서 열기: https://console.cloud.google.com
2. 프로젝트 선택
3. 왼쪽 메뉴: **APIs & Services** → **Credentials**
4. **OAuth 2.0 Client IDs** 섹션 찾기
5. **Web client (auto created by Google Service)** 클릭
   - ⚠️ iOS 또는 Android가 아님!
6. **Client ID** 복사
   - 형식: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

📋 **복사한 값**:

```
GOOGLE_WEB_CLIENT_ID=
```

---

## 🎯 다음 단계

### 옵션 1: 대화형 스크립트 (가장 쉬움! ⭐)

터미널에서 실행:

```bash
bash scripts/setup_env.sh
```

위에서 복사한 3개 값을 붙여넣기만 하면 됩니다!

### 옵션 2: 직접 입력

`.env` 파일을 직접 편집:

```bash
code .env
```

다음 3줄을 찾아서 실제 값으로 변경:

```env
SUPABASE_URL=위에서_복사한_URL
SUPABASE_ANON_KEY=위에서_복사한_긴_키
GOOGLE_WEB_CLIENT_ID=위에서_복사한_클라이언트_ID
```

---

## 💡 빠른 확인

값을 입력했다면 확인:

```bash
bash scripts/check_env.sh
```

**성공 시:**

```
✅ SUPABASE_URL: https://xktqfx...
✅ SUPABASE_ANON_KEY: eyJhbGciOiJIU...
✅ GOOGLE_WEB_CLIENT_ID: 123456789-a...
✅ 모든 필수 환경 변수가 설정되었습니다!
```

---

## 🚀 최종 단계: 앱 재시작

⚠️ **중요**: Hot Restart는 작동하지 않습니다!

```bash
# 앱 완전 종료 후
flutter clean
flutter pub get
flutter run
```

---

## 📸 스크린샷 가이드

### Supabase Dashboard

```
┌─────────────────────────────────────┐
│ Settings > API                      │
├─────────────────────────────────────┤
│ Project URL:                        │
│ https://xktqfx...supabase.co [복사] │
│                                     │
│ Project API keys:                   │
│ anon public: eyJhbG... [복사]       │
│ service_role: eyJhbG... (사용X)     │
└─────────────────────────────────────┘
```

### Google Cloud Console

```
┌─────────────────────────────────────┐
│ Credentials                         │
├─────────────────────────────────────┤
│ OAuth 2.0 Client IDs                │
│                                     │
│ ☑ Web client                        │
│   123456789-abc...com [복사]        │
│                                     │
│ ☐ iOS client (사용X)                │
│ ☐ Android client (사용X)            │
└─────────────────────────────────────┘
```

---

**준비되셨나요?** 위의 3가지 값을 복사한 후:

- **쉬운 방법**: `bash scripts/setup_env.sh` 실행
- **수동 방법**: `code .env` 열어서 직접 수정

둘 다 어렵다면 여기 이슈에 3가지 값을 알려주시면 제가 직접 `.env` 파일을 생성해드리겠습니다! 🎯
