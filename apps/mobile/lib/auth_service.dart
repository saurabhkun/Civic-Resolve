import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();

  // Simple login state - no individual profiles
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  String? get userEmail => _userEmail;

  // Simple login - just admin or regular user
  Future<AuthResult> login(String email, String password) async {
    try {
      // Simple hardcoded authentication - no database needed
      if (email.toLowerCase() == 'admin' && password == 'admin') {
        _isLoggedIn = true;
        _isAdmin = true;
        _userEmail = 'admin@system.com';
        await _saveLoginState();
        return AuthResult.success(
          user: {'email': _userEmail, 'is_admin': true},
          message: 'Admin login successful',
        );
      } else {
        // Any other email/password combination works as regular user
        _isLoggedIn = true;
        _isAdmin = false;
        _userEmail = email;
        await _saveLoginState();
        return AuthResult.success(
          user: {'email': _userEmail, 'is_admin': false},
          message: 'Login successful',
        );
      }
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoggedIn = false;
    _isAdmin = false;
    _userEmail = null;
    await _clearLoginState();
  }

  // Load saved login state
  Future<bool> loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _isAdmin = prefs.getBool('is_admin') ?? false;
      _userEmail = prefs.getString('user_email');
      return _isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  // Save login state
  Future<void> _saveLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', _isLoggedIn);
      await prefs.setBool('is_admin', _isAdmin);
      if (_userEmail != null) {
        await prefs.setString('user_email', _userEmail!);
      }
    } catch (e) {
      print('Error saving login state: $e');
    }
  }

  // Clear login state
  Future<void> _clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('is_admin');
      await prefs.remove('user_email');
    } catch (e) {
      print('Error clearing login state: $e');
    }
  }

  // Validation methods
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;

  AuthResult.success({required this.user, required this.message}) : success = true;
  AuthResult.error(this.message) : success = false, user = null;
}