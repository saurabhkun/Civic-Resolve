import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';
  
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
  
  // Reset onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    await _initPrefs();
    await _prefs!.setBool(_hasSeenOnboardingKey, false);
    await _prefs!.setBool(_hasSeenWelcomeKey, false);
  }
}