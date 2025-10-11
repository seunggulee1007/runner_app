import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'config/app_config.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'services/location_service.dart';
import 'services/database_service.dart';
import 'services/kakao_auth_service.dart';

/// StrideNote 러닝 트래커 앱의 메인 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경 변수 초기화
  await AppConfig.initialize();

  // 2. 환경 변수 검증 (개발 환경에서만)
  if (!AppConfig.validateConfig()) {
    debugPrint('⚠️ 환경 변수 검증 실패. .env 파일을 확인하세요.');
  }

  // 3. 설정 정보 출력 (디버그 모드에서만)
  if (kDebugMode) {
    AppConfig.printConfig();
  }

  // 4. Supabase 초기화
  await SupabaseConfig.initialize();

  // 5. 카카오 SDK 초기화
  await KakaoAuthService.initialize();

  runApp(const StrideNoteApp());
}

/// StrideNote 앱의 루트 위젯
class StrideNoteApp extends StatelessWidget {
  const StrideNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 인증 프로바이더
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        // 위치 서비스 프로바이더
        Provider<LocationService>(create: (_) => LocationService()),
        // 데이터베이스 서비스 프로바이더
        Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'StrideNote',
        debugShowCheckedModeBanner: false,

        // 테마 설정
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // 스플래시 화면
        home: const SplashScreen(),

        // 라우트 설정
        routes: {'/home': (context) => const HomeScreen()},
      ),
    );
  }
}
