import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  String? _userId;
  bool _isAuthenticated = false;

  String? get userId => _userId;
  bool get isAuthenticated => _isAuthenticated;

  Map<String, dynamic>? get currentUser =>
      _userId != null ? {'uid': _userId} : null;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // 임시로 항상 로그인 성공
    _userId = 'local_user';
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    // 임시로 항상 회원가입 성공
    _userId = 'local_user';
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _userId = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    // 임시로 항상 성공
  }

  Future<void> updatePassword(String newPassword) async {
    // Implementation needed
  }

  Future<void> updateEmail(String newEmail) async {
    // Implementation needed
  }

  Future<void> deleteAccount() async {
    // Implementation needed
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    // Implementation needed
  }

  Future<void> register(String email, String password) async {
    // Implementation needed
  }

  Future<void> login(String email, String password) async {
    // Implementation needed
  }

  Future<void> logout() async {
    // Implementation needed
  }
}
