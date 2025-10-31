# 보안 가이드 (Security Guide)

## 🚨 중요: 민감한 정보 보호

이 프로젝트에는 민감한 API 키와 설정 정보가 포함되어 있습니다. Git에 커밋하기 전에 반드시 확인하세요.

## 🔒 보안 체크리스트

### ✅ 해야 할 것들

1. **환경 변수 사용**

   - API 키, 시크릿, 토큰은 환경 변수로 관리
   - `.env` 파일을 사용하여 민감한 정보 분리
   - `.env` 파일은 `.gitignore`에 포함되어 있음

2. **Git 커밋 전 확인**

   ```bash
   # 커밋 전 민감한 정보 검사
   git diff --cached | grep -E "(api[_-]?key|secret|password|token|private[_-]?key|client[_-]?secret|auth[_-]?key)"
   ```

3. **환경 변수 파일 설정**
   ```bash
   # .env 파일 생성 (프로젝트 루트에)
   cp .env.example .env
   # .env 파일에 실제 값 입력
   ```

### ❌ 하지 말아야 할 것들

1. **하드코딩 금지**

   - API 키를 소스 코드에 직접 작성하지 말 것
   - 패스워드, 시크릿을 코드에 포함하지 말 것

2. **공개 저장소에 민감한 정보 업로드 금지**
   - GitHub, GitLab 등 공개 저장소에 API 키 업로드 금지
   - 이미 업로드된 경우 즉시 키 재생성 필요

## 🔧 현재 프로젝트의 민감한 정보

### Supabase 설정

- **URL**: `your_supabase_url_here`
- **Anonymous Key**: `your_supabase_anon_key_here`

### Google OAuth 설정 (향후 사용)

- **Android Client ID**: `your_google_client_id_android`
- **iOS Client ID**: `your_google_client_id_ios`
- **Web Client ID**: `your_google_client_id_web`
- **Client Secret**: `your_google_client_secret`

## 🛠️ 환경 변수 설정 방법

### 1. .env 파일 생성

```bash
# 프로젝트 루트에 .env 파일 생성
touch .env
```

### 2. .env 파일 내용

```env
# Supabase 설정
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Google OAuth 설정
GOOGLE_CLIENT_ID_ANDROID=your_google_client_id_android
GOOGLE_CLIENT_ID_IOS=your_google_client_id_ios
GOOGLE_CLIENT_ID_WEB=your_google_client_id_web
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

### 3. .env.example 파일 생성 (팀원들을 위해)

```env
# Supabase 설정
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Google OAuth 설정
GOOGLE_CLIENT_ID_ANDROID=your_google_client_id_android
GOOGLE_CLIENT_ID_IOS=your_google_client_id_ios
GOOGLE_CLIENT_ID_WEB=your_google_client_id_web
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

## 🚀 배포 시 주의사항

### 개발 환경

- `.env` 파일 사용
- 로컬에서만 민감한 정보 관리

### 프로덕션 환경

- 환경 변수로 직접 설정
- CI/CD 파이프라인에서 보안 변수 관리
- 하드코딩된 값 제거

## 🔍 보안 검사 도구

### Git Hooks 설정

```bash
# pre-commit hook 설정
echo '#!/bin/bash
if git diff --cached | grep -E "(api[_-]?key|secret|password|token|private[_-]?key|client[_-]?secret|auth[_-]?key)"; then
    echo "❌ 민감한 정보가 감지되었습니다. 커밋을 중단합니다."
    exit 1
fi' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 📞 문제 발생 시

만약 민감한 정보가 공개 저장소에 업로드되었다면:

1. **즉시 키 재생성**

   - Supabase Dashboard에서 새 API 키 생성
   - Google Cloud Console에서 새 OAuth 클라이언트 생성

2. **Git 히스토리 정리**

   ```bash
   # 민감한 정보가 포함된 커밋 제거
   git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch lib/config/supabase_config.dart' --prune-empty --tag-name-filter cat -- --all
   ```

3. **팀원들에게 알림**
   - 새로운 키 정보 공유
   - 보안 정책 재교육

---

**⚠️ 이 문서를 팀원들과 공유하고, 보안 정책을 준수하세요.**
