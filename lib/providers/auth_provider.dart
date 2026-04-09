import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;
  String? _userIcon;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userIcon => _userIcon;

  Future<bool> login(String email, String password) async {
    // Mock login logic - requiring specific credentials
    await Future.delayed(const Duration(seconds: 2));
    
    if (email == 'admin' && password == 'atss19') {
      _isAuthenticated = true;
      _userName = 'Komutan';
      _userIcon = '⚡';
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _userName = null;
    _userIcon = null;
    notifyListeners();
  }
}
