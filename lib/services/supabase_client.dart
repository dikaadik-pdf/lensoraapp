import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static late final SupabaseClient _client;

  static Future<void> init() async {
    const supabaseUrl = 'https://ngjgywsshvnehvcrhwgy.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5namd5d3NzaHZuZWh2Y3Jod2d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjkxNTcsImV4cCI6MjA3ODUwNTE1N30.NesUa-XtdauF1caoCQen2_75_evz51WLcdcvf3X66c8';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  static SupabaseClient get client => _client;
}
