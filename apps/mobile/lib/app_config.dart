import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultSupabaseUrl = 'https://ooryormddgyvgthggnzo.supabase.co';
  static const String _defaultSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vcnlvcm1kZGd5dmd0aGdnbnpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNzQyNzIsImV4cCI6MjA3Mzk1MDI3Mn0.fkqBfcvgYy90HfJWPrqBnNSTCbIzlSN9c0QpE7eYavg';
  static const String _defaultGeminiApiKey = 'AIzaSyC2kPThYyYT3UmKF-6uPEF3qTeSbAmicG8';

  /// Initialize environment variables
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      print('✅ AppConfig: Loaded .env configuration successfully');
    } catch (e) {
      print('⚠️ AppConfig: .env file not found or failed to load ($e), using environment/compile-time defaults');
    }
  }

  /// Supabase project URL
  static String get supabaseUrl {
    if (dotenv.isInitialized && (dotenv.env['SUPABASE_URL']?.isNotEmpty ?? false)) {
      return dotenv.env['SUPABASE_URL']!;
    }
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return _defaultSupabaseUrl;
  }

  /// Supabase Anonymous JWT Key
  static String get supabaseAnonKey {
    if (dotenv.isInitialized && (dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty ?? false)) {
      return dotenv.env['SUPABASE_ANON_KEY']!;
    }
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) return envKey;
    return _defaultSupabaseAnonKey;
  }

  /// Google Gemini AI API Key
  static String get geminiApiKey {
    if (dotenv.isInitialized && (dotenv.env['GEMINI_API_KEY']?.isNotEmpty ?? false)) {
      return dotenv.env['GEMINI_API_KEY']!;
    }
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) return envKey;
    return _defaultGeminiApiKey;
  }
}
