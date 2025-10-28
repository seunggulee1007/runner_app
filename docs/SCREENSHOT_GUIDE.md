# 📸 스크린샷 촬영 가이드

## 목차

- [준비사항](#준비사항)
- [iOS 스크린샷 촬영](#ios-스크린샷-촬영)
- [Android 스크린샷 촬영](#android-스크린샷-촬영)
- [데모 영상 제작](#데모-영상-제작)
- [이미지 최적화](#이미지-최적화)
- [GitHub에 업로드](#github에-업로드)

---

## 준비사항

### 1. 촬영할 화면 목록

```
필수 화면 (10개):
├─ 01_login_screen.png - 로그인 화면
├─ 02_signup_screen.png - 회원가입 화면
├─ 03_home_screen.png - 홈 대시보드
├─ 04_stats_summary.png - 통계 요약
├─ 05_running_screen.png - 러닝 추적 (지도)
├─ 06_running_stats.png - 러닝 통계
├─ 07_history_screen.png - 히스토리 목록
├─ 08_detail_screen.png - 상세 통계
├─ 09_profile_screen.png - 프로필
└─ 10_settings_screen.png - 설정

추가 화면 (선택사항):
├─ 11_splash_screen.png - 스플래시
├─ 12_onboarding_screen.png - 온보딩
└─ 13_google_login.png - Google 로그인
```

### 2. 테스트 데이터 준비

```dart
// 더미 데이터 생성
void generateTestData() async {
  final sessions = [
    RunningSession(
      id: '1',
      startTime: DateTime.now().subtract(Duration(days: 1)),
      endTime: DateTime.now().subtract(Duration(days: 1, hours: -1)),
      totalDistance: 5200,  // 5.2km
      totalDuration: 1725,  // 28:45
      averagePace: 5.53,
      maxSpeed: 12.5,
      averageHeartRate: 145,
      maxHeartRate: 165,
      caloriesBurned: 320,
    ),
    // ... 더 많은 세션
  ];

  for (var session in sessions) {
    await DatabaseService().saveRunningSession(session);
  }
}
```

---

## iOS 스크린샷 촬영

### 방법 1: 시뮬레이터 (추천)

#### 1. 시뮬레이터 실행

```bash
# 앱 실행
flutter run -d "iPhone 15 Pro"

# 또는 특정 디바이스 지정
flutter run -d <device-id>
```

#### 2. 스크린샷 촬영

**방법 A: 키보드 단축키**

```
⌘ + S  # 스크린샷 저장
```

- 저장 위치: `~/Desktop/Simulator Screen Shot...png`

**방법 B: 명령어**

```bash
# 시뮬레이터의 스크린샷 저장
xcrun simctl io booted screenshot ~/Desktop/screenshot.png

# 특정 디바이스
xcrun simctl io <device-id> screenshot screenshot.png
```

**방법 C: 시뮬레이터 메뉴**

```
File → New Screen Shot (⌘S)
```

#### 3. 디바이스 프레임 추가 (선택사항)

```bash
# 1. Screenshot 앱 설치
brew install screenshot

# 2. 프레임 추가
screenshot frame screenshot.png --output framed.png
```

또는 온라인 도구:

- **Mockuphone**: https://mockuphone.com
- **Smartmockups**: https://smartmockups.com

---

### 방법 2: 실제 디바이스

#### 1. 디바이스 연결

```bash
# 디바이스 확인
flutter devices

# 디바이스에 앱 실행
flutter run -d <device-id>
```

#### 2. 스크린샷 촬영

**iPhone/iPad**:

```
음량 Up + 전원 버튼 동시 클릭
```

**Mac으로 가져오기**:

1. USB로 연결
2. QuickTime Player 실행
3. `File → New Movie Recording`
4. 카메라 선택: iPhone
5. 화면 캡처: `⌘ + Ctrl + N`

---

### iOS 스크린샷 권장 해상도

```
iPhone 15 Pro Max: 1290 x 2796
iPhone 15 Pro: 1179 x 2556
iPhone 14: 1170 x 2532
iPhone SE: 750 x 1334

포트폴리오용 권장:
├─ 해상도: 1170 x 2532 (iPhone 14/15)
├─ 포맷: PNG (품질 100%)
└─ 파일명: 01_screen_name.png
```

---

## Android 스크린샷 촬영

### 방법 1: 에뮬레이터 (추천)

#### 1. 에뮬레이터 실행

```bash
# AVD Manager로 에뮬레이터 생성
# Android Studio → Tools → AVD Manager

# 앱 실행
flutter run -d emulator-5554

# 또는
flutter run -d "Pixel 7 Pro API 34"
```

#### 2. 스크린샷 촬영

**방법 A: 키보드 단축키**

```
Ctrl + S (Windows/Linux)
⌘ + S (Mac)
```

**방법 B: ADB 명령어**

```bash
# 스크린샷 촬영 후 파일로 저장
adb shell screencap -p /sdcard/screenshot.png

# Mac/PC로 가져오기
adb pull /sdcard/screenshot.png ~/Desktop/

# 삭제
adb shell rm /sdcard/screenshot.png

# 원라인 명령어
adb shell screencap -p | sed 's/\r$//' > screenshot.png
```

**방법 C: 에뮬레이터 버튼**

```
에뮬레이터 사이드 패널 → Camera 아이콘 클릭
```

---

### 방법 2: 실제 디바이스

#### 1. 디바이스 연결

```bash
# USB 디버깅 활성화
# Settings → Developer Options → USB Debugging

# 디바이스 확인
adb devices

# 앱 실행
flutter run -d <device-id>
```

#### 2. 스크린샷 촬영

**대부분의 Android 기기**:

```
전원 버튼 + 음량 Down 동시 클릭
```

**Samsung**:

```
전원 버튼 + 음량 Down
또는
전원 버튼 + Home 버튼 (구형)
```

**Mac/PC로 가져오기**:

```bash
# ADB로 가져오기
adb pull /sdcard/DCIM/Screenshots/ ~/Desktop/
```

---

### Android 스크린샷 권장 해상도

```
Pixel 7 Pro: 1440 x 3120
Pixel 7: 1080 x 2400
Galaxy S23 Ultra: 1440 x 3088

포트폴리오용 권장:
├─ 해상도: 1080 x 2400 (Pixel 7)
├─ 포맷: PNG (품질 100%)
└─ 파일명: 01_screen_name.png
```

---

## 데모 영상 제작

### 방법 1: iOS 시뮬레이터

#### 1. 화면 녹화

```bash
# 녹화 시작
xcrun simctl io booted recordVideo --mask=black demo.mov

# 앱 실행 및 시연
# ...

# 녹화 중지: Ctrl + C
```

#### 2. MOV → GIF 변환

```bash
# ffmpeg 설치
brew install ffmpeg

# GIF 변환
ffmpeg -i demo.mov -vf "fps=10,scale=320:-1:flags=lanczos" -c:v gif demo.gif

# 고품질 GIF (크기 크지만 품질 좋음)
ffmpeg -i demo.mov -vf "fps=15,scale=480:-1:flags=lanczos" demo_hq.gif

# 최적화 (gifsicle)
brew install gifsicle
gifsicle -O3 --colors 256 demo.gif -o demo_optimized.gif
```

---

### 방법 2: Android 에뮬레이터

#### 1. 화면 녹화

```bash
# ADB로 녹화 시작
adb shell screenrecord /sdcard/demo.mp4

# 앱 시연
# ...

# 녹화 중지: Ctrl + C (최대 3분)

# PC로 가져오기
adb pull /sdcard/demo.mp4 ~/Desktop/
```

#### 2. MP4 → GIF 변환

```bash
# ffmpeg로 변환
ffmpeg -i demo.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" demo.gif
```

---

### 방법 3: QuickTime Player (Mac only)

#### 1. 실제 디바이스 녹화

```
1. iPhone을 Mac에 USB 연결
2. QuickTime Player 실행
3. File → New Movie Recording
4. 카메라 선택: iPhone
5. 녹화 버튼 클릭
6. 앱 시연
7. 중지 버튼 클릭
8. File → Save
```

---

### 데모 영상 권장 사양

```
포트폴리오용 GIF:
├─ 크기: 320-480px 너비
├─ 프레임률: 10-15 FPS
├─ 재생 시간: 5-10초
├─ 파일 크기: 5MB 이하
└─ 포맷: GIF 또는 MP4

권장 도구:
├─ LICEcap (Windows/Mac)
├─ Kap (Mac)
├─ ScreenToGif (Windows)
└─ Giphy Capture (Mac)
```

---

### 데모 시나리오 예시

#### 시나리오 1: 로그인 플로우 (10초)

```
1. 스플래시 화면 (1초)
2. 로그인 화면
3. Google 로그인 버튼 클릭
4. 로그인 팝업 (네이티브)
5. 홈 화면 전환
```

#### 시나리오 2: 러닝 추적 (15초)

```
1. 홈 화면
2. "러닝 시작" 버튼 클릭
3. 러닝 화면 진입
4. 지도 표시
5. 시작 버튼 클릭
6. 타이머 및 통계 업데이트
7. 일시정지
8. 종료
```

#### 시나리오 3: 통계 확인 (10초)

```
1. 홈 화면
2. 히스토리 탭 클릭
3. 러닝 기록 목록
4. 특정 기록 클릭
5. 상세 통계 화면
6. 그래프 표시
```

---

## 이미지 최적화

### 1. PNG 최적화

```bash
# pngquant 설치
brew install pngquant

# 단일 파일 최적화
pngquant screenshot.png --output screenshot_optimized.png

# 여러 파일 일괄 최적화
pngquant screenshots/*.png --ext -optimized.png

# 품질 지정 (256 colors)
pngquant --quality=80-100 screenshot.png
```

---

### 2. 일괄 리사이즈

```bash
# ImageMagick 설치
brew install imagemagick

# 너비 800px로 리사이즈 (비율 유지)
magick screenshot.png -resize 800x screenshot_resized.png

# 여러 파일 일괄 처리
for file in screenshots/*.png; do
  magick "$file" -resize 800x "screenshots/resized/$(basename "$file")"
done
```

---

### 3. 워터마크 추가 (선택사항)

```bash
# 텍스트 워터마크
magick screenshot.png \
  -gravity SouthEast \
  -pointsize 40 \
  -fill white \
  -annotate +10+10 'StrideNote' \
  screenshot_watermarked.png

# 이미지 워터마크
magick screenshot.png logo.png \
  -gravity SouthEast \
  -geometry +10+10 \
  -composite \
  screenshot_watermarked.png
```

---

## GitHub에 업로드

### 1. 폴더 구조 확인

```
screenshots/
├── ios/
│   ├── 01_login_screen.png
│   ├── 02_signup_screen.png
│   ├── 03_home_screen.png
│   ├── 04_stats_summary.png
│   ├── 05_running_screen.png
│   ├── 06_running_stats.png
│   ├── 07_history_screen.png
│   ├── 08_detail_screen.png
│   ├── 09_profile_screen.png
│   └── 10_settings_screen.png
├── android/
│   └── (동일 구조)
└── demo/
    ├── demo_login.gif
    ├── demo_running.gif
    └── demo_stats.gif
```

---

### 2. Git 커밋

```bash
# 스크린샷 추가
git add screenshots/

# 커밋
git commit -m "docs: Add screenshots for portfolio"

# 푸시
git push origin main
```

---

### 3. README에 이미지 삽입

```markdown
## 📱 스크린샷

### 로그인 화면

<div align="center">

|                     로그인                     |                     회원가입                      |
| :--------------------------------------------: | :-----------------------------------------------: |
| ![로그인](screenshots/ios/01_login_screen.png) | ![회원가입](screenshots/ios/02_signup_screen.png) |

</div>

### 홈 화면

![홈](screenshots/ios/03_home_screen.png)

### 러닝 추적

<div align="center">

![러닝 데모](screenshots/demo/demo_running.gif)

</div>
```

---

## 고급 팁

### 1. 상태바 숨기기

```dart
// lib/main.dart
SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.immersive,  // 상태바 숨김
);
```

---

### 2. 더미 데이터 주입

```dart
// test/helpers/test_data.dart
class TestData {
  static List<RunningSession> getSampleSessions() {
    return [
      RunningSession(
        id: '1',
        startTime: DateTime(2025, 1, 15, 9, 0),
        endTime: DateTime(2025, 1, 15, 9, 28, 45),
        totalDistance: 5200,
        totalDuration: 1725,
        averagePace: 5.53,
        maxSpeed: 12.5,
        averageHeartRate: 145,
        maxHeartRate: 165,
        caloriesBurned: 320,
        type: RunningType.free,
        gpsPoints: getSampleGPSPoints(),
      ),
      // ... 더 많은 세션
    ];
  }
}
```

---

### 3. 특정 시간 시뮬레이션

```dart
// 특정 시간으로 설정
DateTime debugTime = DateTime(2025, 1, 15, 14, 30);

// 실제 코드에서 사용
final greeting = _getGreeting(debugTime);
```

---

### 4. 스크린샷 자동화 (고급)

```dart
// integration_test/screenshot_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('스크린샷 자동 생성', (tester) async {
    // 1. 앱 실행
    app.main();
    await tester.pumpAndSettle();

    // 2. 홈 화면 스크린샷
    await binding.takeScreenshot('01_home_screen');

    // 3. 로그인 화면으로 이동
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02_login_screen');

    // ... 더 많은 화면
  });
}
```

실행:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  --screenshot=screenshots/
```

---

## 체크리스트

### 촬영 전

- [ ] 테스트 데이터 준비
- [ ] 시뮬레이터/에뮬레이터 실행
- [ ] 올바른 디바이스 선택 (iPhone 15 Pro, Pixel 7 등)
- [ ] 상태바 깔끔하게 (시간, 배터리, 신호 확인)
- [ ] 다크 모드 vs 라이트 모드 결정

### 촬영 중

- [ ] 모든 필수 화면 촬영 (10개)
- [ ] 가로/세로 방향 확인
- [ ] UI 요소 잘림 없는지 확인
- [ ] 로딩 상태 아닌지 확인
- [ ] 에러 메시지 없는지 확인

### 촬영 후

- [ ] 파일명 규칙 준수 (`01_screen_name.png`)
- [ ] 이미지 최적화 (pngquant)
- [ ] 올바른 폴더에 저장 (`screenshots/ios/`)
- [ ] Git에 커밋 및 푸시
- [ ] README에 이미지 삽입
- [ ] 실제로 이미지가 표시되는지 GitHub에서 확인

---

## 추천 도구

### 스크린샷 도구

| 도구              | 플랫폼  | 용도              |
| ----------------- | ------- | ----------------- |
| **LICEcap**       | Mac/Win | 간단한 GIF 녹화   |
| **Kap**           | Mac     | 고품질 화면 녹화  |
| **ScreenToGif**   | Windows | 화면 녹화 및 편집 |
| **Giphy Capture** | Mac     | 빠른 GIF 생성     |

### 이미지 편집

| 도구            | 용도            |
| --------------- | --------------- |
| **ImageMagick** | CLI 이미지 처리 |
| **pngquant**    | PNG 최적화      |
| **Photoshop**   | 고급 편집       |
| **Figma**       | 디자인 및 목업  |

### 디바이스 프레임

| 사이트           | 설명                     |
| ---------------- | ------------------------ |
| **Mockuphone**   | https://mockuphone.com   |
| **Smartmockups** | https://smartmockups.com |
| **Shots**        | https://shots.so         |

---

## FAQ

### Q: 스크린샷 파일 크기가 너무 큽니다

A: PNG 최적화 도구 사용

```bash
pngquant --quality=80-100 screenshot.png
```

### Q: GIF 파일 크기가 10MB를 넘습니다

A: 프레임률 감소 및 크기 조정

```bash
ffmpeg -i demo.mov -vf "fps=8,scale=300:-1" demo.gif
gifsicle -O3 --colors 128 demo.gif -o demo_optimized.gif
```

### Q: 시뮬레이터에서 상태바 시간이 이상합니다

A: 시뮬레이터 재시작 또는 시간 동기화

```bash
# 시뮬레이터 재시작
xcrun simctl shutdown all
xcrun simctl boot "iPhone 15 Pro"
```

### Q: Android 에뮬레이터가 너무 느립니다

A: 하드웨어 가속 활성화

```
AVD Manager → Advanced Settings → Graphics: Hardware
```

---

**이제 멋진 스크린샷으로 포트폴리오를 완성하세요! 🎨**

