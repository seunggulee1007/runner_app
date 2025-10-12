#!/bin/bash

# 🔍 환경 변수 설정 확인 스크립트
# 실행: bash scripts/check_env.sh

echo "======================================"
echo "🔍 환경 변수 설정 확인"
echo "======================================"
echo ""

# .env 파일 존재 확인
if [ ! -f ".env" ]; then
    echo "❌ .env 파일이 없습니다!"
    echo ""
    echo "해결 방법:"
    echo "  cp .env.example .env"
    echo ""
    exit 1
fi

echo "✅ .env 파일 존재 확인"
echo ""

# 환경 변수 로드
source .env 2>/dev/null

# 검증 함수
check_var() {
    local var_name=$1
    local var_value=$2
    local is_required=$3
    
    if [ -z "$var_value" ] || [[ "$var_value" == *"your-"* ]]; then
        if [ "$is_required" == "required" ]; then
            echo "❌ $var_name: 설정 필요 (필수)"
            return 1
        else
            echo "⚠️  $var_name: 설정되지 않음 (선택)"
            return 0
        fi
    else
        # 키 마스킹 (앞 15자만 표시)
        local masked_value="${var_value:0:15}..."
        echo "✅ $var_name: $masked_value"
        return 0
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Supabase Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_var "SUPABASE_URL" "$SUPABASE_URL" "required"
check_var "SUPABASE_ANON_KEY" "$SUPABASE_ANON_KEY" "required"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Google OAuth Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_var "GOOGLE_WEB_CLIENT_ID" "$GOOGLE_WEB_CLIENT_ID" "required"
check_var "GOOGLE_IOS_CLIENT_ID" "$GOOGLE_IOS_CLIENT_ID" "optional"
check_var "GOOGLE_ANDROID_CLIENT_ID" "$GOOGLE_ANDROID_CLIENT_ID" "optional"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  App Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_var "BUNDLE_ID" "$BUNDLE_ID" "optional"
echo ""

# 최종 결과
echo "======================================"
if [ -z "$SUPABASE_URL" ] || [[ "$SUPABASE_URL" == *"your-"* ]] || \
   [ -z "$SUPABASE_ANON_KEY" ] || [[ "$SUPABASE_ANON_KEY" == *"your-"* ]] || \
   [ -z "$GOOGLE_WEB_CLIENT_ID" ] || [[ "$GOOGLE_WEB_CLIENT_ID" == *"your-"* ]]; then
    echo "❌ 필수 환경 변수가 설정되지 않았습니다"
    echo ""
    echo "다음 단계:"
    echo "  1. .env 파일 열기: code .env"
    echo "  2. 실제 값으로 변경"
    echo "  3. 앱 재시작: flutter run"
    echo ""
    echo "자세한 가이드: ENV_FIX_GUIDE.md"
    echo "======================================"
    exit 1
else
    echo "✅ 모든 필수 환경 변수가 설정되었습니다!"
    echo ""
    echo "다음 단계:"
    echo "  flutter clean"
    echo "  flutter pub get"
    echo "  flutter run"
    echo "======================================"
    exit 0
fi

