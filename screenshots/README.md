# 📸 스크린샷 가이드

## 📁 폴더 구조

```
screenshots/
├── ios/                 # iOS 스크린샷
│   ├── login.png
│   ├── signup.png
│   ├── home.png
│   ├── stats.png
│   ├── running.png
│   ├── history.png
│   └── profile.png
│
├── android/             # Android 스크린샷
│   ├── login.png
│   ├── signup.png
│   ├── home.png
│   ├── stats.png
│   ├── running.png
│   ├── history.png
│   └── profile.png
│
└── demo/                # 데모 GIF/영상 (선택)
    └── demo.gif
```

---

## 🎯 필요한 스크린샷 (각 플랫폼별 7개)

### 1. 로그인 화면 (`login.png`)
- Google 소셜 로그인 버튼 강조
- 이메일 로그인 폼

### 2. 회원가입 화면 (`signup.png`)
- 회원가입 폼
- 실시간 검증 표시

### 3. 홈 화면 (`home.png`)
- 대시보드 통계
- 빠른 실행 버튼

### 4. 통계 화면 (`stats.png`)
- 주간/월간 통계
- 차트 표시

### 5. 러닝 화면 (`running.png`)
- 지도 + GPS 경로
- 실시간 통계 (거리, 시간, 페이스)

### 6. 히스토리 화면 (`history.png`)
- 러닝 기록 목록
- 상세 통계

### 7. 프로필 화면 (`profile.png`)
- 사용자 정보
- 전체 러닝 통계

---

## 📱 촬영 방법

### iOS (Simulator)

```bash
# 1. Simulator 실행
flutter run

# 2. 스크린샷 저장 (Simulator에서)
Cmd + S

# 또는 터미널에서
xcrun simctl io booted screenshot screenshots/ios/login.png
```

### Android (Emulator)

```bash
# 1. Emulator 실행
flutter run

# 2. 스크린샷 저장
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png screenshots/android/login.png
```

---

## 🎨 권장 사항

### 화면 크기
- **iOS**: iPhone 14 Pro (1179 x 2556)
- **Android**: Pixel 6 (1080 x 2400)

### 파일 형식
- PNG (투명 배경 지원)
- 최대 2MB 이하

### 해상도
- 2x 또는 3x 해상도 권장
- 선명하게 보이도록

---

## ✅ 체크리스트

촬영 후 확인:

- [ ] iOS 스크린샷 7개 완료
- [ ] Android 스크린샷 7개 완료
- [ ] 파일명이 정확한지 확인
- [ ] 파일 크기가 2MB 이하인지 확인
- [ ] PORTFOLIO.md에서 이미지가 제대로 표시되는지 확인

---

## 💡 팁

1. **앱 내 데이터 준비**
   - 실제 러닝 데이터가 있는 상태에서 촬영
   - 통계 차트가 보기 좋게 표시되도록

2. **라이트/다크 모드**
   - 현재 앱 테마에 맞춰 촬영
   - 일관성 유지

3. **개인 정보**
   - 실제 개인 정보는 가리거나 테스트 계정 사용

---

<div align="center">

### 📸 완료 후 PORTFOLIO.md 확인하세요!

</div>
