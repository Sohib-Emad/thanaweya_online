import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a', 'ar').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a', 'ar').format(date);
  }

  static String formatNumber(int number) {
    return NumberFormat.decimalPattern('ar').format(number);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'ar', symbol: 'ج.م').format(amount);
  }

  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String formatDurationMinutes(int minutes) {
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours ساعة';
    return '$hours ساعة و $remainingMinutes دقيقة';
  }

  static String timeAgo(DateTime date) {
    final local = date.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 2) return 'أمس';
    if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
    return formatDate(local);
  }
}
