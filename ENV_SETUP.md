# 환경 변수 설정 가이드

## .env 파일 생성

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가하세요:

```bash
# Supabase 설정
SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
SUPABASE_ANON_KEY=YOUR-SUPABASE-ANON-KEY

# Google OAuth 설정 (선택사항)
GOOGLE_CLIENT_ID_ANDROID=YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com
GOOGLE_CLIENT_ID_IOS=YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com
GOOGLE_CLIENT_ID_WEB=YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=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
```

## 주의사항

- `.env` 파일은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다
- 실제 배포 시에는 환경 변수를 안전하게 관리하세요
- 현재는 개발용 기본값이 하드코딩되어 있어 `.env` 파일이 없어도 앱이 실행됩니다

## 파일 생성 방법

```bash
# 프로젝트 루트에서 실행
touch .env

# 위의 내용을 .env 파일에 복사하여 붙여넣기
```
