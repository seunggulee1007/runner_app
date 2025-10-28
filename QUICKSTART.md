# 🚀 빠른 시작 가이드

이 가이드는 **포트폴리오를 GitHub에 업로드하는 전체 과정**을 단계별로 설명합니다.

---

## 📋 준비물

- [x] Flutter 프로젝트 완성
- [ ] 개인 정보 (이름, 이메일, GitHub 주소 등)
- [ ] 앱 스크린샷 (선택사항, 나중에 추가 가능)
- [ ] GitHub 계정

---

## 🎯 Step 1: 개인 정보 수정 (5분)

### 1.1 README.md 수정

`README.md` 파일을 열고 다음 부분을 수정하세요:

```markdown
# 1. 개발 기간 수정 (14번째 줄 근처)
**개발 기간**: 2024.01 ~ 2025.02 (14개월)  # 실제 기간으로 변경

# 2. 연락처 수정 (파일 맨 아래)
[![Email](...)](mailto:your.email@example.com)  # 실제 이메일로 변경
[![GitHub](...)](https://github.com/yourusername)  # 실제 GitHub 주소로 변경
```

### 1.2 빠른 찾기 & 바꾸기

**VS Code / Cursor**:
1. `Cmd/Ctrl + Shift + F` (전체 찾기)
2. 다음 키워드를 찾아서 실제 정보로 변경:
   - `[귀하의 이름]` → 본인 이름
   - `[your.email@example.com]` → 실제 이메일
   - `[github.com/yourusername]` → 실제 GitHub 주소
   - `[yourportfolio.com]` → 실제 포트폴리오 주소 (없으면 삭제)
   - `2024.XX ~ 2025.XX` → 실제 개발 기간

---

## 🖼️ Step 2: 스크린샷 준비 (선택사항, 나중에 가능)

### 2.1 스크린샷이 없는 경우

걱정하지 마세요! 스크린샷 없이도 포트폴리오를 먼저 업로드할 수 있습니다.

**임시 방법 1**: 스크린샷 섹션 주석 처리
```markdown
<!-- 
### 인증 및 온보딩
...스크린샷 섹션...
-->
```

**임시 방법 2**: Placeholder 이미지 사용
```markdown
![Coming Soon](https://via.placeholder.com/300x600.png?text=Coming+Soon)
```

### 2.2 스크린샷 준비하기

나중에 스크린샷을 추가하려면:

1. [docs/SCREENSHOT_GUIDE.md](docs/SCREENSHOT_GUIDE.md) 참고
2. 스크린샷 촬영
3. `screenshots/ios/` 폴더에 저장
4. Git에 추가: `git add screenshots/`

---

## 📦 Step 3: GitHub 저장소 생성 (2분)

### 3.1 GitHub에서 새 저장소 생성

