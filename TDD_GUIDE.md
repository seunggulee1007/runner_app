# 🔄 TDD 개발 가이드

## 📋 개요

이 프로젝트는 **엄격한 TDD (Test-Driven Development)** 원칙을 따릅니다.
모든 기능 개발은 **Red → Green → Refactor** 사이클을 준수하며, 각 단계에서 **전체 테스트를 실행**하여 사이드 이펙트를 확인합니다.

---

## 🎯 핵심 원칙

### 1. 테스트가 먼저

- ❌ 코드 먼저 작성 → 테스트 작성
- ✅ **테스트 먼저 작성** → 코드 작성

### 2. 전체 테스트 실행 필수

각 단계마다 **반드시** 전체 테스트를 실행하여:

- 새로운 테스트가 제대로 실패하는지 확인 (Red)
- 모든 테스트가 통과하는지 확인 (Green)
- 리팩터링이 기존 동작을 깨뜨리지 않는지 확인 (Refactor)

### 3. 사이드 이펙트 제로

- 새로운 기능이 기존 기능에 영향을 미치지 않아야 함
- 전체 테스트 실행으로 검증

---

## 🔄 TDD 사이클

### 🔴 1단계: Red (실패하는 테스트 작성)

**목표**: 요구사항을 테스트로 명세하고 실패 확인

```bash
# 1. 테스트 파일 작성
# test/unit/services/new_feature_test.dart

# 2. 테스트 실행 (실패 확인)
bash scripts/tdd_cycle.sh red

# 또는
flutter test
```

**체크리스트**:

- [ ] 테스트 파일 작성 완료
- [ ] 테스트가 예상대로 실패함
- [ ] 실패 메시지가 명확함

---

### 🟢 2단계: Green (최소 구현)

**목표**: 테스트를 통과시키는 최소한의 코드 작성

```bash
# 1. 최소 구현 코드 작성
# lib/services/new_feature.dart

# 2. 전체 테스트 실행 (모두 통과 확인)
bash scripts/tdd_cycle.sh green

# 또는
flutter test
```

**체크리스트**:

- [ ] 최소 구현 코드 작성 완료
- [ ] 새로운 테스트가 통과함
- [ ] **모든 기존 테스트도 통과함** (사이드 이펙트 없음)
- [ ] 과도한 구현 없음 (YAGNI 원칙)

---

### 🔵 3단계: Refactor (코드 개선)

**목표**: 중복 제거, 명확한 네이밍, 구조 개선

```bash
# 1. 리팩터링 전 테스트 (안전 확인)
bash scripts/tdd_cycle.sh refactor

# 2. 코드 개선 진행

# 3. 리팩터링 후 테스트 (동작 불변성 확인)
flutter test
```

**체크리스트**:

- [ ] 리팩터링 전 모든 테스트 통과
- [ ] 코드 개선 완료 (중복 제거, 네이밍 개선 등)
- [ ] 리팩터링 후 모든 테스트 통과
- [ ] **기존 동작이 변경되지 않음** (동작 불변성)

---

## 🛠️ 테스트 실행 스크립트

### 기본 전체 테스트

```bash
# 모든 테스트 실행
flutter test

# 또는 스크립트 사용
bash scripts/run_all_tests.sh
```

### 커버리지 포함 테스트

```bash
# 커버리지 측정 포함
bash scripts/run_tests_with_coverage.sh

# 커버리지 HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### TDD 사이클 헬퍼

```bash
# Red 단계 (실패 확인)
bash scripts/tdd_cycle.sh red

# Green 단계 (전체 테스트 통과 확인)
bash scripts/tdd_cycle.sh green

# Refactor 단계 (동작 불변성 확인)
bash scripts/tdd_cycle.sh refactor
```

---

## 📝 예시: 새 기능 개발

### 요구사항

`UserService`에 이메일 검증 기능 추가

### 1️⃣ Red: 테스트 작성

```dart
// test/unit/services/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/services/user_service.dart';

