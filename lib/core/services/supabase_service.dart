import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for accessing Supabase client throughout the application.
/// This is the only place in the codebase that imports supabase_flutter directly.
class SupabaseService {
  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the Supabase realtime client.
  static RealtimeClient get realtime => client.realtime;
}
