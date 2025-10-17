# Google Maps API 키 설정 가이드

## 🗺️ 지도 기능 활성화하기

현재 앱에는 지도 기능이 구현되어 있지만, Google Maps API 키가 설정되지 않아 대체 UI가 표시됩니다. 실제 지도를 사용하려면 다음 단계를 따라 API 키를 설정하세요.

## 📋 설정 단계

### 1. Google Cloud Console에서 프로젝트 생성

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. 프로젝트 이름: `StrideNote` (또는 원하는 이름)

### 2. Maps SDK for iOS 활성화

1. Google Cloud Console에서 **API 및 서비스 > 라이브러리**로 이동
2. "Maps SDK for iOS" 검색
3. **사용 설정** 클릭

### 3. API 키 생성

1. **API 및 서비스 > 사용자 인증 정보**로 이동
2. **사용자 인증 정보 만들기 > API 키** 클릭
3. 생성된 API 키 복사

### 4. API 키 제한 설정 (보안)

1. 생성된 API 키 옆의 **편집** 아이콘 클릭
2. **애플리케이션 제한사항**에서 **iOS 앱** 선택
3. **번들 ID**에 `com.example.runnerApp` 입력
4. **API 제한사항**에서 **키 제한** 선택
5. **Maps SDK for iOS** 선택

### 5. iOS 앱에 API 키 추가

`ios/Runner/Info.plist` 파일에서 다음 부분을 수정:

```xml
<!-- Google Maps API Key -->
<key>GMSApiKey</key>
<string>YOUR_ACTUAL_API_KEY_HERE</string>
```

`YOUR_ACTUAL_API_KEY_HERE`를 실제 API 키로 교체하세요.

## 🔧 추가 설정 (선택사항)

### Android 지원 (향후)

Android에서도 지도를 사용하려면:

1. **Maps SDK for Android** 활성화
2. `android/app/src/main/AndroidManifest.xml`에 API 키 추가:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 지도 스타일 커스터마이징

현재 앱에는 다크 테마 지도 스타일이 적용되어 있습니다. `lib/widgets/running_map.dart`의 `_getMapStyle()` 메서드에서 스타일을 수정할 수 있습니다.

## 🚀 테스트

API 키 설정 후:

1. 앱을 다시 빌드: `flutter clean && flutter pub get`
2. iOS 시뮬레이터/디바이스에서 실행
3. 러닝 화면에서 지도 버튼(🗺️) 탭
4. 실제 Google Maps가 표시되는지 확인

## ⚠️ 주의사항

- API 키는 절대 공개 저장소에 커밋하지 마세요
- 프로덕션 환경에서는 API 키 제한을 반드시 설정하세요
- API 사용량 모니터링을 설정하여 예상치 못한 비용을 방지하세요

## 🆘 문제 해결

### 지도가 표시되지 않는 경우

1. API 키가 올바르게 설정되었는지 확인
2. 번들 ID가 API 키 제한과 일치하는지 확인
3. Maps SDK for iOS가 활성화되었는지 확인
4. Xcode에서 빌드 에러가 없는지 확인

### 빌드 에러가 발생하는 경우

1. `flutter clean` 실행
2. `cd ios && pod install` 실행
3. Xcode에서 프로젝트 클린 빌드

## 📱 현재 상태

- ✅ 지도 UI 구현 완료
- ✅ 화면 전환 기능 구현 완료
- ✅ GPS 경로 추적 기능 구현 완료
- ⏳ Google Maps API 키 설정 필요
- ⏳ 실제 지도 렌더링 테스트 필요

API 키를 설정하면 완전한 지도 기능을 사용할 수 있습니다!
