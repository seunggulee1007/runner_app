# 🔐 환경 변수 설정 가이드

## 📋 개요

모든 민감한 키와 설정값을 `.env` 파일에서 중앙 관리합니다.
이를 통해:

- ✅ **보안 강화**: API 키가 코드에 하드코딩되지 않음
- ✅ **환경별 관리**: 개발/스테이징/프로덕션 분리
- ✅ **협업 용이**: `.env.example`로 필요한 설정 공유
- ✅ **Git 안전**: `.env`는 `.gitignore`에 등록됨

---

## 🚀 빠른 시작

### 1. `.env` 파일 생성

```bash
# .env.example을 복사하여 .env 생성
cp .env.example .env

# 또는 직접 생성
touch .env
```

### 2. 필수 값 입력

`.env` 파일을 열고 실제 값으로 변경:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-actual-supabase-anon-key

# Google OAuth Configuration
GOOGLE_WEB_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your-google-ios-client-id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=your-google-android-client-id.apps.googleusercontent.com

# Kakao OAuth Configuration (선택 사항)
KAKAO_NATIVE_APP_KEY=your-kakao-native-app-key
KAKAO_JAVASCRIPT_KEY=your-kakao-javascript-key

# App Configuration
BUNDLE_ID=com.example.runnerApp
```

### 3. 앱 실행

```bash
flutter pub get
flutter run
```

앱 시작 시 자동으로 환경 변수를 로드하고 검증합니다.

---

## 📁 파일 구조

```
project_root/
├── .env                 # 실제 키 값 (Git에 커밋하지 않음)
├── .env.example         # 템플릿 파일 (Git에 커밋)
├── .gitignore           # .env 파일 제외 설정
└── lib/
    └── config/
        ├── app_config.dart       # 환경 변수 중앙 관리
        └── supabase_config.dart  # Supabase 초기화
```

---

## 🔑 환경 변수 목록

### 필수 환경 변수

| 변수명                 | 설명                  | 예시                             |
| ---------------------- | --------------------- | -------------------------------- |
| `SUPABASE_URL`         | Supabase 프로젝트 URL | `https://xxx.supabase.co`        |
| `SUPABASE_ANON_KEY`    | Supabase Anonymous 키 | `eyJhbGciOiJIUzI1NiIs...`        |
| `GOOGLE_WEB_CLIENT_ID` | Google Web Client ID  | `xxx.apps.googleusercontent.com` |

### 선택 환경 변수

| 변수명                     | 설명                     | 기본값                          |
| -------------------------- | ------------------------ | ------------------------------- |
| `GOOGLE_IOS_CLIENT_ID`     | Google iOS Client ID     | (Info.plist에서 읽음)           |
| `GOOGLE_ANDROID_CLIENT_ID` | Google Android Client ID | (google-services.json에서 읽음) |
| `KAKAO_NATIVE_APP_KEY`     | Kakao Native App Key     | (빈 문자열)                     |
| `KAKAO_JAVASCRIPT_KEY`     | Kakao JavaScript Key     | (빈 문자열)                     |
| `BUNDLE_ID`                | 앱 Bundle Identifier     | `com.example.runnerApp`         |

---

## 💻 코드에서 사용하기

### AppConfig 클래스 사용

```dart
import 'package:stride_note/config/app_config.dart';

// Supabase 설정
final supabaseUrl = AppConfig.supabaseUrl;
final supabaseAnonKey = AppConfig.supabaseAnonKey;

// Google OAuth 설정
final googleWebClientId = AppConfig.googleWebClientId;

// Kakao OAuth 설정
final kakaoNativeAppKey = AppConfig.kakaoNativeAppKey;

// 앱 설정
final bundleId = AppConfig.bundleId;
```

### 환경 변수 검증

```dart
// main.dart에서 자동 검증
if (!AppConfig.validateConfig()) {
  debugPrint('⚠️ 환경 변수 검증 실패. .env 파일을 확인하세요.');
}
```

### 설정 정보 출력 (디버깅)

```dart
// 디버그 모드에서만 출력 (민감한 정보 마스킹됨)
if (kDebugMode) {
  AppConfig.printConfig();
}
```

---

## 🔒 보안 가이드

### 1. `.env` 파일 보호

```bash
# .gitignore에 추가 확인
grep "^\.env$" .gitignore

# 출력: .env (이미 등록됨)
```

### 2. Git 히스토리에서 제거 (실수로 커밋한 경우)

