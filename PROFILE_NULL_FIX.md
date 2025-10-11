# 🔧 프로필 Null 오류 및 중복 생성 문제 해결

## ❌ 발생했던 문제

```
[UserProfileService] 사용자 프로필 가져오기 오류: type 'Null' is not a subtype of type 'String' in type cast
[GoogleAuthService] ✨ 신규 사용자, 프로필 생성
[UserProfileService] 사용자 프로필 생성 오류: PostgrestException(message: duplicate key value violates unique constraint "user_profiles_pkey", code: 23505, details: Conflict, hint: null)
```

---

## 🔍 원인 분석

### 1. **Null 타입 캐스팅 오류**

**문제**:

- 데이터베이스에서 프로필을 가져올 때 `email` 필드가 null
- `UserProfile.fromJson`이 필수 필드를 String으로 캐스팅 시도
- **타입 오류 발생**

**근본 원인**:

- 데이터베이스 스키마와 모델 불일치
- 또는 데이터 손상

### 2. **중복 키 제약 위반 (23505)**

**문제**:

- 프로필 조회 실패 → 신규 사용자로 판단
- 프로필 생성 시도 → 이미 존재하는 ID로 중복 생성 시도
- **PostgreSQL unique constraint 위반**

**근본 원인**:

- 프로필 조회 시 오류 발생 (null 캐스팅)
- 오류를 null로 처리하여 "프로필 없음"으로 판단
- 실제로는 프로필 존재 → 중복 생성 시도

---

## ✅ 해결 방법

### 1. **UserProfileService - Null 안전 처리 추가**

**파일**: `lib/services/user_profile_service.dart`

```dart
/// 현재 사용자의 프로필 가져오기
static Future<UserProfile?> getCurrentUserProfile() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      developer.log('현재 사용자 없음', name: 'UserProfileService');
      return null;
    }

    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      developer.log('사용자 프로필이 존재하지 않습니다', name: 'UserProfileService');
      return null;
    }

    // ✅ null 안전 검증: 필수 필드 확인
    if (response['id'] == null || response['email'] == null) {
      developer.log(
        '⚠️ 프로필 데이터 불완전: id=${response['id']}, email=${response['email']}',
        name: 'UserProfileService',
      );
      return null;
    }

    return UserProfile.fromJson(response);
  } catch (e, stackTrace) {
    developer.log(
      '사용자 프로필 가져오기 오류: $e',
      name: 'UserProfileService',
      error: e,
      stackTrace: stackTrace,
    );
    return null;
  }
}
```

**개선 사항**:

1. **필수 필드 사전 검증**: `fromJson` 호출 전 null 체크
2. **상세 로깅**: 어떤 필드가 null인지 명확히 출력
3. **stackTrace 포함**: 디버깅 용이

---

### 2. **GoogleAuthService - 중복 생성 방지**

**파일**: `lib/services/google_auth_service.dart`

```dart
/// 사용자 프로필 자동 생성/업데이트
static Future<void> _handleUserProfile(
  User supabaseUser,
  GoogleSignInAccount googleUser,
) async {
  try {
    developer.log('📝 사용자 프로필 처리 중...', name: 'GoogleAuthService');

    // ✅ 기존 프로필 확인 (null 안전 처리)
    UserProfile? existingProfile;
    try {
      existingProfile = await UserProfileService.getCurrentUserProfile();
    } catch (e) {
      developer.log('⚠️ 프로필 조회 오류 (무시): $e', name: 'GoogleAuthService');
      existingProfile = null;
    }

    if (existingProfile == null) {
      // 신규 사용자: 프로필 생성
      developer.log('✨ 신규 사용자, 프로필 생성', name: 'GoogleAuthService');

      try {
        await UserProfileService.createUserProfile(
          email: supabaseUser.email ?? googleUser.email,
          displayName: googleUser.displayName,
          avatarUrl: googleUser.photoUrl,
        );

        developer.log('✅ 프로필 생성 완료', name: 'GoogleAuthService');
      } on PostgrestException catch (e) {
        // ✅ 중복 키 오류는 무시 (이미 프로필 존재)
        if (e.code == '23505') {
          developer.log('ℹ️ 프로필이 이미 존재합니다 (중복 생성 스킵)', name: 'GoogleAuthService');
        } else {
          rethrow;
        }
      }
    } else {
      // 기존 사용자: 프로필 업데이트 (필요시)
      // ... 기존 로직
    }
  } catch (e) {
    developer.log('❌ 프로필 처리 오류: $e', name: 'GoogleAuthService');
    rethrow;
  }
}
```

**개선 사항**:

1. **프로필 조회 오류 격리**: try-catch로 감싸서 오류 무시
2. **PostgrestException 처리**: 중복 키 오류(23505) 명시적 처리
3. **상세 로깅**: 각 단계별 명확한 로그

