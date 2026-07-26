import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientHelper {
  SupabaseClientHelper._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => auth.currentUser;

  static String? get userId => currentUser?.id;

  static bool get isAuthenticated => currentUser != null;
}
