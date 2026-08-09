import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  // Load environment variables
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  print('Initializing Supabase client...');
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  print('Querying users...');
  try {
    final users = await client.from('users').select('id, email, role, full_name');
    print('Users count: ${users.length}');
    for (var u in users) {
      print('User: ${u['id']} - ${u['email']} - ${u['role']} - ${u['full_name']}');
    }
  } catch (e) {
    print('Error querying users: $e');
  }

  print('\nQuerying students...');
  try {
    final students = await client.from('students').select();
    print('Students: $students');
  } catch (e) {
    print('Error querying students: $e');
  }

  print('\nQuerying subscriptions...');
  try {
    final subs = await client.from('subscriptions').select();
    print('Subscriptions: $subs');
  } catch (e) {
    print('Error querying subscriptions: $e');
  }

  print('\nQuerying payments...');
  try {
    final payments = await client.from('payments').select();
    print('Payments: $payments');
  } catch (e) {
    print('Error querying payments: $e');
  }

  print('\nQuerying exams...');
  try {
    final exams = await client.from('exams').select('id, title, is_published, start_at, end_at');
    print('Exams count: ${exams.length}');
    for (var ex in exams) {
      print('Exam: ${ex['id']} - ${ex['title']} - published: ${ex['is_published']} - start: ${ex['start_at']} - end: ${ex['end_at']}');
    }
  } catch (e) {
    print('Error querying exams: $e');
  }

  exit(0);
}
