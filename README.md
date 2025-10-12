# 🏃‍♀️ StrideNote - 러닝 트래커 앱

StrideNote는 사용자가 달리기를 할 때 거리, 속도, 심박수, 러닝 패턴을 자동 기록하고, 개인의 성장과 피드백을 직관적으로 보여주는 앱입니다. 단순한 기록이 아닌 "러닝 스토리"를 만들어주는 개인 맞춤형 트래커입니다.

## ✨ 주요 기능

### 🎯 코어 기능

- **러닝 자동 기록**: GPS 기반 거리, 페이스, 시간, 고도 추적
- **심박수 연동**: 웨어러블 기기 연동 (HealthKit, Google Fit)
- **훈련 요약 리포트**: 달리기 후 자동 생성
- **러닝 히스토리**: 주/월간 통계 시각화 + 배지 시스템

### 🚀 부가 기능

- 러닝 플랜 추천
- 소셜 공유 기능
- 음악 연동
- AI 기반 개인화된 피드백

## 🎨 디자인 특징

- **블루 톤 기반의 역동적 컬러**: 신뢰감과 에너지를 주는 컬러 팔레트
- **한 손 조작 중심의 직관적 UI**: 러닝 중에도 쉽게 사용할 수 있는 인터페이스
- **즉각적 피드백 UX**: 실시간 데이터 표시와 음성 알림

## 🛠 기술 스택

### 프론트엔드

- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Provider**: 상태 관리
- **FL Chart**: 데이터 시각화
- **Lottie**: 애니메이션

### 백엔드 & 데이터

- **SQLite**: 로컬 데이터 저장
- **SharedPreferences**: 설정 데이터 저장
- **Geolocator**: GPS 위치 추적
- **Health**: 건강 앱 연동

### 외부 서비스

- **HealthKit** (iOS): 심박수 및 건강 데이터
- **Google Fit** (Android): 건강 데이터 연동
- **Spotify**: 음악 연동 (예정)
- **Kakao Share**: 소셜 공유 (예정)

## 🔄 개발 방법론

### TDD (Test-Driven Development)

이 프로젝트는 **엄격한 TDD 원칙**을 따릅니다:

- ✅ **Red → Green → Refactor** 사이클 준수
- ✅ **전체 테스트 실행** 의무화 (사이드 이펙트 체크)
- ✅ **테스트 커버리지 90%** 목표 (핵심 로직)

#### 📚 관련 문서

- [TDD 개발 가이드](TDD_GUIDE.md) - 전체 TDD 프로세스 상세 설명
- [Cursor Rules - TDD](.cursor/rules/tdd-development.mdc) - AI 페어 프로그래밍 규칙

#### 🛠️ 테스트 실행

```bash
# 전체 테스트 실행
flutter test

# 또는 헬퍼 스크립트 사용
bash scripts/run_all_tests.sh

# 커버리지 포함
bash scripts/run_tests_with_coverage.sh

# TDD 사이클 헬퍼
bash scripts/tdd_cycle.sh red      # Red 단계
bash scripts/tdd_cycle.sh green    # Green 단계
bash scripts/tdd_cycle.sh refactor # Refactor 단계
```

## 📱 지원 플랫폼

- **iOS**: 12.0 이상
- **Android**: API 26 (Android 8.0) 이상

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK 3.8.1 이상
- Dart SDK 3.0.0 이상
- Android Studio 또는 Xcode
- Git
- Supabase 계정 (인증 기능 사용 시)
- Google Cloud Console 계정 (Google 로그인 사용 시)

### ⚠️ Google 로그인 설정

Google 로그인 기능을 사용하려면 먼저 다음 설정이 필요합니다:

