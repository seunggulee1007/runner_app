# 🏗️ StrideNote 시스템 아키텍처

## 목차

- [전체 시스템 구조](#전체-시스템-구조)
- [레이어 아키텍처](#레이어-아키텍처)
- [데이터 플로우](#데이터-플로우)
- [프로젝트 구조](#프로젝트-구조)
- [디자인 패턴](#디자인-패턴)
- [상태 관리](#상태-관리)
- [데이터베이스 설계](#데이터베이스-설계)

---

## 전체 시스템 구조

```
┌──────────────────────────────────────────────────────────┐
│                  Flutter App (Client)                     │
│  ┌───────────┐  ┌──────────┐  ┌───────────────────┐      │
│  │  Screens  │  │ Widgets  │  │  Providers        │      │
│  │  (View)   │  │ (UI)     │  │  (State Mgmt)     │      │
│  └─────┬─────┘  └────┬─────┘  └─────────┬─────────┘      │
│        │             │                   │                │
│        └─────────────┴───────────────────┘                │
│                      │                                    │
│              ┌───────▼────────┐                           │
│              │    Services    │  ← Business Logic         │
│              │  (Service Layer)│                          │
│              └───────┬────────┘                           │
│                      │                                    │
│         ┌────────────┼────────────┐                       │
│         │            │            │                       │
│    ┌────▼───┐   ┌───▼───┐   ┌───▼────┐                   │
│    │ Models │   │ Utils │   │ Config │                   │
│    └────────┘   └───────┘   └────────┘                   │
└──────────────────────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   ┌────▼────┐   ┌─────▼─────┐  ┌────▼─────┐
   │Supabase │   │Google APIs│  │HealthKit │
   │(Backend)│   │ - Maps    │  │/GoogleFit│
   │         │   │ - Sign-In │  │          │
   └─────────┘   └───────────┘  └──────────┘
```

### 구성 요소

#### 1. Flutter App (Client)

- **View Layer**: 사용자 인터페이스
- **Provider Layer**: 상태 관리
- **Service Layer**: 비즈니스 로직
- **Model Layer**: 데이터 모델

#### 2. Backend Services

- **Supabase**: 인증, 데이터베이스, 실시간 통신
- **Google APIs**: 지도, 소셜 로그인
- **HealthKit/Google Fit**: 건강 데이터

---

## 레이어 아키텍처

### Service-Provider-View 패턴

```
┌─────────────────────────────────────┐
│   View Layer (Screens/Widgets)     │
│   - HomeScreen                      │  ← UI 렌더링
│   - RunningScreen                   │  ← 사용자 입력 처리
│   - ProfileScreen                   │  ← 화면 전환
└──────────────┬──────────────────────┘
               │ listens to (Consumer/Selector)
               ↓
┌─────────────────────────────────────┐
│   Provider Layer (State Management) │
│   - AuthProvider                    │  ← 상태 관리
│   - (LocationProvider - 계획 중)    │  ← 비즈니스 로직 조율
└──────────────┬──────────────────────┘
               │ calls
               ↓
┌─────────────────────────────────────┐
│   Service Layer (Business Logic)   │
│   - AuthService                     │  ← API 호출
│   - LocationService                 │  ← 데이터 처리
│   - HealthService                   │  ← 외부 서비스 연동
│   - DatabaseService                 │
│   - GoogleAuthService               │
│   - UserProfileService              │
└──────────────┬──────────────────────┘
               │ uses
               ↓
┌─────────────────────────────────────┐
│   Model Layer (Data Models)        │
│   - UserProfile                     │  ← 데이터 구조 정의
│   - RunningSession                  │  ← JSON 직렬화/역직렬화
│   - GPSPoint                        │
└─────────────────────────────────────┘
```

### 각 레이어의 역할

#### View Layer

**책임**: UI 렌더링, 사용자 입력 처리, 화면 전환

```dart
// 예시: HomeScreen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Provider의 상태를 구독하여 UI 업데이트
        final user = authProvider.currentUser;

        return Scaffold(
          body: user != null
            ? HomeContent(user: user)
            : LoginPrompt(),
        );
      },
    );
  }
}
```

**규칙**:

- ✅ Provider를 통해서만 상태 접근
- ✅ Service를 직접 호출하지 않음
- ✅ 비즈니스 로직 포함하지 않음

---

#### Provider Layer

**책임**: 상태 관리, 비즈니스 로직 조율, 리스너 알림

```dart
// 예시: AuthProvider
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  // Getter
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // 로그인 (Service 호출)
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );
      _currentUser = user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**규칙**:

- ✅ ChangeNotifier 상속
- ✅ Service Layer 호출
- ✅ 상태 변경 시 notifyListeners() 호출
- ✅ 비공개 변수 + public getter

---

#### Service Layer

**책임**: API 통신, 데이터 처리, 외부 서비스 연동

```dart
// 예시: AuthService
class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 이메일 로그인
  static Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw Exception('로그인 실패: ${e.message}');
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
```

**규칙**:

- ✅ static 메서드 사용 (상태 없음)
- ✅ 순수 함수로 구현 (부작용 최소화)
- ✅ 에러 핸들링 포함
- ✅ Model 객체 반환

---

#### Model Layer

**책임**: 데이터 구조 정의, JSON 직렬화/역직렬화

```dart
// 예시: UserProfile
@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String fitnessLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.fitnessLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON 직렬화
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
```

**규칙**:

- ✅ 불변 객체 (final 필드)
- ✅ @JsonSerializable 어노테이션
- ✅ fromJson / toJson 메서드
- ✅ 비즈니스 로직 포함하지 않음

---

## 데이터 플로우

### 사용자 액션 → UI 업데이트 플로우

```
1. 사용자 액션 (User Action)
   예: 로그인 버튼 클릭
   ↓
2. View Layer - 이벤트 수신
   예: onPressed: () => authProvider.signIn(email, password)
   ↓
3. Provider Layer - 상태 변경 시작
   예: _isLoading = true; notifyListeners();
   ↓
4. Service Layer - API 호출
   예: AuthService.signInWithEmail(...)
   ↓
5. External Services - 원격 요청
   예: Supabase API 호출
   ↓
6. Service Layer - 응답 수신
   예: return response.user;
   ↓
7. Model Layer - 데이터 변환
   예: User.fromJson(json)
   ↓
8. Provider Layer - 상태 업데이트
   예: _currentUser = user; notifyListeners();
   ↓
9. View Layer - UI 자동 재렌더링
   예: Consumer가 rebuild 트리거
   ↓
10. 사용자에게 결과 표시
    예: 홈 화면으로 이동
```

### 실시간 데이터 스트림 플로우

```
1. Service Layer - 스트림 구독
   예: Geolocator.getPositionStream()
   ↓
2. Service Layer - 데이터 수신
   예: Position 객체 수신
   ↓
3. Service Layer - 데이터 처리
   예: 거리 계산, 버퍼링
   ↓
4. Provider Layer - 상태 업데이트
   예: _totalDistance += distance; notifyListeners();
   ↓
5. View Layer - UI 실시간 업데이트
   예: 러닝 통계 화면 갱신
```

---

## 프로젝트 구조

### 디렉토리 구조

```
lib/
├── config/                     # 앱 설정 및 환경 변수
│   ├── app_config.dart          # 환경 변수 관리 (.env)
│   └── supabase_config.dart     # Supabase 초기화
│
├── constants/                  # 앱 전역 상수
│   ├── app_colors.dart          # 컬러 팔레트
│   └── app_theme.dart           # Material 테마
│
├── models/                     # 데이터 모델
│   ├── user_profile.dart        # 사용자 프로필
│   ├── user_profile.g.dart      # JSON 직렬화 (자동 생성)
│   ├── running_session.dart     # 러닝 세션
│   └── running_session.g.dart
│
├── services/                   # 비즈니스 로직
│   ├── auth_service.dart           # 인증
│   ├── google_auth_service.dart    # Google 로그인
│   ├── user_profile_service.dart   # 프로필 관리
│   ├── location_service.dart       # GPS 추적
│   ├── health_service.dart         # 건강 데이터
│   ├── database_service.dart       # 로컬 DB
│   └── supabase_oauth_validator.dart
│
├── providers/                  # 상태 관리
│   └── auth_provider.dart       # 인증 상태
│
├── screens/                    # UI 화면
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home_screen.dart
│   ├── running_screen.dart
│   ├── history_screen.dart
│   ├── profile_screen.dart
│   └── splash_screen.dart
│
├── widgets/                    # 재사용 위젯
│   ├── running_card.dart
│   ├── running_timer.dart
│   ├── running_stats.dart
│   ├── running_controls.dart
│   ├── running_map.dart
│   ├── stats_summary.dart
│   └── quick_actions.dart
│
├── types/                      # 타입 정의
│   └── supabase_types.dart
│
└── main.dart                   # 앱 진입점

test/                           # 테스트
├── unit/                       # 단위 테스트
│   ├── services/
│   ├── models/
│   └── providers/
├── widget/                     # 위젯 테스트
└── integration/                # 통합 테스트
```

### 파일 명명 규칙

```
파일명: snake_case
├─ user_profile.dart ✅
└─ UserProfile.dart ❌

클래스명: PascalCase
├─ class UserProfile ✅
└─ class user_profile ❌

변수/함수: camelCase
├─ final userName ✅
├─ void getUserProfile() ✅
└─ final user_name ❌

상수: lowerCamelCase (Dart 스타일)
├─ const defaultPadding = 16.0; ✅
└─ const DEFAULT_PADDING = 16.0; ❌
```

---

## 디자인 패턴

### 1. Provider 패턴 (상태 관리)

```dart
// main.dart - Provider 등록
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    Provider(create: (_) => LocationService()),
    Provider(create: (_) => DatabaseService()),
  ],
  child: MaterialApp(...),
)

// 화면에서 사용
// 방법 1: Consumer (전체 위젯 리빌드)
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.currentUser?.email ?? '');
  },
)

// 방법 2: Selector (특정 속성만 구독)
Selector<AuthProvider, String?>(
  selector: (_, provider) => provider.currentUser?.email,
  builder: (_, email, __) => Text(email ?? ''),
)

// 방법 3: Provider.of (리빌드 없이 메서드 호출)
final authProvider = Provider.of<AuthProvider>(
  context,
  listen: false,
);
authProvider.signIn(email, password);
```

**장점**:

- ✅ 간단하고 직관적
- ✅ Flutter 공식 추천
- ✅ 보일러플레이트 적음
- ✅ 테스트 용이

---

### 2. Singleton 패턴

```dart
// 예시: LocationService
class LocationService {
  // Private 생성자
  LocationService._internal();

  // Static 인스턴스
  static final LocationService _instance = LocationService._internal();

  // Factory 생성자
  factory LocationService() {
    return _instance;
  }

  // ... 메서드
}

// 사용
final service1 = LocationService();
final service2 = LocationService();
print(service1 == service2); // true (동일한 인스턴스)
```

**장점**:

- ✅ 전역 상태 관리
- ✅ 리소스 공유 (GPS, 데이터베이스)
- ✅ 메모리 효율적

---

### 3. Factory 패턴

```dart
// 예시: RunningSession
class RunningSession {
  final RunningType type;

  // Factory 생성자
  factory RunningSession.fromJson(Map<String, dynamic> json) {
    return RunningSession(
      type: RunningType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      // ...
    );
  }

  // Named constructor
  RunningSession.free({
    required this.startTime,
    required this.endTime,
  }) : type = RunningType.free;

  RunningSession.interval({
    required this.startTime,
    required this.endTime,
  }) : type = RunningType.interval;
}
```

---

### 4. Stream 패턴 (반응형 프로그래밍)

```dart
// 예시: LocationService
class LocationService {
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  // Stream 노출
  Stream<Position> get positionStream => _positionController.stream;

  // 데이터 추가
  void _onPositionReceived(Position position) {
    _positionController.add(position);
  }

  // 리소스 정리
  void dispose() {
    _positionController.close();
  }
}

// 사용
locationService.positionStream.listen((position) {
  print('위치: ${position.latitude}, ${position.longitude}');
});
```

---

## 상태 관리

### Provider 패턴 상세

#### 1. ChangeNotifier 구현

```dart
class AuthProvider extends ChangeNotifier {
  // Private 상태
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Public getter
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // 초기화
  Future<void> initialize() async {
    _currentUser = Supabase.instance.client.auth.currentUser;
    notifyListeners();
  }

  // 로그인
  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );

      _currentUser = user;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await AuthService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
```

#### 2. Consumer vs Selector

```dart
// Consumer: 전체 Provider가 변경되면 리빌드
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // authProvider의 어떤 속성이 변경되어도 리빌드
    return Text(authProvider.currentUser?.email ?? '로그인 필요');
  },
)

