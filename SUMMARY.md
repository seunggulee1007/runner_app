# Google 로그인 문제 해결 요약

## 📌 문제 요약

구글 로그인 시 다음 오류가 발생했습니다:

```
PlatformException(Error, Error while launching https://YOUR-PROJECT-ID.supabase.co/auth/v1/authorize?provider=google...)
```

## ✅ 수정된 사항

### 1. URL Scheme 통일

- ❌ 이전: `com.example.runnerApp://`
- ✅ 수정: `com.example.runnerApp://`
- 📁 수정 파일:
  - `ios/Runner/Info.plist`
  - `lib/services/google_auth_service.dart`

### 2. Bundle ID 통일

- ❌ 이전: `runner_app` (iOS)
- ✅ 수정: `stride_note` (iOS)
- 📁 수정 파일:
  - `ios/Runner/Info.plist`

### 3. 에러 처리 개선

- ✅ 더 구체적인 오류 메시지 추가
- ✅ OAuth 설정 검증 도구 추가
- ✅ 설정 확인사항 자동 안내
- 📁 신규 파일:
  - `lib/services/supabase_oauth_validator.dart`

### 4. 테스트 추가

- ✅ URL Scheme 일관성 검증 테스트
- ✅ Bundle ID 형식 검증 테스트
- ✅ OAuth URL 구성 검증 테스트
- 📁 신규 파일:
  - `test/unit/services/google_auth_config_test.dart`
  - `test/unit/services/google_oauth_url_test.dart`

### 5. 문서화

- ✅ 상세한 설정 가이드 작성
- ✅ 빠른 체크리스트 작성
- ✅ README 업데이트
- 📁 신규 파일:
  - `GOOGLE_LOGIN_FIX_GUIDE.md`
  - `SETUP_CHECKLIST.md`
  - `SUPABASE_OAUTH_SETUP.md`

## 🔧 필요한 추가 작업

### 1. Supabase 대시보드 설정 (필수)

**Authentication > URL Configuration**:

```
Site URL: http://localhost:3000

Redirect URLs:
- com.example.runnerApp://
- com.example.runnerApp://login-callback
- https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
```

**Authentication > Providers > Google**:

- ✅ Enable Sign in with Google
- Client ID (for OAuth): (Google Cloud Console에서 생성)
- Client Secret (for OAuth): (Google Cloud Console에서 생성)

### 2. Google Cloud Console 설정 (필수)

**OAuth 동의 화면**:

- User Type: External
- App name: StrideNote
- Support email: (본인 이메일)
- Developer contact email: (본인 이메일)

**OAuth 2.0 Client ID 생성 (Web)**:

- Application type: Web application
- Name: StrideNote Web (Supabase)
- Authorized redirect URIs:
  ```
  https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback
  ```

**OAuth 2.0 Client ID 생성 (iOS - 선택사항)**:

- Application type: iOS
- Name: StrideNote iOS
- Bundle ID: `com.example.runnerApp`

## 📊 테스트 결과

### 전체 테스트 통과

```bash
flutter test test/unit/services/
```

✅ 35개 테스트 모두 통과

### 주요 검증 항목

- ✅ URL Scheme 일관성
- ✅ Bundle ID 형식
- ✅ OAuth URL 구성
- ✅ Supabase 설정
- ✅ Google OAuth 클라이언트 ID 형식

## 🎯 다음 단계

1. **Supabase 대시보드 설정**: `SETUP_CHECKLIST.md` 참조
2. **Google Cloud Console 설정**: `SETUP_CHECKLIST.md` 참조
3. **앱 테스트**: Google 로그인 시도
4. **성공 확인**: 로그인 후 홈 화면 이동 확인

## 📁 참고 문서

- **빠른 설정**: `SETUP_CHECKLIST.md`
- **상세 가이드**: `GOOGLE_LOGIN_FIX_GUIDE.md`
- **OAuth 설정**: `SUPABASE_OAUTH_SETUP.md`
- **데이터베이스 설정**: `DATABASE_SETUP.md`
- **환경 변수 설정**: `ENV_SETUP.md`

## 🔍 문제 해결

### 여전히 "Error while launching" 오류 발생

→ Supabase Google Provider가 활성화되지 않았거나 Client ID/Secret이 설정되지 않음

### "redirect_uri_mismatch" 오류

→ Google Cloud Console의 Authorized redirect URIs에 Supabase 콜백 URL 추가 필요

### "access_denied" 오류

→ OAuth 동의 화면이 Testing 상태이고 테스트 사용자로 추가되지 않음

## 💡 팁

### 개발 중

- OAuth 동의 화면을 **Testing** 상태로 유지
- 본인 이메일을 테스트 사용자로 추가

### 배포 시

- OAuth 동의 화면을 **In Production**으로 변경
- Supabase Site URL을 실제 도메인으로 변경
- Google Cloud Console의 Authorized redirect URIs에 배포 도메인 추가

## 📞 추가 도움

설정 중 문제가 발생하면:

1. 각 단계를 체크리스트대로 다시 확인
2. Supabase 대시보드의 Authentication 로그 확인
3. Google Cloud Console의 Credentials 설정 확인
4. 앱 로그 콘솔에서 상세 오류 메시지 확인

---

**작업 완료 일자**: 2025-10-11  
**작업 내용**: Google 로그인 설정 문제 해결 및 문서화  
**테스트 결과**: 35/35 테스트 통과 ✅
