# 🚀 빌드 & 배포 가이드

> **프로덕션 환경 배포를 위한 완벽한 가이드**

---

## 목차

- [사전 준비](#사전-준비)
- [Android APK 빌드](#android-apk-빌드)
- [iOS IPA 빌드](#ios-ipa-빌드)
- [Google Play Store 배포](#google-play-store-배포)
- [App Store 배포](#app-store-배포)
- [웹 배포](#웹-배포)
- [문제 해결](#문제-해결)

---

## 사전 준비

### 1. 버전 정보 업데이트

`pubspec.yaml` 파일에서 버전 정보를 업데이트하세요:

```yaml
version: 1.0.0+1
#        ↑     ↑
#     버전명  빌드번호
```

- **버전명**: 사용자에게 표시되는 버전 (예: 1.0.0)
- **빌드번호**: 스토어에서 관리하는 고유 번호 (앱 업데이트 시 반드시 증가)

### 2. 환경 변수 확인

프로덕션용 `.env` 파일이 올바르게 설정되어 있는지 확인:

```env
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
GOOGLE_MAPS_API_KEY=your-production-api-key
```

⚠️ **보안 주의**: `.env` 파일은 절대 Git에 커밋하지 마세요!

### 3. 테스트 실행

배포 전 모든 테스트가 통과하는지 확인:

```bash
flutter test
flutter test --coverage
```

---

## Android APK 빌드

### 1. 키스토어 생성 (최초 1회만)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

**입력 정보**:
- 비밀번호: 안전하게 보관하세요!
- 이름, 조직 등: 실제 정보 입력

### 2. key.properties 파일 생성

`android/key.properties` 파일 생성 (Git에 커밋하지 마세요!):

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/Users/yourusername/upload-keystore.jks
```

### 3. build.gradle 설정

`android/app/build.gradle` 파일에서 다음을 확인:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 4. Release APK 빌드

```bash
# APK 빌드
flutter build apk --release

# 빌드된 APK 위치
# build/app/outputs/flutter-apk/app-release.apk

# APK 크기 확인
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### 5. App Bundle 빌드 (Play Store 권장)

```bash
# AAB 빌드
flutter build appbundle --release

# 빌드된 AAB 위치
# build/app/outputs/bundle/release/app-release.aab
```

**App Bundle vs APK**:
- **App Bundle (AAB)**: Play Store 권장, 동적 전달로 APK 크기 최적화
- **APK**: 직접 배포 가능, 사이드로딩

### 6. APK 테스트

```bash
# 디바이스에 설치
adb install build/app/outputs/flutter-apk/app-release.apk

# 앱 실행
adb shell am start -n com.example.stride_note/.MainActivity
```

---

## iOS IPA 빌드

### 사전 요구사항

- **macOS** 운영체제
- **Xcode** 최신 버전
- **Apple Developer 계정** (연간 $99)

### 1. Apple Developer 설정

1. [Apple Developer](https://developer.apple.com) 로그인
2. **Certificates, Identifiers & Profiles** 메뉴
3. **App ID** 생성:
   - Bundle ID: `com.example.stride_note`
   - 권한: HealthKit, Location Services 등 활성화

### 2. Xcode 프로젝트 설정

```bash
open ios/Runner.xcworkspace
```

**Xcode에서 설정**:
1. **Signing & Capabilities** 탭
2. **Team** 선택 (Apple Developer 계정)
3. **Bundle Identifier** 확인
4. **Capabilities** 추가:
   - HealthKit
   - Background Modes (Location updates)

### 3. Info.plist 확인

`ios/Runner/Info.plist` 파일 확인:

```xml
<!-- 위치 권한 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>러닝 중 실시간 위치를 추적하여 거리와 경로를 기록합니다.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>백그라운드에서도 러닝을 추적하여 정확한 기록을 제공합니다.</string>

<!-- HealthKit 권한 -->
<key>NSHealthShareUsageDescription</key>
<string>러닝 중 심박수를 실시간으로 모니터링하여 더 효과적인 운동을 돕습니다.</string>

<!-- URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

### 4. Release 빌드

```bash
# iOS 빌드
flutter build ios --release

# Xcode에서 Archive 생성
# 1. Xcode에서 Product > Archive 선택
# 2. Archive가 완료되면 Organizer 창 열림
# 3. "Distribute App" 버튼 클릭
```

### 5. TestFlight 배포

**Xcode Organizer에서**:
1. **App Store Connect** 선택
2. **Upload** 클릭
3. 자동 서명 설정
4. 업로드 완료 대기 (5-10분)

**App Store Connect에서**:
1. [App Store Connect](https://appstoreconnect.apple.com) 로그인
2. **My Apps** > **StrideNote** 선택
3. **TestFlight** 탭
4. **Internal Testing** 또는 **External Testing** 설정
5. 테스터 초대

---

## Google Play Store 배포

### 1. Play Console 설정

1. [Google Play Console](https://play.google.com/console) 로그인
2. **모든 앱** > **앱 만들기**
3. 앱 정보 입력:
   - **앱 이름**: StrideNote
   - **기본 언어**: 한국어
   - **앱 또는 게임**: 앱
   - **무료 또는 유료**: 무료

### 2. 앱 세부정보 설정

**스토어 등록정보**:
- 짧은 설명 (80자)
- 자세한 설명 (4000자)
- 스크린샷 (최소 2개, 권장 8개)
- 아이콘 (512x512)
- 배너 이미지 (1024x500)

**콘텐츠 등급**:
- 설문지 작성
- 모든 연령 적합성 확인

**개인정보처리방침**:
- URL 입력 (필수)

### 3. 프로덕션 릴리스 생성

1. **프로덕션** > **새 릴리스 만들기**
2. **App Bundle 업로드**:
   ```bash
   build/app/outputs/bundle/release/app-release.aab
   ```
3. **출시 노트** 작성:
   ```
   버전 1.0.0

   주요 기능:
   - 실시간 GPS 러닝 추적
   - Google 소셜 로그인
   - HealthKit/Google Fit 연동
   - 러닝 통계 시각화
   ```

### 4. 검토 제출

1. 모든 필수 항목 완료
2. **검토용으로 제출** 버튼 클릭
3. 검토 대기 (보통 1-3일)

### 5. 점진적 출시 (권장)

- **내부 테스트** (최대 100명)
- **비공개 테스트** (오픈 또는 폐쇄형)
- **프로덕션** (점진적 출시: 5% → 20% → 50% → 100%)

---

## App Store 배포

### 1. App Store Connect 설정

1. [App Store Connect](https://appstoreconnect.apple.com) 로그인
2. **My Apps** > **+** > **New App**
3. 앱 정보 입력:
   - **플랫폼**: iOS
   - **이름**: StrideNote
   - **기본 언어**: 한국어
   - **Bundle ID**: com.example.stride_note
   - **SKU**: stride-note-ios

### 2. 앱 정보 입력

**App Information**:
- 이름 (30자)
- 부제목 (30자)
- 카테고리: 건강 및 피트니스

**Pricing and Availability**:
- 가격: 무료
- 지역: 한국 또는 전 세계

**App Privacy**:
- 개인정보 처리 방침 URL
- 수집하는 데이터 유형 명시

### 3. 버전 정보 입력

**Version Information**:
- 스크린샷 (5.5", 6.5" 필수)
- 홍보 텍스트 (170자)
- 설명 (4000자)
- 키워드 (100자)
- 지원 URL
- 마케팅 URL (선택)

**App Review Information**:
- 연락처 정보
- 데모 계정 (필요 시)
- 검토 노트

### 4. TestFlight 테스트 (권장)

1. Xcode에서 Archive 업로드
2. App Store Connect에서 빌드 확인
3. **Internal Testing** 테스터 초대
4. **External Testing** 설정 (최대 10,000명)
5. 피드백 수집 및 버그 수정

### 5. 심사 제출

1. 모든 필수 항목 완료
2. **심사용으로 제출** 버튼 클릭
3. 심사 대기 (보통 24-48시간)
4. 승인 후 **수동 출시** 또는 **자동 출시** 선택

---

## 웹 배포

### 1. 웹 빌드

```bash
flutter build web --release

# 빌드된 파일 위치
# build/web/
```

### 2. Firebase Hosting 배포

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 초기화
firebase init hosting

# 배포
firebase deploy --only hosting
```

**firebase.json** 설정:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 3. Vercel 배포

```bash
# Vercel CLI 설치
npm i -g vercel

# 배포
vercel --prod

# 빌드 설정
# Framework Preset: None
# Build Command: flutter build web
# Output Directory: build/web
```

---

## 문제 해결

### Android 빌드 오류

#### 문제 1: Gradle 버전 오류

```bash
# android/gradle/wrapper/gradle-wrapper.properties 확인
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

#### 문제 2: Java 버전 오류

```bash
# Java 17 설치 및 설정
# macOS
brew install openjdk@17

# 환경 변수 설정
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
```

#### 문제 3: MultiDex 오류

`android/app/build.gradle`에 추가:
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### iOS 빌드 오류

#### 문제 1: Pods 설치 실패

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

#### 문제 2: Signing 오류

1. Xcode에서 **Automatically manage signing** 체크
2. **Team** 선택
3. **Bundle Identifier** 고유하게 변경

#### 문제 3: Capability 오류

Xcode에서 **Signing & Capabilities** 탭:
- **+ Capability** 버튼
- 필요한 권한 추가 (HealthKit, Background Modes 등)

---

## 체크리스트

### 배포 전 체크리스트

- [ ] 버전 정보 업데이트 (`pubspec.yaml`)
- [ ] 환경 변수 프로덕션 설정 확인 (`.env`)
- [ ] 모든 테스트 통과 확인 (`flutter test`)
- [ ] 앱 아이콘 설정 완료
- [ ] 스플래시 화면 설정 완료
- [ ] 개인정보처리방침 URL 준비
- [ ] 스크린샷 촬영 완료 (각 플랫폼)
- [ ] 앱 설명 작성 완료
- [ ] 릴리스 노트 작성 완료

### Android 체크리스트

- [ ] 키스토어 파일 안전하게 보관
- [ ] `key.properties` 파일 설정
- [ ] `build.gradle` 서명 설정 확인
- [ ] ProGuard 규칙 설정 (난독화)
- [ ] Play Console 계정 준비
- [ ] 앱 콘텐츠 등급 완료

### iOS 체크리스트

- [ ] Apple Developer 계정 준비
- [ ] Xcode 서명 설정 완료
- [ ] `Info.plist` 권한 설명 작성
- [ ] App Store Connect 앱 생성
- [ ] TestFlight 내부 테스트 완료
- [ ] 앱 심사 가이드라인 확인

---

## 유용한 명령어

```bash
# 빌드 크기 분석
flutter build apk --analyze-size
flutter build appbundle --analyze-size

# 빌드 로그 확인
flutter build apk --verbose
flutter build ios --verbose

# 프로파일링
flutter run --profile
flutter build apk --profile

# 디바이스 목록
flutter devices

# 앱 서명 확인 (Android)
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

---

## 참고 자료

- [Flutter 공식 배포 가이드](https://docs.flutter.dev/deployment)
- [Google Play Console 도움말](https://support.google.com/googleplay/android-developer/)
- [App Store Connect 도움말](https://help.apple.com/app-store-connect/)
- [Firebase Hosting 문서](https://firebase.google.com/docs/hosting)

---

<div align="center">

### 🎉 배포 성공을 기원합니다!

문제가 발생하면 [GitHub Issues](https://github.com/yourusername/stride-note/issues)에 등록해주세요.

</div>

