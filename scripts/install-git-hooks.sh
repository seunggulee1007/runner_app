#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Git Hooks 설치 중...${NC}"

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# pre-commit hook 설치
cp "$PROJECT_ROOT/scripts/git-hooks/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
chmod +x "$GIT_HOOKS_DIR/pre-commit"

echo -e "${GREEN}✅ Git Hooks 설치 완료!${NC}"
echo ""
echo "설치된 Hook:"
echo "  - pre-commit: API 키 노출 방지"
echo ""
echo "이제 커밋할 때마다 자동으로 API 키가 검사됩니다."
