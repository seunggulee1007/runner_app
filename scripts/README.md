# 프로젝트 스크립트

이 디렉토리에는 프로젝트 개발 및 보안을 위한 유틸리티 스크립트가 포함되어 있습니다.

## 📋 스크립트 목록

### 🔒 install-git-hooks.sh

Git Hooks를 자동으로 설치하는 스크립트입니다.

**사용 방법:**
```bash
./scripts/install-git-hooks.sh
```

**기능:**
- API 키 노출 방지를 위한 pre-commit hook 설치
- 커밋 시 자동으로 민감한 정보 검사

**설치되는 Hook:**
- `pre-commit`: 커밋 전 API 키 패턴 검사

### 📂 git-hooks/

프로젝트에 사용되는 Git Hooks가 저장된 디렉토리입니다.

#### pre-commit

커밋 전에 실행되는 Hook으로, 다음 항목을 검사합니다:

- Google API 키 패턴: `AIza[0-9A-Za-z_-]{35}`
- AWS Access Key 패턴: `AKIA[0-9A-Z]{16}`
- OpenAI API 키 패턴: `sk-[a-zA-Z0-9]{48}`
- `.env` 파일 커밋 시도

**검사 통과 시:**
```
🔍 API 키 노출 검사 중...
✅ API 키 검사 완료 - 안전합니다!
```

**검사 실패 시:**
```
❌ 오류: API 키가 발견되었습니다!
   파일: ios/Runner/Info.plist
   패턴: AIza[0-9A-Za-z_-]{35}

🚨 커밋 차단: API 키 또는 민감한 정보가 발견되었습니다!
```

## 🚀 처음 시작하는 경우

프로젝트를 클론한 후 다음 명령어를 실행하세요:

```bash
# 1. Git Hooks 설치
./scripts/install-git-hooks.sh

# 2. 환경 변수 파일 생성
cp .env.example .env

# 3. .env 파일에 실제 API 키 입력
# (편집기로 .env 파일을 열어 수정)
```

## 🔐 보안 정책

### ✅ 해야 할 것

1. **Git Hooks 반드시 설치**
   ```bash
   ./scripts/install-git-hooks.sh
   ```

2. **API 키는 .env에만 저장**
   - .env 파일은 .gitignore에 포함되어 있음
   - 절대 Git에 커밋되지 않음

3. **플레이스홀더 사용**
   - 코드에는 `YOUR_API_KEY_HERE` 같은 플레이스홀더만 사용
   - 실제 키는 빌드 시 자동으로 주입됨

### ❌ 하지 말아야 할 것

1. **API 키를 코드에 하드코딩**
   ```dart
   // ❌ 절대 금지!
   const apiKey = 'AIzaSyABC123...';
   ```

2. **.env 파일을 Git에 커밋**
   ```bash
   # ❌ 절대 금지!
   git add .env
   ```

3. **Git Hooks 우회**
   ```bash
   # 🚨 보안상 권장하지 않음
   git commit --no-verify
   ```

## 🆘 문제 해결

### Git Hooks가 작동하지 않는 경우

```bash
# 1. 실행 권한 확인
ls -la .git/hooks/pre-commit

# 2. 권한이 없다면 추가
chmod +x .git/hooks/pre-commit

# 3. 재설치
./scripts/install-git-hooks.sh
```

### 실수로 API 키를 커밋한 경우

**즉시 다음 조치를 취하세요:**

1. **커밋을 푸시하지 않았다면:**
   ```bash
   git reset HEAD~1
   # API 키 제거 후 다시 커밋
   ```

2. **이미 푸시했다면:**
   - 즉시 팀 리더에게 보고
   - Google Cloud Console에서 해당 키 삭제
   - Git 히스토리 정리 필요 (팀 리더와 상의)

## 📚 추가 정보

- iOS 빌드 스크립트: `../ios/scripts/README.md`
- 환경 변수 설정: `../.env.example`
- 보안 이슈: [GitHub Issues #28](https://github.com/seunggulee1007/runner_app/issues/28)

---

**⚠️ 중요**: 이 스크립트들은 프로젝트의 보안을 위해 필수적입니다. 모든 팀원은 반드시 Git Hooks를 설치하고 보안 정책을 준수해야 합니다.