void main() {
  group('UserService', () {
    group('validateEmail', () {
      test('should return true when valid email provided', () {
        // Arrange
        const email = 'test@example.com';

        // Act
        final result = UserService.validateEmail(email);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when invalid email provided', () {
        // Arrange
        const email = 'invalid-email';

        // Act
        final result = UserService.validateEmail(email);

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
```

**테스트 실행**:

```bash
bash scripts/tdd_cycle.sh red
# ✅ 예상대로 실패 확인
```

---

### 2️⃣ Green: 최소 구현

```dart
// lib/services/user_service.dart
class UserService {
  static bool validateEmail(String email) {
    // 최소 구현: 간단한 정규식
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

**전체 테스트 실행**:

```bash
bash scripts/tdd_cycle.sh green
# ✅ 모든 테스트 통과
# ✅ 사이드 이펙트 없음 확인
```

---

### 3️⃣ Refactor: 코드 개선

```dart
// lib/services/user_service.dart
class UserService {
  // 정규식을 상수로 추출
  static final _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  /// 이메일 유효성 검증
  ///
  /// [email]: 검증할 이메일 주소
  /// Returns: 유효한 이메일이면 true, 아니면 false
  static bool validateEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }
}
```

**전체 테스트 실행**:

```bash
bash scripts/tdd_cycle.sh refactor
# ✅ 리팩터링 전 모든 테스트 통과
# (코드 개선)
# ✅ 리팩터링 후 모든 테스트 통과
# ✅ 동작 불변성 확인
```

---

## 🚫 금지 사항

### ❌ 절대 하지 말 것

1. **테스트 없이 코드 작성**
   - "나중에 테스트 추가할게요" ❌
2. **한 번에 여러 기능 구현**
   - Red → Green 사이클은 작은 단위로
3. **전체 테스트 건너뛰기**
   - "이 변경은 작아서 괜찮을 거예요" ❌
4. **테스트 실패 상태에서 리팩터링**
   - 리팩터링은 초록 상태에서만!

---

## ✅ 완료 정의 (Definition of Done)

모든 작업은 다음 조건을 만족해야 완료로 간주됩니다:

- [ ] Red: 실패하는 테스트가 먼저 작성됨
- [ ] Green: 최소 구현으로 테스트 통과
- [ ] **전체 테스트 실행 결과 모두 통과**
- [ ] **사이드 이펙트 없음 확인** (기존 테스트 모두 통과)
- [ ] Refactor: 코드 개선 완료 (선택사항)
- [ ] **리팩터링 후에도 전체 테스트 통과**
- [ ] 경계/예외 케이스 테스트 포함
- [ ] 커버리지 90% 이상 (핵심 경로)
- [ ] 린트 에러 없음

---

## 📊 커버리지 목표

### 필수

- **핵심 비즈니스 로직**: 90% 이상
- **Services**: 90% 이상
- **Models**: 90% 이상

### 권장

- **Providers**: 80% 이상
- **Utils**: 80% 이상

### 예외

- **UI 위젯**: 위젯 테스트로 검증
- **main.dart**: 통합 테스트로 검증

---

## 🔍 문제 해결

### Q: 테스트 실행이 너무 느려요

```bash
# 특정 테스트만 실행
flutter test test/unit/services/user_service_test.dart

# 변경된 테스트만 실행 (Git)
flutter test $(git diff --name-only --diff-filter=ACMR | grep "_test.dart")
```

### Q: 커버리지를 어떻게 확인하나요?

```bash
# 커버리지 측정
bash scripts/run_tests_with_coverage.sh

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Q: 테스트가 실패했는데 원인을 모르겠어요

```bash
# 상세 출력으로 실행
flutter test --verbose

# 특정 테스트만 디버그
flutter test test/unit/services/user_service_test.dart --verbose
```

---

## 🎓 추가 학습 자료

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [TDD 원칙](https://en.wikipedia.org/wiki/Test-driven_development)
- [Clean Code - Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)

---

## 📝 커밋 메시지 규칙

```
test: Add email validation test for UserService
feat: Implement email validation in UserService
refactor: Extract email regex to constant
```

형식:

- `test:` - 테스트 추가/수정
- `feat:` - 기능 구현
- `refactor:` - 리팩터링
- `fix:` - 버그 수정
- `docs:` - 문서 수정
- `chore:` - 기타 작업

---

**마지막 업데이트**: 2025-10-12  
**작성자**: StrideNote 개발팀  
**적용 범위**: 전체 프로젝트
