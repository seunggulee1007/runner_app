# 기여 가이드

## 개발 환경 설정

### 필요 조건
- Flutter SDK (최신 안정 버전)
- Dart SDK
- Android Studio 또는 VS Code
- Git

### 프로젝트 설정
1. 레포지토리 클론
```bash
git clone https://github.com/seunggulee1007/runner_app.git
cd runner_app
```

2. 의존성 설치
```bash
flutter pub get
```

3. 코드 생성 (필요한 경우)
```bash
flutter packages pub run build_runner build
```

## 브랜치 전략

- `main`: 프로덕션 배포용 브랜치
- `develop`: 개발 통합 브랜치
- `feature/*`: 새로운 기능 개발
- `fix/*`: 버그 수정
- `hotfix/*`: 긴급 수정

## 커밋 메시지 규칙

- 한국어 명령조로 작성
- 형식: "[작업내용] [목적]"
- 예시: "GPS 위치 추적 기능 추가 및 러닝 세션 저장 로직 구현할것"

## Pull Request 규칙

1. 이슈를 먼저 생성
2. 브랜치명은 `{type}/issue-number` 형식 사용
3. PR 템플릿에 따라 작성
4. 코드 리뷰 후 머지

## 코드 스타일

- Dart/Flutter 공식 스타일 가이드 준수
- `analysis_options.yaml` 설정 따르기
- 의미있는 변수명과 함수명 사용
- 주석은 한국어로 작성
