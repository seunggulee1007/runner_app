import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      _user = data.session?.user;
      _isLoading = false;
      notifyListeners();
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

  /// Google 로그인 (임시 비활성화)
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signInWithGoogle();
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
