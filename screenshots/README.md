# 📸 스크린샷

이 폴더는 포트폴리오용 스크린샷을 저장하는 곳입니다.

## 📁 폴더 구조

```
screenshots/
├── ios/              # iOS 스크린샷
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
├── android/          # Android 스크린샷 (동일 구조)
└── demo/             # 데모 GIF 파일
    ├── demo_login.gif
    ├── demo_running.gif
    └── demo_stats.gif
```

## 🎯 촬영 가이드

**상세 촬영 가이드**: [../docs/SCREENSHOT_GUIDE.md](../docs/SCREENSHOT_GUIDE.md)

### 빠른 시작

#### iOS

```bash
# 1. 시뮬레이터 실행
flutter run -d "iPhone 15 Pro"

# 2. 스크린샷 촬영
# ⌘ + S 키 누르기

# 3. 파일명 변경 후 이동
mv ~/Desktop/Simulator\ Screen\ Shot*.png screenshots/ios/01_login_screen.png
```

#### Android

```bash
# 1. 에뮬레이터 실행
flutter run -d "Pixel 7 Pro API 34"

# 2. 스크린샷 촬영
# Ctrl + S (Windows/Linux) 또는 ⌘ + S (Mac)

# 또는 ADB 명령어
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshots/android/01_login_screen.png
```

## ✅ 필수 스크린샷 목록

- [ ] 01_login_screen.png - 로그인 화면
- [ ] 02_signup_screen.png - 회원가입 화면
- [ ] 03_home_screen.png - 홈 대시보드
- [ ] 04_stats_summary.png - 통계 요약
- [ ] 05_running_screen.png - 러닝 추적 (지도)
- [ ] 06_running_stats.png - 러닝 통계
- [ ] 07_history_screen.png - 히스토리 목록
- [ ] 08_detail_screen.png - 상세 통계
- [ ] 09_profile_screen.png - 프로필
- [ ] 10_settings_screen.png - 설정

## 📐 권장 사양

### iOS

- **디바이스**: iPhone 15 Pro 또는 iPhone 14
- **해상도**: 1170 x 2532
- **포맷**: PNG (품질 100%)

### Android

- **디바이스**: Pixel 7 Pro 또는 Pixel 7
- **해상도**: 1080 x 2400
- **포맷**: PNG (품질 100%)

### 데모 GIF

- **크기**: 320-480px 너비
- **프레임률**: 10-15 FPS
- **파일 크기**: 5MB 이하
- **재생 시간**: 5-10초

## 🎨 팁

### 1. 테스트 데이터 준비

더미 데이터를 미리 생성해두면 스크린샷이 더 풍부해집니다.

### 2. 상태바 깔끔하게

- 시간: 9:41 (Apple의 공식 시간)
- 배터리: 100%
- 신호: 풀바

### 3. 다크 모드 vs 라이트 모드

일관성 있게 하나의 테마로 촬영하세요.

### 4. 에러/로딩 상태 피하기

완성된 화면만 캡처하세요.

## 🔄 이미지 최적화

```bash
# PNG 최적화
brew install pngquant
pngquant screenshots/ios/*.png --ext -optimized.png --quality=80-100

# GIF 최적화
brew install gifsicle
gifsicle -O3 --colors 256 demo.gif -o demo_optimized.gif
```

## 📤 업로드

```bash
# Git에 추가
git add screenshots/

# 커밋
git commit -m "docs: Add screenshots for portfolio"

# 푸시
git push origin main
```

---

**스크린샷을 모두 촬영하셨나요?** ✅

그렇다면 [README.md](../README.md)에서 포트폴리오를 확인해보세요!

