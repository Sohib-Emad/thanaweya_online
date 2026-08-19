import 'package:flutter/material.dart';

/// Status style data for a transaction badge.
class TransactionStatusStyle {
  final String label;
  final Color bg;
  final Color border;
  final Color fg;

  const TransactionStatusStyle({
    required this.label,
    required this.bg,
    required this.border,
    required this.fg,
  });
}

/// Resolves status string to a styled badge configuration.
TransactionStatusStyle resolveStatusStyle(
  String? status, {
  required String pendingLabel,
  required String failedLabel,
  required String paidLabel,
}) {
  final s = (status ?? '').toLowerCase();
  if (s.contains('pending') ||
      s.contains('waiting') ||
      s.contains('قيد')) {
    return TransactionStatusStyle(
      label: pendingLabel,
      bg: const Color(0xFFFEF3C7),
      border: const Color(0xFFFDE68A),
      fg: const Color(0xFFB45309),
    );
  }
  if (s.contains('failed') ||
      s.contains('refunded') ||
      s.contains('فشل') ||
      s.contains('ملغي')) {
    return TransactionStatusStyle(
      label: failedLabel,
      bg: const Color(0xFFFEE2E2),
      border: const Color(0xFFFECACA),
      fg: const Color(0xFFDC2626),
    );
  }
  return TransactionStatusStyle(
    label: paidLabel,
    bg: const Color(0xFFE6F7F2),
    border: const Color(0xFFA7F3D0),
    fg: const Color(0xFF0FA37F),
  );
}