// Selector: 특정 속성만 구독
Selector<AuthProvider, String?>(
  selector: (_, provider) => provider.currentUser?.email,
  builder: (_, email, __) {
    // email이 변경될 때만 리빌드
    return Text(email ?? '로그인 필요');
  },
)
```

**성능 비교**:

- Consumer: 간단하지만 불필요한 리빌드 발생 가능
- Selector: 복잡하지만 최적화된 리빌드

---

## 데이터베이스 설계

### Supabase (PostgreSQL) 스키마

#### 1. user_profiles 테이블

```sql
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  fitness_level TEXT DEFAULT 'beginner',
  birth_date DATE,
  gender TEXT,
  height_cm INTEGER,
  weight_kg NUMERIC(5, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);

-- RLS (Row Level Security)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
ON public.user_profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON public.user_profiles FOR UPDATE
USING (auth.uid() = id);
```

#### 2. running_sessions 테이블

```sql
CREATE TABLE public.running_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  total_distance NUMERIC(10, 2) NOT NULL,  -- meters
  total_duration INTEGER NOT NULL,          -- seconds
  average_pace NUMERIC(5, 2),               -- min/km
  max_speed NUMERIC(5, 2),                  -- km/h
  average_heart_rate INTEGER,
  max_heart_rate INTEGER,
  calories_burned INTEGER,
  elevation_gain NUMERIC(8, 2),             -- meters
  elevation_loss NUMERIC(8, 2),             -- meters
  type TEXT DEFAULT 'free',                 -- free, interval, goal
  gps_points JSONB,                         -- GPS 데이터 배열
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_running_sessions_user_id ON public.running_sessions(user_id);
CREATE INDEX idx_running_sessions_start_time ON public.running_sessions(start_time DESC);

