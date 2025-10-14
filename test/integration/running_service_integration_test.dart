import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stride_note/services/running_service.dart';
import 'package:stride_note/models/running_session.dart';

/// RunningService 테스트
///
/// NOTE: 이 테스트는 실제 Supabase 연결이 필요한 통합 테스트입니다.
/// 테스트 실행 전에 .env 파일에 Supabase 설정이 필요합니다.
void main() {
  // NOTE: 통합 테스트는 shared_preferences 플러그인이 필요하므로
  // 실제 기기나 에뮬레이터에서만 실행 가능합니다.
  // setUpAll(() async {
  //   // .env 파일 로드
  //   await dotenv.load(fileName: '.env');
  //
  //   // Supabase 초기화
  //   await Supabase.initialize(
  //     url: dotenv.env['SUPABASE_URL']!,
  //     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  //   );
  // });
  //
  // tearDownAll(() async {
  //   // Supabase 클린업
  //   await Supabase.instance.dispose();
  // });

  group('RunningService', () {
    late RunningService service;

    setUp(() {
      // 통합 테스트이므로 실제 Supabase 인스턴스 사용
      service = RunningService(Supabase.instance.client);
    });

    group(
      'startSession',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test(
          'should create new running session with in_progress status',
          () async {
            // Arrange
            const userId = 'test-user-id';

            // Act
            final session = await service.startSession(userId: userId);

            // Assert
            expect(session, isA<RunningSession>());
            expect(session.userId, equals(userId));
            expect(session.status, equals(RunningSessionStatus.inProgress));
            expect(session.startTime, isNotNull);
            expect(session.endTime, isNull);
            expect(session.distance, isNull);
            expect(session.duration, isNull);
          },
        );

        test('should set current timestamp as startTime', () async {
          // Arrange
          const userId = 'test-user-id';
          final beforeStart = DateTime.now();

          // Act
          final session = await service.startSession(userId: userId);

          // Assert
          final afterStart = DateTime.now();
          expect(
            session.startTime.isAfter(
              beforeStart.subtract(const Duration(seconds: 1)),
            ),
            isTrue,
          );
          expect(
            session.startTime.isBefore(
              afterStart.add(const Duration(seconds: 1)),
            ),
            isTrue,
          );
        });

        test('should generate unique session ID', () async {
          // Arrange
          const userId = 'test-user-id';

          // Act
          final session1 = await service.startSession(userId: userId);
          final session2 = await service.startSession(userId: userId);

          // Assert
          expect(session1.id, isNot(equals(session2.id)));
          expect(session1.id, isNotEmpty);
          expect(session2.id, isNotEmpty);
        });
      },
    );

    group(
      'endSession',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test('should update session status to completed', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);
          await Future.delayed(const Duration(milliseconds: 100));

          // Act
          final endedSession = await service.endSession(
            sessionId: startedSession.id,
            distance: 5000.0,
            duration: 1800,
          );

          // Assert
          expect(endedSession.status, equals(RunningSessionStatus.completed));
          expect(endedSession.endTime, isNotNull);
          expect(endedSession.distance, equals(5000.0));
          expect(endedSession.duration, equals(1800));
        });

        test('should set endTime to current timestamp', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);
          await Future.delayed(const Duration(milliseconds: 100));
          final beforeEnd = DateTime.now();

          // Act
          final endedSession = await service.endSession(
            sessionId: startedSession.id,
            distance: 5000.0,
            duration: 1800,
          );

          // Assert
          final afterEnd = DateTime.now();
          expect(endedSession.endTime, isNotNull);
          expect(
            endedSession.endTime!.isAfter(
              beforeEnd.subtract(const Duration(seconds: 1)),
            ),
            isTrue,
          );
          expect(
            endedSession.endTime!.isBefore(
              afterEnd.add(const Duration(seconds: 1)),
            ),
            isTrue,
          );
        });

        test('should calculate avgSpeed from distance and duration', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);

          // Act
          final endedSession = await service.endSession(
            sessionId: startedSession.id,
            distance: 5000.0, // 5km
            duration: 1800, // 30분
          );

          // Assert
          // 5000m / 1800s = 2.78 m/s
          // 2.78 m/s * 3.6 = 10 km/h
          expect(endedSession.avgSpeed, isNotNull);
          expect(endedSession.avgSpeed, closeTo(10.0, 0.1));
        });

        test('should throw error when session not found', () async {
          // Arrange
          const invalidSessionId = 'invalid-id';

          // Act & Assert
          expect(
            () => service.endSession(
              sessionId: invalidSessionId,
              distance: 5000.0,
              duration: 1800,
            ),
            throwsA(isA<SessionNotFoundException>()),
          );
        });
      },
    );

    group(
      'pauseSession',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test('should update session status to paused', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);

          // Act
          final pausedSession = await service.pauseSession(
            sessionId: startedSession.id,
          );

          // Assert
          expect(pausedSession.status, equals(RunningSessionStatus.paused));
        });

        test('should throw error when session not found', () async {
          // Arrange
          const invalidSessionId = 'invalid-id';

          // Act & Assert
          expect(
            () => service.pauseSession(sessionId: invalidSessionId),
            throwsA(isA<SessionNotFoundException>()),
          );
        });
      },
    );

    group(
      'resumeSession',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test('should update session status to in_progress', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);
          final pausedSession = await service.pauseSession(
            sessionId: startedSession.id,
          );

          // Act
          final resumedSession = await service.resumeSession(
            sessionId: pausedSession.id,
          );

          // Assert
          expect(
            resumedSession.status,
            equals(RunningSessionStatus.inProgress),
          );
        });

        test('should throw error when session not found', () async {
          // Arrange
          const invalidSessionId = 'invalid-id';

          // Act & Assert
          expect(
            () => service.resumeSession(sessionId: invalidSessionId),
            throwsA(isA<SessionNotFoundException>()),
          );
        });
      },
    );

    group(
      'getSession',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test('should return session by ID', () async {
          // Arrange
          const userId = 'test-user-id';
          final createdSession = await service.startSession(userId: userId);

          // Act
          final retrievedSession = await service.getSession(
            sessionId: createdSession.id,
          );

          // Assert
          expect(retrievedSession, isNotNull);
          expect(retrievedSession!.id, equals(createdSession.id));
          expect(retrievedSession.userId, equals(userId));
        });

        test('should return null when session not found', () async {
          // Arrange
          const invalidSessionId = 'invalid-id';

          // Act
          final retrievedSession = await service.getSession(
            sessionId: invalidSessionId,
          );

          // Assert
          expect(retrievedSession, isNull);
        });
      },
    );

    group(
      'getUserSessions',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test('should return all sessions for user', () async {
          // Arrange
          const userId = 'test-user-id';
          await service.startSession(userId: userId);
          await service.startSession(userId: userId);

          // Act
          final sessions = await service.getUserSessions(userId: userId);

          // Assert
          expect(sessions, hasLength(2));
          expect(sessions.every((s) => s.userId == userId), isTrue);
        });

        test('should return empty list when user has no sessions', () async {
          // Arrange
          const userId = 'test-user-id-no-sessions';

          // Act
          final sessions = await service.getUserSessions(userId: userId);

          // Assert
          expect(sessions, isEmpty);
        });

        test('should return sessions sorted by startTime descending', () async {
          // Arrange
          const userId = 'test-user-id';
          final session1 = await service.startSession(userId: userId);
          await Future.delayed(const Duration(milliseconds: 10));
          final session2 = await service.startSession(userId: userId);
          await Future.delayed(const Duration(milliseconds: 10));
          final session3 = await service.startSession(userId: userId);

          // Act
          final sessions = await service.getUserSessions(userId: userId);

          // Assert
          expect(sessions, hasLength(3));
          expect(sessions[0].id, equals(session3.id)); // 가장 최근
          expect(sessions[1].id, equals(session2.id));
          expect(sessions[2].id, equals(session1.id)); // 가장 오래된
        });
      },
    );

    group(
      'getCurrentSession',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test('should return active session for user', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);

          // Act
          final currentSession = await service.getCurrentSession(
            userId: userId,
          );

          // Assert
          expect(currentSession, isNotNull);
          expect(currentSession!.id, equals(startedSession.id));
          expect(
            currentSession.status,
            equals(RunningSessionStatus.inProgress),
          );
        });

        test('should return null when no active session exists', () async {
          // Arrange
          const userId = 'test-user-id-no-active';

          // Act
          final currentSession = await service.getCurrentSession(
            userId: userId,
          );

          // Assert
          expect(currentSession, isNull);
        });

        test('should return null when only completed sessions exist', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);
          await service.endSession(
            sessionId: startedSession.id,
            distance: 5000.0,
            duration: 1800,
          );

          // Act
          final currentSession = await service.getCurrentSession(
            userId: userId,
          );

          // Assert
          expect(currentSession, isNull);
        });
      },
    );

    group(
      'cancelSession',
      skip: 'Requires device/emulator with shared_preferences plugin',
      () {
        test('should update session status to cancelled', () async {
          // Arrange
          const userId = 'test-user-id';
          final startedSession = await service.startSession(userId: userId);

          // Act
          final cancelledSession = await service.cancelSession(
            sessionId: startedSession.id,
          );

          // Assert
          expect(
            cancelledSession.status,
            equals(RunningSessionStatus.cancelled),
          );
        });

        test('should throw error when session not found', () async {
          // Arrange
          const invalidSessionId = 'invalid-id';

          // Act & Assert
          expect(
            () => service.cancelSession(sessionId: invalidSessionId),
            throwsA(isA<SessionNotFoundException>()),
          );
        });
      },
    );
  });

  group(
    'SessionNotFoundException',
    skip: 'Requires device/emulator with shared_preferences plugin',
    () {
      test('should have descriptive error message', () {
        // Arrange
        const sessionId = 'test-session-id';

        // Act
        final exception = SessionNotFoundException(sessionId);

        // Assert
        expect(exception.toString(), contains('Session not found'));
        expect(exception.toString(), contains(sessionId));
      });
    },
  );
}
