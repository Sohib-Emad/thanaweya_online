import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves user rows (full_name / email / phone) for the given student ids.
///
/// Prefers `public.users` (returns full profiles once the teacher RLS
/// migration is applied) and falls back to the public `user_profiles`
/// view, which exposes only id/full_name/avatar_url but is always
/// readable by any authenticated user. Used by teacher screens so that
/// student names show up even before the RLS migration is applied.
class StudentUserLookup {
  StudentUserLookup({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Returns a map of user id → user row (id, full_name, email, phone when
  /// available). Empty map when nothing is readable.
  Future<Map<String, Map<String, dynamic>>> forIds(List<String> ids) async {
    if (ids.isEmpty) return const {};

    final result = <String, Map<String, dynamic>>{};
    final missing = List<String>.from(ids);

    // First pass: public.users (full profile — works once the teacher RLS
    // migration is applied).
    try {
      final rows = await _client
          .from('users')
          .select('id, full_name, email, phone, role, avatar_url, plain_password')
          .inFilter('id', ids);
      for (final r in rows) {
        final id = r['id'] as String? ?? '';
        if (id.isEmpty) continue;
        result[id] = r;
        missing.remove(id);
      }
    } catch (_) {
      // users table not readable — rely on the view below
    }

    // Second pass: public.user_profiles view (always readable) for any ids
    // the users table did not return — never drops partial results.
    if (missing.isNotEmpty) {
      try {
        final rows = await _client
            .from('user_profiles')
            .select('id, full_name')
            .inFilter('id', missing);
        for (final r in rows) {
          final id = r['id'] as String? ?? '';
          if (id.isEmpty) continue;
          result[id] = r;
        }
      } catch (_) {
        // view not available either — return what we have
      }
    }

    return result;
  }

  /// Convenience: full name per user id (falls back to [fallback]).
  Future<Map<String, String>> namesFor(List<String> ids,
      {String fallback = 'طالب'}) async {
    final users = await forIds(ids);
    return {
      for (final entry in users.entries)
        entry.key:
            (entry.value['full_name'] as String?)?.trim().isNotEmpty == true
                ? entry.value['full_name'] as String
                : fallback,
    };
  }
}
