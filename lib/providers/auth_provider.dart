import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../services/auth_service.dart';

/// 인증 상태 관리 프로바이더
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  /// 초기화
  Future<void> initialize() async {
    _user = AuthService.currentUser;
    _isLoading = false;
    notifyListeners();

    // 인증 상태 변경 리스너 등록
    AuthService.authStateChanges.listen((data) {
      final newUser = data.session?.user;
      final wasLoggedOut = _user != null && newUser == null;
      final wasLoggedIn = _user == null && newUser != null;
      final isUserChanged = _user?.id != newUser?.id;

      developer.log(
        'Auth state changed: ${newUser?.email ?? 'null'}',
        name: 'AuthProvider',
      );
      developer.log(
        'Previous user: ${_user?.email ?? 'null'}',
        name: 'AuthProvider',
      );
      developer.log('Was logged in: $wasLoggedIn', name: 'AuthProvider');
      developer.log('Was logged out: $wasLoggedOut', name: 'AuthProvider');
      developer.log('Is user changed: $isUserChanged', name: 'AuthProvider');

      _user = newUser;
      _isLoading = false;
      notifyListeners();

      // 로그인/로그아웃 상태 로그
      if (wasLoggedIn || (newUser != null && isUserChanged)) {
        developer.log('✅ 로그인 감지: ${newUser.email}', name: 'AuthProvider');
        // 프로필은 GoogleAuthService.signInWithGoogle()에서 자동 처리됨
      } else if (wasLoggedOut) {
        developer.log('🚪 로그아웃 감지', name: 'AuthProvider');
      }
    });
  }

  /// 로그인
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signInWithEmail(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 회원가입
  Future<void> signUp(String email, String password, {String? name}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signOut();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    await AuthService.resetPassword(email);
  }

  /// 프로필 업데이트
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.updateProfile(name: name, avatarUrl: avatarUrl);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google 로그인
  /// 반환값: 로그인 성공 여부 (true: 성공, false: 취소 또는 실패)
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('🟢 AuthProvider: Google 로그인 시작', name: 'AuthProvider');
      final result = await AuthService.signInWithGoogle();
      developer.log(
        '🟢 AuthProvider: Google 로그인 결과: $result',
        name: 'AuthProvider',
      );
      return result;
    } catch (e, stackTrace) {
      developer.log(
        '❌ AuthProvider: Google 로그인 오류: $e',
        name: 'AuthProvider',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google 로그아웃 (임시 비활성화)
  Future<void> signOutGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signOutGoogle();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
