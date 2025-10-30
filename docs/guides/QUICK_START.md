# ⚡ Quick Start Guide

> **시간이 없으신 분들을 위한 5분 설치 가이드**

---

## 🚀 빠른 실행 (5분)

### 1️⃣ 사전 요구사항 확인

```bash
# Flutter SDK 설치 확인
flutter --version  # 3.8.1 이상 필요

# Dart SDK 확인
dart --version  # 3.0 이상 필요
```

### 2️⃣ 프로젝트 클론

```bash
git clone https://github.com/yourusername/stride-note.git
cd stride-note
```

### 3️⃣ 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가하세요:

```env
# Supabase (필수)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Google OAuth (소셜 로그인용)
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your-ios-client-id.apps.googleusercontent.com

# Google Maps (지도 기능용)
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

**🔑 API 키 발급 방법**:
- Supabase: [supabase.com](https://supabase.com) → 새 프로젝트 생성
- Google Maps: [Google Cloud Console](https://console.cloud.google.com) → Maps SDK 활성화
- Google OAuth: [Google Cloud Console](https://console.cloud.google.com) → OAuth 2.0 클라이언트 ID 생성

### 4️⃣ 의존성 설치

```bash
# 패키지 설치
flutter pub get

# JSON 직렬화 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5️⃣ 앱 실행

```bash
# 디버그 모드 실행 (핫 리로드 지원)
flutter run

# 특정 디바이스에서 실행
flutter devices  # 사용 가능한 디바이스 목록 확인
flutter run -d <device-id>
```

---

## 📱 플랫폼별 추가 설정

### iOS 설정 (macOS 필요)

```bash
# CocoaPods 설치
sudo gem install cocoapods

# Pods 설치
cd ios
pod install
cd ..
```

**Info.plist 설정** (`ios/Runner/Info.plist`):
```xml
<!-- Google Client ID -->
<key>GIDClientID</key>
<string>YOUR-IOS-CLIENT-ID.apps.googleusercontent.com</string>

<!-- 위치 권한 설명 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>러닝 중 실시간 위치를 추적하여 거리와 경로를 기록합니다.</string>

<!-- HealthKit 권한 설명 -->
<key>NSHealthShareUsageDescription</key>
<string>러닝 중 심박수를 실시간으로 모니터링합니다.</string>
```

### Android 설정

**AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`):
```xml
<!-- 위치 권한 -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- 인터넷 권한 -->
<uses-permission android:name="android.permission.INTERNET"/>
```

**google-services.json** (Firebase 사용 시):
- [Firebase Console](https://console.firebase.google.com)에서 프로젝트 생성
- `android/app/` 디렉토리에 `google-services.json` 다운로드

---

## 🧪 테스트 실행

```bash
# 모든 테스트 실행
flutter test

# 커버리지 포함
flutter test --coverage

# 특정 테스트만 실행
flutter test test/unit/services/auth_service_test.dart
```

---

## 🏗️ 빌드

```bash
# Android APK (Release)
flutter build apk --release

# iOS (Release) - macOS만 가능
flutter build ios --release

# 웹 (Release)
flutter build web --release
```

---

## ❓ 문제 해결

### 문제 1: `flutter pub get` 실패

```bash
# 캐시 정리 후 재시도
flutter clean
flutter pub get
```

### 문제 2: iOS 빌드 실패

```bash
# Pods 재설치
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### 문제 3: Android 빌드 실패

```bash
# Gradle 캐시 정리
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### 문제 4: Google 로그인 실패

- `.env` 파일의 `GOOGLE_WEB_CLIENT_ID`와 `GOOGLE_IOS_CLIENT_ID` 확인
- Google Cloud Console에서 OAuth 2.0 클라이언트 ID 재확인
- [GOOGLE_SIGNIN_NATIVE.md](GOOGLE_SIGNIN_NATIVE.md) 참조

---

## 📚 추가 문서

| 문서 | 내용 |
|------|------|
| [README.md](README.md) | 전체 프로젝트 설명 |
| [ENV_CONFIG_GUIDE.md](ENV_CONFIG_GUIDE.md) | 환경 변수 상세 설정 |
| [DATABASE_SETUP.md](DATABASE_SETUP.md) | Supabase 데이터베이스 설정 |
| [GOOGLE_MAPS_API_SETUP.md](GOOGLE_MAPS_API_SETUP.md) | Google Maps API 설정 |

---

## 💡 유용한 명령어

```bash
# Flutter 버전 업그레이드
flutter upgrade

# 패키지 업데이트
flutter pub upgrade

# 디바이스 목록 확인
flutter devices

# 앱 프로파일링
flutter run --profile

# 빌드 크기 분석
flutter build apk --analyze-size
```

---

## 📞 도움이 필요하신가요?

- **이슈 등록**: [GitHub Issues](https://github.com/yourusername/stride-note/issues)
- **이메일**: your.email@example.com
- **Discord**: [Join our community](#)

---

<div align="center">

### 🎉 설치 완료!

이제 **StrideNote**를 실행해보세요!

```bash
flutter run
```

</div>

