import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'services/location_service.dart';
import 'services/database_service.dart';

/// StrideNote 러닝 트래커 앱의 메인 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await SupabaseConfig.initialize();

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
