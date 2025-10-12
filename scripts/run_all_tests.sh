#!/bin/bash

# 🧪 전체 테스트 실행 스크립트
# TDD 사이클의 각 단계에서 사용

set -e  # 에러 발생 시 즉시 종료

echo "======================================"
echo "🧪 전체 테스트 실행"
echo "======================================"
echo ""

# 현재 시간 기록
START_TIME=$(date +%s)

# 테스트 실행
echo "📝 테스트 실행 중..."
flutter test

# 종료 시간 계산
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "======================================"
echo "✅ 모든 테스트 통과!"
echo "======================================"
echo "⏱️  소요 시간: ${DURATION}초"
echo ""

# 성공 사운드 (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
fi

exit 0

