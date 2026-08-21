import 'package:flutter/material.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Normalizes Arabic text for flexible, error-tolerant searching.
String _normalizeArabic(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Remove Tashkeel
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(RegExp(r'[\s\-_]+'), ' ');
}

/// Normalizes phone numbers for matching with or without country code.
String _cleanPhone(String phone) {
  var digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.startsWith('20') && digits.length > 10) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return digits;
}

/// Normalizes a grade level value to standard keys: 'first', 'second', 'third'.
String _normalizeGradeKey(String raw) {
  final clean = _normalizeArabic(raw);
  if (clean.contains('اول') || clean.contains('first') || clean == '1' || clean == '1st') {
    return 'first';
  }
  if (clean.contains('ثاني') || clean.contains('second') || clean == '2' || clean == '2nd') {
    return 'second';
  }
  if (clean.contains('ثالث') || clean.contains('third') || clean == '3' || clean == '3rd') {
    return 'third';
  }
  return raw.trim().toLowerCase();
}

/// Filters a student list by search query and grade level flexibly and reliably.
List<Map<String, dynamic>> filterStudents({
  required List<Map<String, dynamic>> students,
  required String searchQuery,
  required String gradeFilter,
}) {
  final q = _normalizeArabic(searchQuery);
  final qPhone = _cleanPhone(searchQuery);
  final targetGrade = _normalizeGradeKey(gradeFilter);

  return students.where((s) {
    final user = s['users'] as Map<String, dynamic>? ?? {};
    final meta = s['students'] as Map<String, dynamic>? ?? {};

    final name = _normalizeArabic(user['full_name'] as String? ?? s['name'] as String? ?? '');
    final email = (user['email'] as String? ?? s['email'] as String? ?? '').toLowerCase();
    final rawPhone = user['phone'] as String? ?? s['phone'] as String? ?? '';
    final rawParentPhone = meta['parent_phone'] as String? ?? s['parent_phone'] as String? ?? '';
    final studentPhone = _cleanPhone(rawPhone);
    final parentPhone = _cleanPhone(rawParentPhone);

    final rawGrade = meta['grade_level'] as String? ?? s['grade_level'] as String? ?? '';
    final studentGrade = _normalizeGradeKey(rawGrade);

    // Search query matching
    final matchesQuery = q.isEmpty ||
        name.contains(q) ||
        email.contains(q) ||
        (qPhone.isNotEmpty && (studentPhone.contains(qPhone) || parentPhone.contains(qPhone))) ||
        rawPhone.contains(searchQuery.trim()) ||
        rawParentPhone.contains(searchQuery.trim());

    // Grade filter matching
    final matchesGrade = targetGrade.isEmpty ||
        studentGrade == targetGrade ||
        rawGrade.toLowerCase() == targetGrade;

    return matchesQuery && matchesGrade;
  }).toList();
}

/// Empty-state widget used when no students match.
class StudentsEmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StudentsEmptyState({
    super.key,
    required this.message,
    this.subMessage,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DeskEmptyNote(
        message: message,
        subMessage: subMessage,
        icon: icon,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
