import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static late final SupabaseClient _client;

  static Future<void> init() async {
    const supabaseUrl = 'https://ftkdzltyhxevckibkren.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0a2R6bHR5aHhldmNraWJrcmVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2NDczMDUsImV4cCI6MjA4MzIyMzMwNX0.v6qFTmoxuv4TEEGAdm3jdTPqvrOHuzf0n2Zsst3yknY';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  static SupabaseClient get client => _client;
}
