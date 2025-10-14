import 'package:flutter_test/flutter_test.dart';
import 'package:stride_note/services/running_database_service.dart';

/// RunningDatabaseService 테스트
///
/// TDD 원칙에 따라 작성된 테스트입니다.
///
/// NOTE: 이 테스트들은 실제 Supabase 연결이 필요한 통합 테스트로 작성되었습니다.
/// Supabase의 복잡한 타입 시스템으로 인해 Mock을 사용한 단위 테스트보다
/// 실제 데이터베이스를 사용하는 통합 테스트가 더 실용적입니다.
///
/// 테스트 실행 전 요구사항:
/// 1. Supabase 프로젝트가 설정되어 있어야 함
/// 2. .env 파일에 SUPABASE_URL과 SUPABASE_ANON_KEY가 설정되어 있어야 함
/// 3. running_sessions 테이블이 생성되어 있어야 함
void main() {
  group('RunningDatabaseService - Integration Tests', () {
    // 실제 Supabase 연결이 필요하므로 모든 테스트를 skip
    // CI/CD나 개발 환경에서 필요시 skip을 제거하고 실행

    test(
      'insertSession - should insert session to database',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // final now = DateTime.now();
        // final session = RunningSession(
        //   id: 'test-id',
        //   userId: 'user-id',
        //   startTime: now,
        //   status: RunningSessionStatus.inProgress,
        //   createdAt: now,
        //   updatedAt: now,
        // );

        // Act
        // final result = await service.insertSession(session);

        // Assert
        // expect(result.id, isNotEmpty);
        // expect(result.userId, equals('user-id'));

        // Cleanup
        // await service.deleteSession(result.id);
      },
      skip: 'Requires Supabase connection',
    );

    test(
      'updateSession - should update existing session',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // 먼저 세션 생성
        // final session = await service.insertSession(...);

        // Act
        // final updatedSession = session.copyWith(distance: 5000.0);
        // final result = await service.updateSession(updatedSession);

        // Assert
        // expect(result.distance, equals(5000.0));

        // Cleanup
        // await service.deleteSession(result.id);
      },
      skip: 'Requires Supabase connection',
    );

    test(
      'getSessionById - should return session when found',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // final createdSession = await service.insertSession(...);

        // Act
        // final result = await service.getSessionById(createdSession.id);

        // Assert
        // expect(result, isNotNull);
        // expect(result!.id, equals(createdSession.id));

        // Cleanup
        // await service.deleteSession(createdSession.id);
      },
      skip: 'Requires Supabase connection',
    );

    test(
      'getSessionById - should return null when not found',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // const nonExistentId = 'non-existent-id';

        // Act
        // final result = await service.getSessionById(nonExistentId);

        // Assert
        // expect(result, isNull);
      },
      skip: 'Requires Supabase connection',
    );

    test(
      'getUserSessionList - should return user sessions sorted by start time',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // const userId = 'test-user-id';

        // 여러 세션 생성
        // await service.insertSession(...);
        // await service.insertSession(...);

        // Act
        // final result = await service.getUserSessionList(userId);

        // Assert
        // expect(result, hasLength(greaterThanOrEqualTo(2)));
        // expect(result.every((s) => s.userId == userId), isTrue);

        // Cleanup
        // for (final session in result) {
        //   await service.deleteSession(session.id);
        // }
      },
      skip: 'Requires Supabase connection',
    );

    test(
      'getUserSessionList - should return empty list when no sessions',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // const userId = 'user-with-no-sessions';

        // Act
        // final result = await service.getUserSessionList(userId);

        // Assert
        // expect(result, isEmpty);
      },
      skip: 'Requires Supabase connection',
    );

    test(
      'getCurrentSession - should return active session for user',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // const userId = 'test-user-id';

        // 진행 중인 세션 생성
        // final activeSession = await service.insertSession(...);

        // Act
        // final result = await service.getCurrentSession(userId);

        // Assert
        // expect(result, isNotNull);
        // expect(result!.status, equals(RunningSessionStatus.inProgress));

        // Cleanup
        // await service.deleteSession(activeSession.id);
      },
      skip: 'Requires Supabase connection',
    );

    test(
      'getCurrentSession - should return null when no active session',
      () async {
        // Arrange
        // final service = RunningDatabaseService(Supabase.instance.client);
        // const userId = 'user-with-no-active-session';

        // Act
        // final result = await service.getCurrentSession(userId);

        // Assert
        // expect(result, isNull);
      },
      skip: 'Requires Supabase connection',
    );
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

    test('should preserve original error information', () {
      // Arrange
      const message = 'Database error';
      const originalError = 'Connection timeout';

      // Act
      final exception = DatabaseException(message, originalError);

      // Assert
      expect(exception.toString(), contains(message));
      expect(exception.toString(), contains(originalError));
    });
  });
}
