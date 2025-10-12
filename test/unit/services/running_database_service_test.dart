import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stride_note/services/running_database_service.dart';
import 'package:stride_note/models/running_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock 클래스 생성을 위한 어노테이션
@GenerateMocks([
  SupabaseClient,
  PostgrestQueryBuilder,
  PostgrestFilterBuilder,
  PostgrestBuilder,
])
import 'running_database_service_test.mocks.dart';

/// RunningDatabaseService 테스트
///
/// Supabase와의 CRUD 작업을 테스트합니다.
void main() {
  group('RunningDatabaseService', () {
    late RunningDatabaseService service;
    late MockSupabaseClient mockSupabase;
    late MockPostgrestQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockQueryBuilder = MockPostgrestQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      service = RunningDatabaseService(mockSupabase);
    });

    group('insertSession', () {
      test('should insert session to database', () async {
        // Arrange
        final now = DateTime.now();
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: now,
          status: RunningSessionStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        );

        final sessionJson = {
          'id': 'test-id',
          'user_id': 'user-id',
          'start_time': now.toIso8601String(),
          'status': 'in_progress',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        // Mock 설정
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => sessionJson);

        // Act
        final result = await service.insertSession(session);

        // Assert
        expect(result.id, equals('test-id'));
        expect(result.userId, equals('user-id'));
        verify(mockSupabase.from('running_sessions')).called(1);
        verify(mockQueryBuilder.insert(any)).called(1);
      });

      test('should throw exception when insert fails', () async {
        // Arrange
        final now = DateTime.now();
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: now,
          createdAt: now,
          updatedAt: now,
        );

        // Mock 설정 - 에러 발생
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.single(),
        ).thenThrow(PostgrestException(message: 'Insert failed', code: '500'));

        // Act & Assert
        expect(
          () => service.insertSession(session),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('updateSession', () {
      test('should update existing session', () async {
        // Arrange
        final now = DateTime.now();
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: now,
          endTime: now,
          distance: 5000.0,
          duration: 1800,
          status: RunningSessionStatus.completed,
          createdAt: now,
          updatedAt: now,
        );

        final sessionJson = {
          'id': 'test-id',
          'user_id': 'user-id',
          'start_time': now.toIso8601String(),
          'end_time': now.toIso8601String(),
          'distance': 5000.0,
          'duration': 1800,
          'status': 'completed',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        // Mock 설정
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => sessionJson);

        // Act
        final result = await service.updateSession(session);

        // Assert
        expect(result.id, equals('test-id'));
        expect(result.distance, equals(5000.0));
        expect(result.duration, equals(1800));
        verify(mockSupabase.from('running_sessions')).called(1);
        verify(mockQueryBuilder.update(any)).called(1);
        verify(mockFilterBuilder.eq('id', 'test-id')).called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        final now = DateTime.now();
        final session = RunningSession(
          id: 'test-id',
          userId: 'user-id',
          startTime: now,
          createdAt: now,
          updatedAt: now,
        );

        // Mock 설정 - 에러 발생
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.single(),
        ).thenThrow(PostgrestException(message: 'Update failed', code: '500'));

        // Act & Assert
        expect(
          () => service.updateSession(session),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getSessionById', () {
      test('should return session when found', () async {
        // Arrange
        final now = DateTime.now();
        const sessionId = 'test-id';

        final sessionJson = {
          'id': 'test-id',
          'user_id': 'user-id',
          'start_time': now.toIso8601String(),
          'status': 'in_progress',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        // Mock 설정
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => sessionJson);

        // Act
        final result = await service.getSessionById(sessionId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('test-id'));
        expect(result.userId, equals('user-id'));
        verify(mockSupabase.from('running_sessions')).called(1);
        verify(mockFilterBuilder.eq('id', sessionId)).called(1);
      });

      test('should return null when session not found', () async {
        // Arrange
        const sessionId = 'non-existent-id';

        // Mock 설정 - 404 에러
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.single(),
        ).thenThrow(PostgrestException(message: 'Not found', code: 'PGRST116'));

        // Act
        final result = await service.getSessionById(sessionId);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception on other database errors', () async {
        // Arrange
        const sessionId = 'test-id';

        // Mock 설정 - 다른 에러
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.single(),
        ).thenThrow(PostgrestException(message: 'Database error', code: '500'));

        // Act & Assert
        expect(
          () => service.getSessionById(sessionId),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getUserSessionList', () {
      test('should return user sessions sorted by start time', () async {
        // Arrange
        const userId = 'user-id';
        final now = DateTime.now();

        final sessionsJson = [
          {
            'id': 'session-1',
            'user_id': userId,
            'start_time': now
                .subtract(const Duration(days: 2))
                .toIso8601String(),
            'status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          {
            'id': 'session-2',
            'user_id': userId,
            'start_time': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'status': 'completed',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
        ];

        // Mock 설정
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', any),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.order('start_time', ascending: false),
        ).thenAnswer((_) async => sessionsJson);

        // Act
        final result = await service.getUserSessionList(userId);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('session-2')); // 더 최근
        expect(result[1].id, equals('session-1'));
        verify(mockSupabase.from('running_sessions')).called(1);
        verify(mockFilterBuilder.eq('user_id', userId)).called(1);
        verify(
          mockFilterBuilder.order('start_time', ascending: false),
        ).called(1);
      });

      test('should return empty list when user has no sessions', () async {
        // Arrange
        const userId = 'user-with-no-sessions';

        // Mock 설정
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', any),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.order('start_time', ascending: false),
        ).thenAnswer((_) async => []);

        // Act
        final result = await service.getUserSessionList(userId);

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception on database error', () async {
        // Arrange
        const userId = 'user-id';

        // Mock 설정 - 에러 발생
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', any),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.order('start_time', ascending: false),
        ).thenThrow(PostgrestException(message: 'Database error', code: '500'));

        // Act & Assert
        expect(
          () => service.getUserSessionList(userId),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getCurrentSession', () {
      test('should return active session for user', () async {
        // Arrange
        const userId = 'user-id';
        final now = DateTime.now();

        final sessionJson = {
          'id': 'active-session',
          'user_id': userId,
          'start_time': now.toIso8601String(),
          'status': 'in_progress',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        // Mock 설정
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', any),
        ).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.maybeSingle(),
        ).thenAnswer((_) async => sessionJson);

        // Act
        final result = await service.getCurrentSession(userId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('active-session'));
        expect(result.status, equals(RunningSessionStatus.inProgress));
        verify(mockFilterBuilder.eq('user_id', userId)).called(1);
        verify(mockFilterBuilder.eq('status', 'in_progress')).called(1);
      });

      test('should return null when no active session', () async {
        // Arrange
        const userId = 'user-id';

        // Mock 설정
        when(
          mockSupabase.from('running_sessions'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', any),
        ).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);

        // Act
        final result = await service.getCurrentSession(userId);

        // Assert
        expect(result, isNull);
      });
    });
  });

  group('DatabaseException', () {
    test('should have descriptive error message', () {
      // Arrange
      const message = 'Insert failed';
      const originalError = 'PostgrestException: Insert failed';

      // Act
      final exception = DatabaseException(message, originalError);

      // Assert
      expect(exception.toString(), contains('Insert failed'));
      expect(exception.message, equals(message));
      expect(exception.originalError, equals(originalError));
    });
  });
}
