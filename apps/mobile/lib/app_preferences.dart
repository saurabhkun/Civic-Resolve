import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';
  static const String _userRoleKey = 'user_role';
  static const String _userProfileKey = 'user_profile_data';
  
  static AppPreferences? _instance;
  SharedPreferences? _prefs;
  
  AppPreferences._();
  
  static AppPreferences get instance {
    _instance ??= AppPreferences._();
    return _instance!;
  }
  
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // Check if user has seen onboarding/welcome screens
  Future<bool> hasSeenOnboarding() async {
    await _initPrefs();
    return _prefs!.getBool(_hasSeenOnboardingKey) ?? false;
  }
  
  Future<bool> hasSeenWelcome() async {
    await _initPrefs();
    return _prefs!.getBool(_hasSeenWelcomeKey) ?? false;
  }
  
  // Mark onboarding/welcome as seen
  Future<void> setOnboardingSeen() async {
    await _initPrefs();
    await _prefs!.setBool(_hasSeenOnboardingKey, true);
  }
  
  Future<void> setWelcomeSeen() async {
    await _initPrefs();
    await _prefs!.setBool(_hasSeenWelcomeKey, true);
  }
  
  // User Role Management (Citizen vs Contractor)
  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role.toLowerCase().trim());
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> clearUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userRoleKey);
  }

  // User Profile Persistence
  static Future<void> setUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }

  // Reset onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    await _initPrefs();
    await _prefs!.setBool(_hasSeenOnboardingKey, false);
    await _prefs!.setBool(_hasSeenWelcomeKey, false);
  }
}