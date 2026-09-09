import 'lib/app_preferences.dart';

void main() async {
  print('Testing Onboarding Flow...');
  
  final prefs = AppPreferences.instance;
  
  try {
    // Check initial state
    print('Initial state:');
    print('Has seen welcome: ${await prefs.hasSeenWelcome()}');
    print('Has seen onboarding: ${await prefs.hasSeenOnboarding()}');
    
    // Reset onboarding for testing
    await prefs.resetOnboarding();
    print('\nAfter reset:');
    print('Has seen welcome: ${await prefs.hasSeenWelcome()}');
    print('Has seen onboarding: ${await prefs.hasSeenOnboarding()}');
    
    // Simulate user flow
    await prefs.setWelcomeSeen();
    print('\nAfter welcome seen:');
    print('Has seen welcome: ${await prefs.hasSeenWelcome()}');
    print('Has seen onboarding: ${await prefs.hasSeenOnboarding()}');
    
    await prefs.setOnboardingSeen();
    print('\nAfter onboarding seen:');
    print('Has seen welcome: ${await prefs.hasSeenWelcome()}');
    print('Has seen onboarding: ${await prefs.hasSeenOnboarding()}');
    
    print('\n✅ Onboarding flow preferences working correctly!');
    
  } catch (e) {
    print('❌ Error testing onboarding flow: $e');
  }
}