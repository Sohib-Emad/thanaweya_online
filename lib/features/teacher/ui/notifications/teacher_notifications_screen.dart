import 'package:flutter/material.dart';
import 'package:thanaweya_online/features/shared/ui/notifications_screen.dart';

/// Notifications hub for teachers — delegates to the unified Supabase-powered NotificationsScreen.
class TeacherNotificationsScreen extends StatelessWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsScreen();
  }
}
