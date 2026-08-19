import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

/// Loads initial student home data and ensures profiles exist in the database.
Future<void> loadStudentHomeData({
  required StudentCoursesCubit cubit,
  required ValueChanged<String> onNameLoaded,
  required bool Function() isMounted,
}) async {
  var user = Supabase.instance.client.auth.currentUser;
  var userId = user?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
  if (userId == null) {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
      if (!isMounted()) return;
      user = Supabase.instance.client.auth.currentUser;
      userId = user?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
      if (userId != null) break;
    }
  }
  if (!isMounted()) return;
  if (user != null) {
    onNameLoaded(user.userMetadata?['full_name']?.toString().split(' ').first ?? 'طالب');
  }
  if (userId != null) {
    await _ensureProfile(userId);
    if (isMounted()) {
      cubit.loadSubscribedTeachers(userId);
      cubit.loadMyCourses(userId);
    }
  }
  if (isMounted()) {
    cubit.loadPopularCourses();
    cubit.loadApprovedTeachers();
    cubit.loadSubjects();
  }
}

Future<void> _ensureProfile(String uid) async {
  try {
    final c = Supabase.instance.client;
    final u = c.auth.currentUser;
    if (u == null) return;
    if (await c.from('users').select('id').eq('id', uid).maybeSingle() == null) {
      await c.from('users').insert({
        'id': uid,
        'email': u.email ?? '',
        'full_name': u.userMetadata?['full_name']?.toString() ?? 'طالب',
        'phone': u.userMetadata?['phone']?.toString() ?? '01000000000',
        'role': u.userMetadata?['role']?.toString() ?? 'student',
      });
    }
    if (await c.from('students').select('id').eq('id', uid).maybeSingle() == null) {
      await c.from('students').insert({
        'id': uid,
        'grade_level': 'first',
        'parent_phone': '01000000000',
      });
    }
  } catch (e) {
    debugPrint('[StudentHome] Profile error: $e');
  }
}
