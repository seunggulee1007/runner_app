#!/bin/bash

# .env 파일 경로
ENV_FILE="${SRCROOT}/../.env"
INFO_PLIST="${SRCROOT}/Runner/Info.plist"

# .env 파일이 존재하는지 확인
if [ ! -f "$ENV_FILE" ]; then
  echo "⚠️  .env 파일을 찾을 수 없습니다: $ENV_FILE"
  echo "ℹ️  .env.example을 복사하여 .env 파일을 생성하고 실제 API 키를 입력하세요."
  exit 0
fi

# .env 파일에서 GOOGLE_MAPS_API_KEY_IOS 읽기
API_KEY=$(grep -E '^GOOGLE_MAPS_API_KEY_IOS=' "$ENV_FILE" | cut -d '=' -f2)

# API 키가 비어있거나 플레이스홀더인지 확인
if [ -z "$API_KEY" ] || [ "$API_KEY" == "your_ios_google_maps_api_key_here" ]; then
  echo "⚠️  Google Maps API Key가 설정되지 않았습니다."
  echo "ℹ️  .env 파일에서 GOOGLE_MAPS_API_KEY_IOS를 설정하세요."
  exit 0
fi

# Info.plist에 API 키 주입
/usr/libexec/PlistBuddy -c "Set :GMSApiKey $API_KEY" "$INFO_PLIST" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :GMSApiKey string $API_KEY" "$INFO_PLIST"

echo "✅ Google Maps API Key가 Info.plist에 설정되었습니다."