```bash
# ⚠️ 주의: 히스토리를 변경하므로 팀원과 협의 필요
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env' \
  --prune-empty --tag-name-filter cat -- --all

# 강제 푸시 (위험!)
git push origin --force --all
```

### 3. 키 순환 (Rotation)

키가 노출된 경우:

1. **즉시 키 무효화**: Supabase/Google/Kakao 콘솔에서 키 삭제
2. **새 키 발급**: 새로운 키 생성
3. **`.env` 업데이트**: 새 키로 변경
4. **앱 재배포**: 새 키가 포함된 버전 배포

---

## 🌍 환경별 설정

### 개발 환경

```env
# .env.development
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=dev-key
```

### 스테이징 환경

```env
# .env.staging
SUPABASE_URL=https://staging-project.supabase.co
SUPABASE_ANON_KEY=staging-key
```

### 프로덕션 환경

```env
# .env.production
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=prod-key
```

### 환경별 실행

```bash
# 개발 환경
flutter run --dart-define-from-file=.env.development

# 스테이징 환경
flutter run --dart-define-from-file=.env.staging

# 프로덕션 환경
flutter run --dart-define-from-file=.env.production
```

---

## 🧪 테스트 환경

테스트에서도 환경 변수를 사용할 수 있습니다:

```dart
// test/widget_test.dart
void main() {
  setUpAll(() async {
    await AppConfig.initialize();
  });

  test('should load Supabase URL from environment', () {
    expect(AppConfig.supabaseUrl, isNotEmpty);
  });
}
```

---

## 📝 CI/CD 설정

### GitHub Actions

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Create .env file
        run: |
          echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" >> .env
          echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env
          echo "GOOGLE_WEB_CLIENT_ID=${{ secrets.GOOGLE_WEB_CLIENT_ID }}" >> .env

      - name: Flutter build
        run: flutter build apk
```

### GitHub Secrets 설정

1. **GitHub 저장소** → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** 클릭
3. 각 환경 변수를 Secret으로 추가:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GOOGLE_WEB_CLIENT_ID`
   - 등등...

---

## 🔍 문제 해결

### 1. `.env` 파일을 찾을 수 없음

**증상**:

```
⚠️ .env 파일을 찾을 수 없습니다. 기본값을 사용합니다.
```

**해결**:

```bash
# 1. .env 파일이 있는지 확인
ls -la | grep .env

# 2. 없으면 생성
cp .env.example .env

# 3. 값 입력 후 앱 재시작
flutter run
```

### 2. 환경 변수 검증 실패

**증상**:

```
⚠️ 환경 변수 검증 실패:
SUPABASE_URL이 설정되지 않았습니다
```

**해결**:

```bash
# .env 파일 열기
nano .env

# 또는 VS Code에서
code .env

# 필수 값 입력 후 저장
```

### 3. 값이 로드되지 않음

**증상**:
환경 변수가 항상 기본값으로 로드됨

**해결**:

```bash
# 1. Hot Restart (권장하지 않음, Full Restart 필요)
# 앱 완전 종료 후 재시작

# 2. 캐시 삭제
flutter clean
flutter pub get
flutter run

# 3. .env 파일 인코딩 확인 (UTF-8이어야 함)
file -I .env
```

---

## ✅ 체크리스트

- [ ] `.env.example` 파일 존재 확인
- [ ] `.env` 파일 생성 및 값 입력
- [ ] `.gitignore`에 `.env` 등록 확인
- [ ] 필수 환경 변수 모두 입력
- [ ] `flutter pub get` 실행
- [ ] 앱 실행 시 환경 변수 로드 확인
- [ ] 디버그 로그에서 설정 정보 확인
- [ ] GitHub Secrets 설정 (CI/CD 사용 시)

---

## 📚 관련 문서

- `README.md` - 프로젝트 개요
- `DATABASE_SETUP.md` - 데이터베이스 설정
- `GOOGLE_NATIVE_LOGIN_COMPLETE.md` - Google 로그인 설정
- `NONCE_FINAL_FIX.md` - Nonce 문제 해결

---

## 🎉 완료!

이제 모든 민감한 키가 안전하게 환경 변수로 관리됩니다!

코드에 하드코딩된 키가 없으므로:

- ✅ **Git에 안전하게 커밋** 가능
- ✅ **팀원과 협업** 용이
- ✅ **환경별 분리** 관리 가능
- ✅ **보안 강화** 완료

---

**다음 단계**: Kakao 로그인 연동 또는 다른 OAuth 제공자 추가! 🚀
