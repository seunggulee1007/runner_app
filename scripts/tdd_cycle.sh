#!/bin/bash

# 🔄 TDD 사이클 헬퍼 스크립트
# Red → Green → Refactor 각 단계에서 전체 테스트 실행

set -e

STEP=$1

case "$STEP" in
  "red"|"RED"|"1")
    echo "======================================"
    echo "🔴 RED 단계: 실패하는 테스트 확인"
    echo "======================================"
    echo ""
    echo "📝 테스트 파일을 작성한 후 이 스크립트를 실행하세요."
    echo ""
    read -p "테스트를 작성했나요? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "❌ 테스트를 먼저 작성해주세요."
        exit 1
    fi
    echo ""
    echo "🧪 전체 테스트 실행 중 (실패 예상)..."
    echo ""
    flutter test && echo "⚠️  경고: 테스트가 실패해야 하는데 통과했습니다!" || echo "✅ 테스트가 예상대로 실패했습니다. Green 단계로 진행하세요."
    ;;

  "green"|"GREEN"|"2")
    echo "======================================"
    echo "🟢 GREEN 단계: 최소 구현으로 테스트 통과"
    echo "======================================"
    echo ""
    echo "📝 최소 구현 코드를 작성한 후 이 스크립트를 실행하세요."
    echo ""
    read -p "구현 코드를 작성했나요? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "❌ 구현 코드를 먼저 작성해주세요."
        exit 1
    fi
    echo ""
    echo "🧪 전체 테스트 실행 중 (통과 예상)..."
    echo ""
    flutter test
    echo ""
    echo "✅ 모든 테스트 통과!"
    echo "✅ 사이드 이펙트 없음 확인 완료!"
    echo ""
    echo "다음 단계: Refactor (코드 개선) 또는 다음 기능"
    ;;

  "refactor"|"REFACTOR"|"3")
    echo "======================================"
    echo "🔵 REFACTOR 단계: 코드 개선"
    echo "======================================"
    echo ""
    echo "📝 리팩터링 전 테스트 실행..."
    echo ""
    flutter test
    echo ""
    echo "✅ 리팩터링 전 모든 테스트 통과 확인!"
    echo ""
    read -p "리팩터링을 진행하시겠습니까? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "리팩터링을 건너뜁니다."
        exit 0
    fi
    echo ""
    echo "📝 리팩터링 후 Enter를 눌러주세요..."
    read
    echo ""
    echo "🧪 리팩터링 후 전체 테스트 실행 중..."
    echo ""
    flutter test
    echo ""
    echo "✅ 리팩터링 완료!"
    echo "✅ 동작 불변성 확인 완료!"
    echo "✅ 사이드 이펙트 없음 확인 완료!"
    ;;

  *)
    echo "======================================"
    echo "🔄 TDD 사이클 헬퍼"
    echo "======================================"
    echo ""
    echo "사용법:"
    echo "  bash scripts/tdd_cycle.sh red      # 🔴 Red 단계"
    echo "  bash scripts/tdd_cycle.sh green    # 🟢 Green 단계"
    echo "  bash scripts/tdd_cycle.sh refactor # 🔵 Refactor 단계"
    echo ""
    echo "각 단계에서 전체 테스트를 실행하여:"
    echo "  - Red: 테스트 실패 확인"
    echo "  - Green: 모든 테스트 통과 + 사이드 이펙트 체크"
    echo "  - Refactor: 동작 불변성 + 사이드 이펙트 체크"
    echo ""
    exit 1
    ;;
esac

