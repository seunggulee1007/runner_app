#!/bin/bash

# 🧪 커버리지 포함 전체 테스트 실행 스크립트
# TDD 완료 후 또는 커밋 전 실행

set -e  # 에러 발생 시 즉시 종료

echo "======================================"
echo "🧪 커버리지 포함 전체 테스트 실행"
echo "======================================"
echo ""

# 현재 시간 기록
START_TIME=$(date +%s)

# 테스트 실행 (커버리지 포함)
echo "📝 테스트 실행 중 (커버리지 측정)..."
flutter test --coverage

# 종료 시간 계산
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "======================================"
echo "✅ 모든 테스트 통과!"
echo "======================================"
echo "⏱️  소요 시간: ${DURATION}초"
echo ""

# 커버리지 확인
if [ -f "coverage/lcov.info" ]; then
    echo "📊 커버리지 리포트 생성됨: coverage/lcov.info"
    echo ""
    echo "📊 커버리지 확인 방법:"
    echo "  1. 터미널: lcov --summary coverage/lcov.info"
    echo "  2. HTML:   genhtml coverage/lcov.info -o coverage/html"
    echo "             open coverage/html/index.html"
    echo ""
fi

# 성공 사운드 (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
fi

exit 0

