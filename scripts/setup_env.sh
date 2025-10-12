#!/bin/bash

# 🔐 환경 변수 설정 도우미 스크립트

echo "======================================"
echo "🔐 환경 변수 설정 도우미"
echo "======================================"
echo ""
echo "이 스크립트는 .env 파일을 생성하고 실제 값을 입력하는 것을 도와줍니다."
echo ""

# .env 파일이 이미 있는지 확인
if [ -f ".env" ]; then
    echo "⚠️  .env 파일이 이미 존재합니다."
    read -p "덮어쓰시겠습니까? (y/N): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "취소되었습니다."
        exit 0
    fi
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 1. Supabase 설정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Supabase Dashboard에서 가져오기:"
echo "   https://supabase.com/dashboard"
echo "   → 프로젝트 선택 → Settings → API"
echo ""

read -p "Supabase URL (예: https://xxxxx.supabase.co): " SUPABASE_URL
while [[ -z "$SUPABASE_URL" ]]; do
    read -p "❌ 필수 항목입니다. Supabase URL: " SUPABASE_URL
done

echo ""
read -p "Supabase Anon Key (긴 문자열): " SUPABASE_ANON_KEY
while [[ -z "$SUPABASE_ANON_KEY" ]]; do
    read -p "❌ 필수 항목입니다. Supabase Anon Key: " SUPABASE_ANON_KEY
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 2. Google OAuth 설정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Google Cloud Console에서 가져오기:"
echo "   https://console.cloud.google.com"
echo "   → APIs & Services → Credentials"
echo "   → Web client (auto created by Google Service)"
echo ""

read -p "Google Web Client ID (xxx.apps.googleusercontent.com): " GOOGLE_WEB_CLIENT_ID
while [[ -z "$GOOGLE_WEB_CLIENT_ID" ]]; do
    read -p "❌ 필수 항목입니다. Google Web Client ID: " GOOGLE_WEB_CLIENT_ID
done

echo ""
read -p "Google iOS Client ID (선택, Enter로 건너뛰기): " GOOGLE_IOS_CLIENT_ID
read -p "Google Android Client ID (선택, Enter로 건너뛰기): " GOOGLE_ANDROID_CLIENT_ID

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  3. 앱 설정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Bundle ID (기본값: com.example.runnerApp): " BUNDLE_ID
BUNDLE_ID=${BUNDLE_ID:-com.example.runnerApp}

# .env 파일 생성
cat > .env << EOF
# ======================================
# 🔐 환경 변수 파일
# ======================================
# 
# ⚠️ 이 파일은 Git에 커밋하지 마세요!
# 자동 생성: $(date '+%Y-%m-%d %H:%M:%S')
#

# ======================================
# Supabase Configuration
# ======================================

SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# ======================================
# Google OAuth Configuration
# ======================================

GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID
EOF

# 선택 항목 추가
if [ ! -z "$GOOGLE_IOS_CLIENT_ID" ]; then
    echo "GOOGLE_IOS_CLIENT_ID=$GOOGLE_IOS_CLIENT_ID" >> .env
fi

if [ ! -z "$GOOGLE_ANDROID_CLIENT_ID" ]; then
    echo "GOOGLE_ANDROID_CLIENT_ID=$GOOGLE_ANDROID_CLIENT_ID" >> .env
fi

# 앱 설정 추가
cat >> .env << EOF

# ======================================
# App Configuration
# ======================================

BUNDLE_ID=$BUNDLE_ID
EOF

echo ""
echo "======================================"
echo "✅ .env 파일이 생성되었습니다!"
echo "======================================"
echo ""

# 환경 변수 검증
echo "🔍 환경 변수 검증 중..."
echo ""
bash scripts/check_env.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "======================================"
    echo "🎉 설정 완료!"
    echo "======================================"
    echo ""
    echo "다음 단계:"
    echo "  flutter clean"
    echo "  flutter pub get"
    echo "  flutter run"
    echo ""
else
    echo ""
    echo "⚠️  일부 값이 올바르지 않을 수 있습니다."
    echo "   .env 파일을 직접 확인해주세요: code .env"
    echo ""
fi

