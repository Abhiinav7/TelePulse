import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://gsfdepviubuwewgmlvyp.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzZmRlcHZpdWJ1d2V3Z21sdnlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzNzgxNzgsImV4cCI6MjEwNDk1NDE3OH0.IYuseV1fwg5HvoVtazvjqO5kcBjD8lvVbh8Hh2aJ9hc';

  static Future<void> initialize() async {
    // Prevent initialization if keys are not set
    if (url == 'YOUR_SUPABASE_URL') {
      print('WARNING: Supabase URL and Key are not set. Data fetching will fail.');
      return;
    }
    
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
