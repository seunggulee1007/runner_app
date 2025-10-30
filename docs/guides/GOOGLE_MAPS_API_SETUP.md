# Google Maps API 키 설정 가이드

## 🗺️ 개요

StrideNote 앱에서 실시간 지도 기능을 사용하려면 Google Maps API 키가 필요합니다. 현재 앱이 크래시되는 이유는 API 키가 설정되지 않았기 때문입니다.

## 📋 설정 단계

### 1. Google Cloud Console에서 API 키 생성

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. **API 및 서비스** > **라이브러리**로 이동
4. 다음 API들을 활성화:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Maps JavaScript API** (웹용, 선택사항)

5. **API 및 서비스** > **사용자 인증 정보**로 이동
6. **사용자 인증 정보 만들기** > **API 키** 선택
7. 생성된 API 키를 복사

### 2. iOS 설정 (Info.plist)

`ios/Runner/Info.plist` 파일에서 다음 부분을 수정:

```xml
<!-- Google Maps API Key -->
<key>GMSApiKey</key>
<string>YOUR_ACTUAL_GOOGLE_MAPS_API_KEY_HERE</string>
```

**현재 상태:**
```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

### 3. Android 설정 (AndroidManifest.xml)

`android/app/src/main/AndroidManifest.xml` 파일에서 다음 부분을 수정:

```xml
<!-- Google Maps API 키 -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_GOOGLE_MAPS_API_KEY_HERE" />
```

**현재 상태:**
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

## 🔒 보안 설정

### API 키 제한 설정

1. Google Cloud Console에서 생성한 API 키 클릭
2. **애플리케이션 제한사항** 설정:
   - **Android 앱**: 패키지 이름 `com.example.runnerApp` 추가
   - **iOS 앱**: 번들 ID `com.example.runnerApp` 추가

3. **API 제한사항** 설정:
   - **키 제한** 선택
   - 다음 API들만 선택:
     - Maps SDK for Android
     - Maps SDK for iOS

## 🚀 테스트

API 키 설정 후:

1. 앱을 완전히 종료
2. 다시 실행
3. 러닝 화면에서 지도 아이콘(🗺️) 클릭
4. 실제 Google Maps가 표시되는지 확인

## 🛠️ 문제 해결

### 크래시가 계속 발생하는 경우

1. **API 키 확인**: 올바른 API 키가 설정되었는지 확인
2. **API 활성화**: 필요한 API들이 활성화되었는지 확인
3. **제한 설정**: API 키 제한 설정이 올바른지 확인
4. **캐시 클리어**: 앱 캐시를 삭제하고 다시 실행

### 지도가 표시되지 않는 경우

1. **네트워크 연결** 확인
2. **API 할당량** 확인 (Google Cloud Console)
3. **결제 정보** 설정 (Google Cloud Console)

## 💡 현재 상태

현재 앱은 API 키가 없어도 크래시되지 않도록 수정되었습니다. 지도 대신 GPS 경로 정보를 표시하는 플레이스홀더 UI가 나타납니다.

API 키를 설정하면 실제 Google Maps가 표시되어 실시간 경로를 시각적으로 확인할 수 있습니다.

## 📞 지원

문제가 지속되면 다음을 확인해주세요:

1. Google Cloud Console에서 API 키 상태
2. 앱 로그에서 오류 메시지
3. 네트워크 연결 상태