-- RLS
ALTER TABLE public.running_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions"
ON public.running_sessions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions"
ON public.running_sessions FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

#### 3. Trigger: 자동 프로필 생성

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, display_name, avatar_url, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'display_name',
      NEW.raw_user_meta_data->>'full_name',
      SPLIT_PART(NEW.email, '@', 1)
    ),
    NEW.raw_user_meta_data->>'avatar_url',
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### SQLite (로컬 데이터베이스)

```dart
// lib/services/database_service.dart
class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'stride_note.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // running_sessions 테이블
    await db.execute('''
      CREATE TABLE running_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        total_distance REAL NOT NULL,
        total_duration INTEGER NOT NULL,
        gps_points TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Index
    await db.execute('''
      CREATE INDEX idx_sessions_synced
      ON running_sessions(synced)
    ''');
  }
}
```

---

## 의존성 주입

### Provider를 통한 의존성 주입

```dart
// main.dart
MultiProvider(
  providers: [
    // State Management
    ChangeNotifierProvider(create: (_) => AuthProvider()),

    // Services (Singleton)
    Provider(create: (_) => LocationService()),
    Provider(create: (_) => DatabaseService()),
    Provider(create: (_) => HealthService()),
  ],
  child: MaterialApp(...),
)

// 화면에서 사용
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Provider에서 Service 주입받기
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );

    return Scaffold(...);
  }
}
```

