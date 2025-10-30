# Supabase 데이터베이스 설정 가이드

## 🗄️ 사용자 프로필 테이블 생성

소셜 로그인 및 회원가입으로 가입한 사용자 정보를 저장하기 위해 Supabase에 테이블을 생성해야 합니다.

### 1단계: Supabase Dashboard 접속

1. [Supabase Dashboard](https://supabase.com/dashboard)에 로그인
2. 프로젝트 선택: `YOUR-PROJECT-ID`
3. 좌측 메뉴에서 **SQL Editor** 클릭

### 2단계: SQL 마이그레이션 실행

다음 SQL 코드를 복사하여 SQL Editor에 붙여넣고 실행하세요:

```sql
-- 사용자 프로필 테이블 생성
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    birth_date DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    height INTEGER, -- cm 단위
    weight DECIMAL(5,2), -- kg 단위
    fitness_level TEXT CHECK (fitness_level IN ('beginner', 'intermediate', 'advanced')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 프로필만 조회/수정할 수 있도록 정책 설정
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- updated_at 자동 업데이트를 위한 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_at 트리거 생성
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### 3단계: 테이블 확인

SQL 실행 후 **Table Editor**에서 `user_profiles` 테이블이 생성되었는지 확인하세요.

## 🔐 RLS (Row Level Security) 정책

생성된 테이블은 다음과 같은 보안 정책을 가집니다:

- **SELECT**: 사용자는 자신의 프로필만 조회 가능
- **INSERT**: 사용자는 자신의 프로필만 생성 가능
- **UPDATE**: 사용자는 자신의 프로필만 수정 가능
- **DELETE**: CASCADE로 인해 auth.users 삭제 시 자동 삭제

## 📊 테이블 구조

| 컬럼명        | 타입         | 설명                        | 제약조건                               |
| ------------- | ------------ | --------------------------- | -------------------------------------- |
| id            | UUID         | 사용자 ID (auth.users 참조) | PRIMARY KEY, FOREIGN KEY               |
| email         | TEXT         | 이메일 주소                 | UNIQUE, NOT NULL                       |
| display_name  | TEXT         | 표시 이름                   | -                                      |
| avatar_url    | TEXT         | 프로필 이미지 URL           | -                                      |
| birth_date    | DATE         | 생년월일                    | -                                      |
| gender        | TEXT         | 성별                        | 'male', 'female', 'other'              |
| height        | INTEGER      | 키 (cm)                     | -                                      |
| weight        | DECIMAL(5,2) | 몸무게 (kg)                 | -                                      |
| fitness_level | TEXT         | 체력 수준                   | 'beginner', 'intermediate', 'advanced' |
| created_at    | TIMESTAMP    | 생성일시                    | DEFAULT NOW()                          |
| updated_at    | TIMESTAMP    | 수정일시                    | DEFAULT NOW()                          |

## 🚀 사용 방법

### 이메일 회원가입

```dart
// 회원가입 시 자동으로 user_profiles 테이블에 레코드 생성
await AuthService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  name: '홍길동',
);
```

### Google 로그인

```dart
// Google 로그인 시 자동으로 user_profiles 테이블에 레코드 생성
await AuthService.signInWithGoogle();
```

### 프로필 조회

```dart
// 현재 사용자의 프로필 조회
final profile = await UserProfileService.getCurrentUserProfile();
```

### 프로필 수정

```dart
// 프로필 정보 수정
await UserProfileService.updateUserProfile(
  displayName: '새로운 이름',
  height: 175,
  weight: 70.0,
  fitnessLevel: FitnessLevel.intermediate,
);
```

## 🔍 데이터 확인

Supabase Dashboard의 **Table Editor**에서 `user_profiles` 테이블을 확인하여 사용자 데이터가 올바르게 저장되는지 확인할 수 있습니다.

## ⚠️ 주의사항

1. **RLS 정책**: 모든 사용자는 자신의 데이터만 접근 가능
2. **자동 삭제**: auth.users에서 사용자가 삭제되면 user_profiles도 자동 삭제
3. **데이터 타입**: gender와 fitness_level은 정해진 값만 허용
4. **업데이트 트리거**: updated_at은 자동으로 현재 시간으로 업데이트

---

**이제 소셜 로그인 및 회원가입으로 가입한 모든 사용자 정보가 Supabase의 user_profiles 테이블에 자동으로 저장됩니다!** 🎉
