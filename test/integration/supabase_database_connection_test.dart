import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stride_note/config/app_config.dart';
import 'package:stride_note/config/supabase_config.dart';

/// Supabase 데이터베이스 연결 통합 테스트
void main() {
  group('Supabase Database Integration', () {
    // NOTE: 통합 테스트는 shared_preferences 플러그인이 필요하므로
    // 실제 기기나 에뮬레이터에서만 실행 가능합니다.
    // late SupabaseClient client;
    //
    // setUpAll(() async {
    //   // AppConfig 초기화
    //   await AppConfig.initialize();
    //   // Supabase 초기화
    //   await SupabaseConfig.initialize();
    //   client = SupabaseConfig.client;
    // });

    test(
      'should connect to database and verify user_profiles table exists',
      () async {
        // NOTE: This test is skipped due to shared_preferences plugin requirement
        // Uncomment when running on device/emulator
        //
        // // Arrange & Act
        // final response = await client
        //     .from('user_profiles')
        //     .select('count')
        //     .limit(1);
        //
        // // Assert
        // expect(response, isNotNull);
        // expect(response, isA<List>());
      },
      skip: 'Requires device/emulator with shared_preferences plugin',
    );

    test(
      'should be able to query table structure',
      () async {
        // NOTE: This test is skipped due to shared_preferences plugin requirement
        // Uncomment when running on device/emulator
        //
        // // Arrange & Act
        // final response = await client.from('user_profiles').select('*').limit(0);
        //
        // // Assert
        // expect(response, isNotNull);
        // expect(response, isA<List>());
        // expect(response.length, equals(0)); // 빈 테이블이므로 0개 행
      },
      skip: 'Requires device/emulator with shared_preferences plugin',
    );

    test(
      'should have proper RLS policies enabled',
      () async {
        // NOTE: This test is skipped due to shared_preferences plugin requirement
        // Uncomment when running on device/emulator
        //
        // // Arrange & Act
        // // RLS가 활성화되어 있으면 인증되지 않은 사용자는 데이터를 볼 수 없어야 함
        // try {
        //   final response = await client.from('user_profiles').select('*');
        //
        //   // RLS가 제대로 작동하면 빈 결과를 반환해야 함
        //   expect(response, isA<List>());
        // } catch (e) {
        //   // RLS로 인한 오류도 예상되는 결과
        //   expect(e, isA<Exception>());
        // }
      },
      skip: 'Requires device/emulator with shared_preferences plugin',
    );
  });
}