1. **🔐 환경 변수 설정**: `ENV_CONFIG_GUIDE.md` 파일 참조 ⭐⭐⭐ **먼저 읽기!**
2. **🔒 보안 감사 완료**: `SECURITY_AUDIT_COMPLETE.md` 파일 참조 ⭐⭐
3. **🟡 카카오 로그인 설정**: `KAKAO_LOGIN_SETUP.md` 파일 참조 ⭐⭐⭐ **NEW!**
4. **🎯 완전 가이드**: `GOOGLE_NATIVE_LOGIN_COMPLETE.md` 파일 참조 ⭐
5. **🔧 Nonce 최종 해결**: `NONCE_FINAL_FIX.md` 파일 참조 ⭐⭐
6. **🛠️ 프로필 오류 해결**: `PROFILE_NULL_FIX.md` 파일 참조
7. **🔤 Snake Case 매핑**: `SNAKE_CASE_FIX.md` 파일 참조 ⭐⭐⭐
8. **데이터베이스 설정**: `DATABASE_SETUP.md` 파일 참조

#### 플랫폼별 로그인 방식

- **모든 플랫폼 (iOS/Android/Web)**: 네이티브 Google Sign-In
  - ✅ 브라우저 열리지 않음
  - ✅ 딥링크 불필요
  - ✅ 자동 세션 유지
  - ✅ 자동 프로필 생성/업데이트

> 💡 Google 로그인 없이 이메일 로그인만 사용할 경우, Supabase 설정만 완료하면 됩니다.

### 설치 및 실행

1. **저장소 클론**

   ```bash
   git clone https://github.com/your-username/stride-note.git
   cd stride-note
   ```

2. **의존성 설치**

   ```bash
   flutter pub get
   ```

3. **JSON 직렬화 코드 생성**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **앱 실행**
   ```bash
   flutter run
   ```

### 빌드

**Android APK 빌드**

```bash
flutter build apk --release
```

**iOS 빌드**

```bash
flutter build ios --release
```

## 📁 프로젝트 구조

```
lib/
├── constants/          # 앱 상수 및 테마
│   ├── app_colors.dart
│   └── app_theme.dart
├── models/             # 데이터 모델
│   ├── running_session.dart
│   └── user_profile.dart
├── services/           # 비즈니스 로직
│   ├── location_service.dart
│   └── database_service.dart
├── screens/            # 화면 위젯
│   ├── home_screen.dart
│   ├── running_screen.dart
│   ├── history_screen.dart
│   └── profile_screen.dart
├── widgets/            # 재사용 가능한 위젯
│   ├── running_card.dart
│   ├── running_timer.dart
│   ├── running_stats.dart
│   ├── running_controls.dart
│   ├── stats_summary.dart
│   └── quick_actions.dart
├── utils/              # 유틸리티 함수
└── main.dart           # 앱 진입점
```

## 🎯 사용자 여정

1. **앱 실행** → "오늘의 러닝 시작하기"
2. **"러닝 시작" 클릭** → GPS 연결 + 카운트다운
3. **달리기 중** → 실시간 데이터 표시 + 음성 알림
4. **종료** → 자동 저장 + 리포트 생성
5. **분석 보기** → 통계 대시보드 이동
6. **목표 설정** → AI 플랜 생성

## 📊 성공 지표 (KPI)

- **DAU**: 10,000명
- **세션 평균**: 25분 이상
- **목표 달성률**: 60% 이상
- **리텐션(30일)**: 40% 이상
- **앱 평점**: 4.5점 이상

## 🗓 로드맵

### Phase 1 (MVP, 0~3개월)

- ✅ 기본 기록 + 리포트
- ✅ GPS 기반 거리 추적
- ✅ 러닝 히스토리
- ✅ 통계 시각화

### Phase 2 (3~6개월)

- 🔄 AI 플랜 + 배지 시스템
- 🔄 웨어러블 연동
- 🔄 음성 안내

### Phase 3 (6~12개월)

- 📋 커뮤니티 + 챌린지
- 📋 음악 연동
- 📋 소셜 공유

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 연락처

- **개발팀**: StrideNote Team
- **이메일**: support@stridenote.com
- **웹사이트**: https://stridenote.com

## 🙏 감사의 말

이 프로젝트는 다음 오픈소스 프로젝트들의 도움을 받았습니다:

- [Flutter](https://flutter.dev/)
- [FL Chart](https://github.com/imaNNeoFighT/fl_chart)
- [Geolocator](https://github.com/Baseflow/flutter-geolocator)
- [Provider](https://github.com/rrousselGit/provider)

---

**StrideNote와 함께 건강한 러닝을 시작하세요! 🏃‍♀️💪**
