import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/running_session.dart';

/// 러닝 세션 데이터베이스 서비스
///
/// Supabase와의 CRUD 작업을 담당합니다.
class RunningDatabaseService {
  final SupabaseClient _supabase;

  RunningDatabaseService(this._supabase);

  /// 러닝 세션 삽입
  Future<RunningSession> insertSession(RunningSession session) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .insert(session.toJson())
          .select()
          .single();

      return RunningSession.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to insert session', e.toString());
    } catch (e) {
      throw DatabaseException('Failed to insert session', e.toString());
    }
  }

  /// 러닝 세션 업데이트
  Future<RunningSession> updateSession(RunningSession session) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .update(session.toJson())
          .eq('id', session.id)
          .select()
          .single();

      return RunningSession.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to update session', e.toString());
    } catch (e) {
      throw DatabaseException('Failed to update session', e.toString());
    }
  }

  /// 세션 ID로 조회
  Future<RunningSession?> getSessionById(String sessionId) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      return RunningSession.fromJson(data);
    } on PostgrestException catch (e) {
      // PGRST116 = Not found
      if (e.code == 'PGRST116') {
        return null;
      }
      throw DatabaseException('Failed to get session', e.toString());
    } catch (e) {
      throw DatabaseException('Failed to get session', e.toString());
    }
  }

  /// 사용자의 모든 세션 조회 (최신순)
  Future<List<RunningSession>> getUserSessionList(String userId) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: false);

      return (data as List<dynamic>)
          .map((json) => RunningSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to get user sessions', e.toString());
    } catch (e) {
      throw DatabaseException('Failed to get user sessions', e.toString());
    }
  }

  /// 현재 진행 중인 세션 조회
  Future<RunningSession?> getCurrentSession(String userId) async {
    try {
      final data = await _supabase
          .from('running_sessions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'in_progress')
          .maybeSingle();

      if (data == null) return null;

      return RunningSession.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to get current session', e.toString());
    } catch (e) {
      throw DatabaseException('Failed to get current session', e.toString());
    }
  }
}

/// 데이터베이스 작업 실패 시 발생하는 예외
class DatabaseException implements Exception {
  final String message;
  final String originalError;

  DatabaseException(this.message, this.originalError);

  @override
  String toString() => 'DatabaseException: $message\nOriginal: $originalError';
}