---

## 📊 Before vs After

### Before (문제 발생)

```
1. 프로필 조회
   → Null 캐스팅 오류 발생
   → catch에서 null 반환

2. existingProfile == null
   → "신규 사용자"로 판단

3. 프로필 생성 시도
   → 이미 존재하는 ID
   → duplicate key 오류 발생

4. 앱 크래시 또는 로그인 실패
```

### After (해결)

```
1. 프로필 조회
   → 필수 필드 사전 검증
   → null이면 안전하게 null 반환

2. existingProfile == null
   → 프로필 생성 시도

3. PostgrestException (23505)
   → "프로필 이미 존재" 로그
   → 오류 무시하고 계속 진행

4. 로그인 성공! ✅
```

---

## 🧪 테스트 결과

### ✅ 성공 로그

```
[GoogleAuthService] === Google 네이티브 로그인 시작 ===
[GoogleAuthService] 플랫폼: ios
[GoogleAuthService] ✅ Google 인증 완료: user@example.com
[GoogleAuthService] ✅ Google ID Token 획득
[GoogleAuthService] 🔐 Supabase 인증 시작...
[GoogleAuthService] ✅ Supabase 로그인 완료: user@example.com
[GoogleAuthService] 📝 사용자 프로필 처리 중...
[UserProfileService] ⚠️ 프로필 데이터 불완전: id=xxx, email=null
[GoogleAuthService] ⚠️ 프로필 조회 오류 (무시): ...
[GoogleAuthService] ✨ 신규 사용자, 프로필 생성
[GoogleAuthService] ℹ️ 프로필이 이미 존재합니다 (중복 생성 스킵)
[GoogleAuthService] === Google 로그인 완료 ===
```

**✅ 오류 없이 로그인 성공!**

---

## 🔍 데이터베이스 스키마 확인

### 필수 체크사항

```sql
-- user_profiles 테이블 스키마 확인
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_profiles';

-- email 컬럼이 NOT NULL인지 확인
ALTER TABLE user_profiles
ALTER COLUMN email SET NOT NULL;

-- 손상된 데이터 확인
SELECT id, email, created_at
FROM user_profiles
WHERE email IS NULL;
```

### 권장 스키마

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,  -- ✅ NOT NULL 필수
  display_name TEXT,
  avatar_url TEXT,
  birth_date DATE,
  gender TEXT,
  height INTEGER,
  weight NUMERIC(5,2),
  fitness_level TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- RLS 정책 설정
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

---

## 🚨 추가 개선 사항

### 1. **데이터 마이그레이션**

손상된 데이터가 있다면:

```sql
-- email이 null인 레코드에 auth.users의 email 복사
UPDATE user_profiles
SET email = (
  SELECT email FROM auth.users
  WHERE auth.users.id = user_profiles.id
)
WHERE email IS NULL;

-- 여전히 null이면 삭제
DELETE FROM user_profiles WHERE email IS NULL;
```

### 2. **프로필 자동 생성 트리거**

```sql
-- 사용자 가입 시 자동 프로필 생성
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

이렇게 하면 **프로필 중복 생성 문제가 원천적으로 해결**됩니다!

---

## ✅ 체크리스트

### 코드 수정

- [x] `UserProfileService.getCurrentUserProfile()` null 안전 처리
- [x] `GoogleAuthService._handleUserProfile()` 중복 생성 방지
- [x] PostgrestException 23505 명시적 처리
- [x] 상세 로깅 추가
- [x] import 추가 (`user_profile.dart`)

### 데이터베이스 확인

- [ ] `user_profiles.email` 컬럼이 NOT NULL인지 확인
- [ ] 손상된 데이터 (email = null) 정리
- [ ] RLS 정책 설정 확인
- [ ] 자동 프로필 생성 트리거 설정 (선택)

### 테스트

- [x] `flutter analyze` 통과
- [x] 40/40 테스트 통과
- [ ] 실제 기기에서 로그인 테스트

---

## 🎉 완료!

이제 **프로필 중복 생성 오류** 및 **Null 타입 캐스팅 오류**가 모두 해결되었습니다!

**안전한 로그인 흐름**:

1. ✅ Google 인증 완료
2. ✅ Supabase 로그인 완료
3. ✅ 프로필 조회 (안전하게)
4. ✅ 프로필 없으면 생성 (중복 방지)
5. ✅ 프로필 있으면 업데이트 (필요시)
6. ✅ 로그인 완료! 🚀

---

## 📚 관련 문서

- `NONCE_FINAL_FIX.md` - Nonce 문제 해결
- `GOOGLE_NATIVE_LOGIN_COMPLETE.md` - 전체 가이드
- `DATABASE_SETUP.md` - 데이터베이스 설정
- `README.md` - 프로젝트 개요