1. [GitHub](https://github.com) 로그인
2. 우측 상단 **"+"** → **"New repository"** 클릭
3. 저장소 정보 입력:
   ```
   Repository name: stride-note (또는 원하는 이름)
   Description: GPS 기반 실시간 러닝 추적 및 건강 데이터 통합 앱
   Public/Private: Public 선택 (포트폴리오용)
   ✅ Add a README file: 체크 해제 (이미 있음)
   ✅ Add .gitignore: None
   ✅ Choose a license: MIT
   ```
4. **"Create repository"** 클릭

### 3.2 저장소 URL 복사

생성된 저장소 페이지에서 HTTPS URL 복사:
```
https://github.com/yourusername/stride-note.git
```

---

## 🚀 Step 4: Git Push (3분)

### 4.1 기존 Git 저장소 확인

```bash
# 현재 프로젝트 폴더로 이동
cd /Users/nhn/Desktop/DEV/flutter-workspace/runner_app

# Git 상태 확인
git status
```

### 4.2 Remote 저장소 연결

```bash
# GitHub 저장소 연결
git remote add origin https://github.com/yourusername/stride-note.git

# 또는 기존 origin 변경
git remote set-url origin https://github.com/yourusername/stride-note.git

# 연결 확인
git remote -v
```

### 4.3 Push

```bash
# main 브랜치로 Push
git push -u origin main

# 또는 현재 브랜치 Push
git push -u origin HEAD
```

**에러 발생 시**:
```bash
# 강제 Push (주의: 기존 내용 덮어씀)
git push -u origin main --force
```

---

## ✅ Step 5: 최종 확인 (1분)

### 5.1 GitHub 페이지 확인

브라우저에서 저장소 주소로 이동:
```
https://github.com/yourusername/stride-note
```

다음을 확인하세요:
- [ ] README.md가 잘 표시되는가?
- [ ] 개인 정보가 올바른가?
- [ ] 링크들이 작동하는가?
- [ ] 이미지가 깨지지 않았는가?

### 5.2 README 프리뷰

GitHub에서 README.md 파일을 클릭하여:
- 레이아웃이 깨지지 않았는지 확인
- 모든 섹션이 잘 표시되는지 확인
- 배지(Badge)가 정상 작동하는지 확인

---

## 🎨 Step 6: 추가 개선 (선택사항)

### 6.1 GitHub Pages 활성화 (선택)

더 전문적인 프로젝트 페이지를 만들려면:

1. 저장소 **Settings** 탭
2. 좌측 메뉴에서 **Pages**
3. Source: `main` 브랜치 선택
4. **Save** 클릭
5. 생성된 URL 확인: `https://yourusername.github.io/stride-note`

### 6.2 Topics 추가

저장소를 더 쉽게 검색되도록:

1. 저장소 메인 페이지
2. 우측 상단 **⚙️ (Settings)** 옆 **About** 섹션
3. **Topics** 추가:
   ```
   flutter, dart, mobile-app, gps-tracking, health-app, 
   supabase, google-maps, cross-platform, portfolio
   ```

### 6.3 README 배지 추가

```markdown
![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)
![Stars](https://img.shields.io/github/stars/yourusername/stride-note)
![Forks](https://img.shields.io/github/forks/yourusername/stride-note)
![License](https://img.shields.io/github/license/yourusername/stride-note)
```

---

## 📝 Step 7: 이력서에 추가

### 이력서 프로젝트 섹션 예시

```
📱 StrideNote - 실시간 러닝 추적 앱
2024.01 ~ 2025.02 | 1인 개발 (기획, 개발, 배포)

• Flutter로 iOS/Android 크로스 플랫폼 앱 개발
• GPS 최적화로 배터리 소모 30% 감소 (20% → 14%)
• Google 로그인 성공률 100% 달성 (95% → 100%)
• HealthKit/Google Fit 통합으로 실시간 심박수 모니터링 구현
• PostgreSQL Trigger로 프로필 자동 생성 시스템 구축
• TDD 방법론 적용, 테스트 커버리지 87.3% 달성

기술 스택: Flutter, Dart, Supabase, PostgreSQL, Google Maps API
GitHub: https://github.com/yourusername/stride-note
```

---

## 🔥 Pro Tips

### 1. 꾸준한 업데이트

```bash
# 새로운 기능 추가 후
git add .
git commit -m "feat: Add new feature"
git push
```

### 2. 스크린샷 나중에 추가

```bash
# 스크린샷 촬영 후
git add screenshots/
git commit -m "docs: Add app screenshots"
git push
```

### 3. README 개선

README.md는 **계속 진화**하는 문서입니다:
- 새로운 기능 추가 시 문서 업데이트
- 성과 지표 업데이트
- 기술 블로그 링크 추가
- 사용자 피드백 반영

### 4. Star 받기

친구들에게 GitHub 저장소 링크를 공유하고 Star를 받으세요!
- Star가 많을수록 프로젝트가 더 신뢰도 있어 보입니다
- 채용 담당자에게 좋은 인상을 줄 수 있습니다

---

## 🆘 문제 해결

### Q1: "remote origin already exists" 에러

```bash
# 기존 remote 제거
git remote remove origin

# 새로 추가
git remote add origin https://github.com/yourusername/stride-note.git
```

### Q2: 스크린샷 이미지가 깨짐

경로를 확인하세요:
- ✅ 올바른 경로: `screenshots/ios/01_login_screen.png`
- ❌ 잘못된 경로: `/screenshots/ios/01_login_screen.png`

### Q3: Mermaid 다이어그램이 보이지 않음

GitHub에서는 자동으로 렌더링됩니다. 로컬 편집기에서는 안 보일 수 있습니다.

### Q4: 배지(Badge)가 작동하지 않음

URL의 `yourusername`과 `stride-note`를 실제 값으로 변경했는지 확인하세요.

---

## ✨ 축하합니다!

포트폴리오 프로젝트를 성공적으로 GitHub에 업로드했습니다! 🎉

### 다음 단계

1. **이력서 업데이트**: 프로젝트 링크 추가
2. **LinkedIn 게시**: 프로젝트 완성 소식 공유
3. **기술 블로그 작성**: 주요 기술적 도전과제 정리
4. **오픈소스 기여**: 사용한 패키지에 기여해보기

---

**질문이나 피드백이 있으시면 GitHub Issues를 생성해주세요!**

**행운을 빕니다! 🍀**

