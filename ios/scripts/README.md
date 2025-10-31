# iOS Build Scripts

## setup_env.sh

이 스크립트는 빌드 시 `.env` 파일에서 환경 변수를 읽어 `Info.plist`에 주입합니다.

### 동작 방식

1. 프로젝트 루트의 `.env` 파일을 읽습니다
2. `GOOGLE_MAPS_API_KEY_IOS` 값을 찾습니다
3. `ios/Runner/Info.plist`의 `GMSApiKey`에 값을 주입합니다

### 설정 방법

1. 프로젝트 루트에 `.env` 파일 생성:
```bash
cp .env.example .env
```

2. `.env` 파일에 실제 API 키 입력:
```env
GOOGLE_MAPS_API_KEY_IOS=your_actual_api_key_here
```

3. Xcode 빌드 시 자동으로 실행됩니다

### 주의사항

- `.env` 파일은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다
- `Info.plist`는 플레이스홀더 값을 유지한 채로 Git에 커밋됩니다
- 빌드할 때마다 스크립트가 실행되어 실제 키를 주입합니다
