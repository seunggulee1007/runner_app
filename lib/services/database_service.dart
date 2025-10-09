import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/running_session.dart';
import '../models/user_profile.dart';

/// 로컬 데이터베이스 서비스
/// SQLite를 사용하여 러닝 세션과 사용자 프로필 데이터를 저장
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/stride_note.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 데이터베이스 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    // 사용자 프로필 테이블
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        profile_image_url TEXT,
        birth_date TEXT,
        gender TEXT,
        height REAL,
        weight REAL,
        level TEXT NOT NULL,
        weekly_goal REAL NOT NULL,
        weekly_run_goal INTEGER NOT NULL,
        target_pace REAL,
        preferred_times TEXT NOT NULL,
        preferred_locations TEXT NOT NULL,
        notifications TEXT NOT NULL,
        privacy TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 러닝 세션 테이블
    await db.execute('''
      CREATE TABLE running_sessions (
        id TEXT PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT,
        total_distance REAL NOT NULL,
        total_duration INTEGER NOT NULL,
        average_pace REAL NOT NULL,
        max_speed REAL NOT NULL,
        average_heart_rate INTEGER,
        max_heart_rate INTEGER,
        calories_burned INTEGER,
        elevation_gain REAL,
        elevation_loss REAL,
        gps_points TEXT NOT NULL,
        type TEXT NOT NULL,
        weather TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 러닝 통계 테이블 (성능 최적화용)
    await db.execute('''
      CREATE TABLE running_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        total_distance REAL NOT NULL,
        total_duration INTEGER NOT NULL,
        total_sessions INTEGER NOT NULL,
        average_pace REAL NOT NULL,
        calories_burned INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id)
      )
    ''');

    // 목표 달성 기록 테이블
    await db.execute('''
      CREATE TABLE goal_achievements (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        goal_type TEXT NOT NULL,
        target_value REAL NOT NULL,
        achieved_value REAL NOT NULL,
        achieved_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id)
      )
    ''');
  }

  /// 데이터베이스 업그레이드
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 향후 스키마 변경 시 사용
  }

  // ========== 사용자 프로필 관련 메서드 ==========

  /// 사용자 프로필 저장
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profiles',
      _userProfileToMap(profile),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 사용자 프로필 가져오기
  Future<UserProfile?> getUserProfile(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return _userProfileFromMap(maps.first);
    }
    return null;
  }

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      'user_profiles',
      _userProfileToMap(profile),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // ========== 러닝 세션 관련 메서드 ==========

  /// 러닝 세션 저장
  Future<void> saveRunningSession(RunningSession session) async {
    final db = await database;
    await db.insert(
      'running_sessions',
      _runningSessionToMap(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 러닝 세션 가져오기
  Future<RunningSession?> getRunningSession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'running_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (maps.isNotEmpty) {
      return _runningSessionFromMap(maps.first);
    }
    return null;
  }

  /// 모든 러닝 세션 가져오기
  Future<List<RunningSession>> getAllRunningSessions({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'start_time BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      whereClause = 'start_time >= ?';
      whereArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      whereClause = 'start_time <= ?';
      whereArgs = [endDate.toIso8601String()];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'running_sessions',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'start_time DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => _runningSessionFromMap(map)).toList();
  }

  /// 러닝 세션 업데이트
  Future<void> updateRunningSession(RunningSession session) async {
    final db = await database;
    await db.update(
      'running_sessions',
      _runningSessionToMap(session),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  /// 러닝 세션 삭제
  Future<void> deleteRunningSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'running_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // ========== 통계 관련 메서드 ==========

  /// 주간 통계 가져오기
  Future<Map<String, dynamic>> getWeeklyStats(DateTime weekStart) async {
    final db = await database;
    final weekEnd = weekStart.add(const Duration(days: 7));

    final List<Map<String, dynamic>> maps = await db.query(
      'running_sessions',
      where: 'start_time BETWEEN ? AND ?',
      whereArgs: [weekStart.toIso8601String(), weekEnd.toIso8601String()],
    );

    double totalDistance = 0.0;
    int totalDuration = 0;
    int totalSessions = maps.length;
    double totalCalories = 0.0;
    List<double> paces = [];

    for (final map in maps) {
      totalDistance += map['total_distance'] as double;
      totalDuration += map['total_duration'] as int;
      totalCalories += (map['calories_burned'] as int?) ?? 0;
      paces.add(map['average_pace'] as double);
    }

    final averagePace = paces.isNotEmpty
        ? paces.reduce((a, b) => a + b) / paces.length
        : 0.0;

    return {
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'totalSessions': totalSessions,
      'averagePace': averagePace,
      'totalCalories': totalCalories,
    };
  }

  /// 월간 통계 가져오기
  Future<Map<String, dynamic>> getMonthlyStats(DateTime monthStart) async {
    final db = await database;
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      'running_sessions',
      where: 'start_time BETWEEN ? AND ?',
      whereArgs: [monthStart.toIso8601String(), monthEnd.toIso8601String()],
    );

    double totalDistance = 0.0;
    int totalDuration = 0;
    int totalSessions = maps.length;
    double totalCalories = 0.0;
    List<double> paces = [];

    for (final map in maps) {
      totalDistance += map['total_distance'] as double;
      totalDuration += map['total_duration'] as int;
      totalCalories += (map['calories_burned'] as int?) ?? 0;
      paces.add(map['average_pace'] as double);
    }

    final averagePace = paces.isNotEmpty
        ? paces.reduce((a, b) => a + b) / paces.length
        : 0.0;

    return {
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'totalSessions': totalSessions,
      'averagePace': averagePace,
      'totalCalories': totalCalories,
    };
  }

  // ========== 데이터 변환 메서드 ==========

  /// UserProfile을 Map으로 변환
  Map<String, dynamic> _userProfileToMap(UserProfile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'email': profile.email,
      'profile_image_url': profile.profileImageUrl,
      'birth_date': profile.birthDate?.toIso8601String(),
      'gender': profile.gender?.name,
      'height': profile.height,
      'weight': profile.weight,
      'level': profile.level.name,
      'weekly_goal': profile.weeklyGoal,
      'weekly_run_goal': profile.weeklyRunGoal,
      'target_pace': profile.targetPace,
      'preferred_times': jsonEncode(
        profile.preferredTimes.map((e) => e.name).toList(),
      ),
      'preferred_locations': jsonEncode(profile.preferredLocations),
      'notifications': jsonEncode(profile.notifications.toJson()),
      'privacy': jsonEncode(profile.privacy.toJson()),
      'created_at': profile.createdAt.toIso8601String(),
      'updated_at': profile.updatedAt.toIso8601String(),
    };
  }

  /// Map을 UserProfile로 변환
  UserProfile _userProfileFromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      profileImageUrl: map['profile_image_url'],
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'])
          : null,
      gender: map['gender'] != null
          ? Gender.values.byName(map['gender'])
          : null,
      height: map['height'],
      weight: map['weight'],
      level: RunningLevel.values.byName(map['level']),
      weeklyGoal: map['weekly_goal'],
      weeklyRunGoal: map['weekly_run_goal'],
      targetPace: map['target_pace'],
      preferredTimes: (jsonDecode(map['preferred_times']) as List)
          .map((e) => RunningTime.values.byName(e))
          .toList(),
      preferredLocations: List<String>.from(
        jsonDecode(map['preferred_locations']),
      ),
      notifications: NotificationSettings.fromJson(
        jsonDecode(map['notifications']),
      ),
      privacy: PrivacySettings.fromJson(jsonDecode(map['privacy'])),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// RunningSession을 Map으로 변환
  Map<String, dynamic> _runningSessionToMap(RunningSession session) {
    return {
      'id': session.id,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime?.toIso8601String(),
      'total_distance': session.totalDistance,
      'total_duration': session.totalDuration,
      'average_pace': session.averagePace,
      'max_speed': session.maxSpeed,
      'average_heart_rate': session.averageHeartRate,
      'max_heart_rate': session.maxHeartRate,
      'calories_burned': session.caloriesBurned,
      'elevation_gain': session.elevationGain,
      'elevation_loss': session.elevationLoss,
      'gps_points': jsonEncode(
        session.gpsPoints.map((e) => e.toJson()).toList(),
      ),
      'type': session.type.name,
      'weather': session.weather?.toJson() != null
          ? jsonEncode(session.weather!.toJson())
          : null,
      'notes': session.notes,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Map을 RunningSession으로 변환
  RunningSession _runningSessionFromMap(Map<String, dynamic> map) {
    return RunningSession(
      id: map['id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      totalDistance: map['total_distance'],
      totalDuration: map['total_duration'],
      averagePace: map['average_pace'],
      maxSpeed: map['max_speed'],
      averageHeartRate: map['average_heart_rate'],
      maxHeartRate: map['max_heart_rate'],
      caloriesBurned: map['calories_burned'],
      elevationGain: map['elevation_gain'],
      elevationLoss: map['elevation_loss'],
      gpsPoints: (jsonDecode(map['gps_points']) as List)
          .map((e) => GPSPoint.fromJson(e))
          .toList(),
      type: RunningType.values.byName(map['type']),
      weather: map['weather'] != null
          ? WeatherInfo.fromJson(jsonDecode(map['weather']))
          : null,
      notes: map['notes'],
    );
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
