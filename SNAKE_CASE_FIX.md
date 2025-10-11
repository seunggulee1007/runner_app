# 🔧 Snake Case 필드 매핑 문제 해결

## ❌ 발생했던 문제

```
[UserProfileService] 사용자 프로필 가져오기 오류: type 'Null' is not a subtype of type 'String' in type cast
[UserProfileService] _TypeError (type 'Null' is not a subtype of type 'String' in type cast)
[UserProfileService] #0  _$UserProfileFromJson (package:stride_note/models/user_profile.g.dart:24:47)
```

**스택 트레이스**: `user_profile.g.dart:24` → `createdAt: DateTime.parse(json['createdAt'] as String)`

---

## 🔍 근본 원인

### 필드 네이밍 불일치

| 위치            | 네이밍 규칙      | 예시                         |
| --------------- | ---------------- | ---------------------------- |
| **Dart 모델**   | camelCase        | `createdAt`, `displayName`   |
| **PostgreSQL**  | snake_case       | `created_at`, `display_name` |
| **JSON 직렬화** | camelCase (기본) | `createdAt` (❌ 틀림)        |

### 문제 발생 흐름

```
1. Supabase에서 데이터 조회
   → { "created_at": "2025-01-01", "display_name": "User" }

2. UserProfile.fromJson() 호출
   → json['createdAt']를 찾음
   → null 반환 (실제 키는 'created_at')

3. DateTime.parse(null as String)
   → ❌ type 'Null' is not a subtype of type 'String'
```

---

## ✅ 해결 방법

### 1. **JsonSerializable에 fieldRename 추가**

**파일**: `lib/models/user_profile.dart`

**Before**:

```dart
@JsonSerializable()
class UserProfile {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? displayName;
  final String? avatarUrl;
  // ...
}
```

**After**:

```dart
@JsonSerializable(fieldRename: FieldRename.snake)  // ✅ snake_case 자동 변환
class UserProfile {
  final DateTime createdAt;      // → created_at
  final DateTime updatedAt;      // → updated_at
  final String? displayName;     // → display_name
  final String? avatarUrl;       // → avatar_url
  // ...
}
```

---

### 2. **JSON 직렬화 코드 재생성**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**생성된 코드** (`user_profile.g.dart`):

**Before**:

```dart
UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  createdAt: DateTime.parse(json['createdAt'] as String),  // ❌ 틀림
  updatedAt: DateTime.parse(json['updatedAt'] as String),  // ❌ 틀림
  displayName: json['displayName'] as String?,              // ❌ 틀림
  avatarUrl: json['avatarUrl'] as String?,                  // ❌ 틀림
);
```

**After**:

```dart
UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  createdAt: DateTime.parse(json['created_at'] as String),  // ✅ 맞음
  updatedAt: DateTime.parse(json['updated_at'] as String),  // ✅ 맞음
  displayName: json['display_name'] as String?,             // ✅ 맞음
  avatarUrl: json['avatar_url'] as String?,                 // ✅ 맞음
);
```

---

### 3. **추가 Null 안전 검증**

**파일**: `lib/services/user_profile_service.dart`

```dart
// null 안전 검증: 필수 필드 확인
if (response['id'] == null ||
    response['email'] == null ||
    response['created_at'] == null ||  // ✅ 추가
    response['updated_at'] == null) {  // ✅ 추가
  developer.log(
    '⚠️ 프로필 데이터 불완전: id=${response['id']}, email=${response['email']}, '
    'created_at=${response['created_at']}, updated_at=${response['updated_at']}',
    name: 'UserProfileService',
  );
  return null;
}
```

---

## 📊 Before vs After

### Before (문제 발생)

```json
// Supabase 응답
{
  "id": "xxx",
  "email": "user@example.com",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "display_name": "User",
  "avatar_url": "https://..."
}

// Dart가 찾는 키
json['createdAt']   → null ❌
json['updatedAt']   → null ❌
json['displayName'] → null ❌
json['avatarUrl']   → null ❌

// 결과
DateTime.parse(null as String) → ❌ 타입 오류!
```

### After (해결)

```json
// Supabase 응답 (동일)
{
  "id": "xxx",
  "email": "user@example.com",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "display_name": "User",
  "avatar_url": "https://..."
}

// Dart가 찾는 키 (수정됨)
json['created_at']   → "2025-01-01T00:00:00Z" ✅
json['updated_at']   → "2025-01-01T00:00:00Z" ✅
json['display_name'] → "User" ✅
json['avatar_url']   → "https://..." ✅

// 결과
DateTime.parse("2025-01-01T00:00:00Z") → ✅ 성공!
```

---

## 🧪 테스트 결과

```bash
✅ flutter analyze: No issues found!
✅ flutter test: 9/9 UserProfile tests passed
✅ 모든 코드 컴파일 성공
```

---

## 📝 FieldRename 옵션

`@JsonSerializable`의 `fieldRename` 옵션:

| 옵션                 | 설명                 | 예시                       |
| -------------------- | -------------------- | -------------------------- |
| `FieldRename.none`   | 변환 없음 (기본값)   | `createdAt` → `createdAt`  |
| `FieldRename.snake`  | snake_case로 변환 ✅ | `createdAt` → `created_at` |
| `FieldRename.kebab`  | kebab-case로 변환    | `createdAt` → `created-at` |
| `FieldRename.pascal` | PascalCase로 변환    | `createdAt` → `CreatedAt`  |

**PostgreSQL/Supabase 사용 시**: **`FieldRename.snake` 필수!**

---

## 🔄 다른 모델에도 적용

### running_session.dart

이 모델도 동일한 문제가 있을 수 있습니다!

<function_calls>
<invoke name="read_file">
<parameter name="target_file">/Users/nhn/Desktop/DEV/flutter-workspace/runner_app/lib/models/running_session.dart
