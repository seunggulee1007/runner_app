import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/running_session.dart';

/// 러닝 세션 관리 서비스
///
/// Supabase와 연동하여 러닝 세션을 관리합니다.
class RunningService {
  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  RunningService(this._supabase);

  /// 새로운 러닝 세션 시작
  Future<RunningSession> startSession({required String userId}) async {
    try {
      final now = DateTime.now();
      final session = RunningSession(
        id: _uuid.v4(),
        userId: userId,
        startTime: now,
        status: RunningSessionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      );

      final data = await _supabase
          .from('running_sessions')
          .insert(session.toJson())
          .select()
          .single();

      return RunningSession.fromJson(data);
    } catch (e) {
      throw Exception('Failed to start session: $e');
    }
  }

  /// 러닝 세션 종료
  Future<RunningSession> endSession({
    required String sessionId,
    required double distance,
    required int duration,
  }) async {
    try {
      // 기존 세션 조회
      final existingData = await _supabase
          .from('running_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (existingData == null) {
        throw SessionNotFoundException(sessionId);
      }

      final session = RunningSession.fromJson(existingData);
      final now = DateTime.now();

      // 평균 속도 계산 (km/h)
      // distance(m) / duration(s) = m/s
      // m/s * 3.6 = km/h
      final avgSpeed = (distance / duration) * 3.6;

      final updatedSession = session.copyWith(
        endTime: now,
        distance: distance,
        duration: duration,
        avgSpeed: avgSpeed,
        status: RunningSessionStatus.completed,
        updatedAt: now,
      );

      final data = await _supabase
          .from('running_sessions')
          .update(updatedSession.toJson())
          .eq('id', sessionId)
          .select()
          .single();

      return RunningSession.fromJson(data);
    } catch (e) {
      if (e is SessionNotFoundException) rethrow;
      throw Exception('Failed to end session: $e');
    }
  }

  /// 러닝 세션 일시정지
  Future<RunningSession> pauseSession({required String sessionId}) async {
    return _updateSessionStatus(sessionId, RunningSessionStatus.paused);
  }

  /// 러닝 세션 재개
  Future<RunningSession> resumeSession({required String sessionId}) async {
    return _updateSessionStatus(sessionId, RunningSessionStatus.inProgress);
  }

  /// 러닝 세션 취소
  Future<RunningSession> cancelSession({required String sessionId}) async {
    return _updateSessionStatus(sessionId, RunningSessionStatus.cancelled);
  }

  /// 세션 상태 업데이트 (공통 로직)
  Future<RunningSession> _updateSessionStatus(
    String sessionId,
    RunningSessionStatus status,
  ) async {
    try {
      // 기존 세션 조회
      final existingData = await _supabase
          .from('running_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (existingData == null) {
        throw SessionNotFoundException(sessionId);
      }

      final session = RunningSession.fromJson(existingData);
      final updatedSession = session.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      final data = await _supabase
          .from('running_sessions')
          .update(updatedSession.toJson())
          .eq('id', sessionId)
          .select()
          .single();

      return RunningSession.fromJson(data);
    } catch (e) {
      if (e is SessionNotFoundException) rethrow;
      throw Exception('Failed to update session status: $e');
    }
  }

  /// 특정 세션 조회
  Future<RunningSession?> getSession({required String sessionId}) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (data == null) return null;

      return RunningSession.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  /// 사용자의 모든 세션 조회
  Future<List<RunningSession>> getUserSessions({required String userId}) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: false);

      return (data as List<dynamic>)
          .map((json) => RunningSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user sessions: $e');
    }
  }

  /// 현재 진행 중인 세션 조회
  Future<RunningSession?> getCurrentSession({required String userId}) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'in_progress')
          .maybeSingle();

      if (data == null) return null;

      return RunningSession.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get current session: $e');
    }
  }
}

/// 세션을 찾을 수 없을 때 발생하는 예외
class SessionNotFoundException implements Exception {
  final String sessionId;

  SessionNotFoundException(this.sessionId);

  @override
  String toString() => 'Session not found: $sessionId';
}