**장점**:

- ✅ 테스트 용이 (Mock 주입 가능)
- ✅ 의존성 명확화
- ✅ 느슨한 결합

---

## 에러 처리 전략

### 1. Try-Catch 패턴

```dart
// Service Layer
class AuthService {
  static Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      // Supabase 인증 오류
      throw Exception('인증 실패: ${e.message}');
    } on SocketException catch (e) {
      // 네트워크 오류
      throw Exception('네트워크 연결을 확인해주세요');
    } catch (e) {
      // 기타 오류
      throw Exception('알 수 없는 오류: $e');
    }
  }
}

// Provider Layer
class AuthProvider extends ChangeNotifier {
  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );

      _currentUser = user;
    } catch (e) {
      _errorMessage = e.toString();
      // UI에서 처리하도록 rethrow
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// View Layer
class LoginScreen extends StatelessWidget {
  Future<void> _handleLogin() async {
    try {
      await authProvider.signIn(email, password);
      Navigator.of(context).pushReplacement(...);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
```

### 2. Result 패턴 (계획 중)

```dart
// 성공/실패를 명시적으로 표현
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;
  Result.failure(this.error) : data = null, isSuccess = false;
}

// 사용
Future<Result<User>> signIn(String email, String password) async {
  try {
    final user = await AuthService.signInWithEmail(...);
    return Result.success(user);
  } catch (e) {
    return Result.failure(e.toString());
  }
}
```

---

## 보안 고려사항

### 1. 환경 변수 관리

```dart
// .env (Git에 포함 안 됨)
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...

// app_config.dart
class AppConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
```

### 2. Row Level Security (RLS)

```sql
-- 사용자는 자신의 데이터만 접근 가능
CREATE POLICY "Users can view own profile"
ON public.user_profiles FOR SELECT
USING (auth.uid() = id);
```

### 3. API Key 보호

- ✅ .env 파일 사용
- ✅ .gitignore에 추가
- ✅ 클라이언트에 노출되지 않도록 주의

---

## 성능 최적화

### 1. 위젯 최적화

```dart
// const 생성자 사용
const Text('Hello');  // ✅ 재생성 안 됨
Text('Hello');        // ❌ 매번 재생성

// Selector로 리빌드 최소화
Selector<AuthProvider, String?>(
  selector: (_, provider) => provider.currentUser?.email,
  builder: (_, email, __) => Text(email ?? ''),
)
```

### 2. 이미지 최적화

```dart
// 캐시된 네트워크 이미지
CachedNetworkImage(
  imageUrl: avatarUrl,
  placeholder: (_, __) => CircularProgressIndicator(),
  errorWidget: (_, __, ___) => Icon(Icons.error),
)
```

### 3. 데이터베이스 최적화

```sql
-- Index 추가
CREATE INDEX idx_sessions_user_start
ON running_sessions(user_id, start_time DESC);

-- 쿼리 최적화
SELECT * FROM running_sessions
WHERE user_id = $1
ORDER BY start_time DESC
LIMIT 10;
```

---

## 참고 자료

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Provider 패키지](https://pub.dev/packages/provider)
- [Supabase 문서](https://supabase.com/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

