import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import '../../../../core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'widgets/widgets.dart';

/// Screen listing student payment transactions and receipts.
class StudentTransactionsScreen extends StatefulWidget {
  final bool showBackButton;
  final bool isSelected;

  const StudentTransactionsScreen({
    super.key,
    this.showBackButton = false,
    this.isSelected = false,
  });

  @override
  State<StudentTransactionsScreen> createState() => _StudentTransactionsScreenState();
}

class _StudentTransactionsScreenState extends State<StudentTransactionsScreen> {
  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  static const _palette = [
    Color(0xFF0FA37F), Color(0xFF2563EB), Color(0xFF7C3AED),
    Color(0xFFEA580C), Color(0xFF059669),
  ];

  @override
  void initState() { super.initState(); _loadPayments(); }

  @override
  void didUpdateWidget(covariant StudentTransactionsScreen old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) _loadPayments();
  }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  Future<void> _loadPayments() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) _cubit.loadPayments(userId);
  }

  String _fmtAmt(dynamic a, AppLocalizations l10n) {
    final n = double.tryParse(a?.toString() ?? '') ?? 0;
    final s = n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
    return '$s ${l10n.egpCurrency}';
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    return dt == null ? iso : '${dt.day}/${dt.month}/${dt.year}';
  }

  String _gw(Map<String, dynamic> p, AppLocalizations l10n) {
    final raw = p['payment_gateway'] as String? ?? l10n.electronicPayment;
    final tid = p['gateway_transaction_id'] as String? ?? '';
    if (tid.startsWith('CODE-')) return l10n.teacherActivationCode;
    if (raw.toLowerCase() == 'fawry') return l10n.fawryGateway;
    if (raw.toLowerCase() == 'paymob') return l10n.creditCardGateway;
    return raw;
  }

  String _amt(Map<String, dynamic> p, AppLocalizations l10n) {
    final cm = p['courses'] as Map<String, dynamic>? ?? {};
    final tid = p['gateway_transaction_id'] as String? ?? '';
    final pa = double.tryParse(p['amount']?.toString() ?? '') ?? 0;
    final cp = double.tryParse(cm['price']?.toString() ?? '') ?? 0;
    if (tid.startsWith('CODE-')) {
      if (pa > 0) return _fmtAmt(pa, l10n);
      if (cp > 0) return _fmtAmt(cp, l10n);
      return l10n.freeViaCode;
    }
    return _fmtAmt(p['amount'], l10n);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: context.l10n.transactionsTitle,
          subtitle: context.l10n.transactionsSubtitle,
          automaticallyImplyBack: widget.showBackButton,
          actions: [
            IconButton(icon: Icon(Icons.search_rounded, color: NotebookColors.ink, size: 20.r), onPressed: () {}),
            SizedBox(width: 12.w),
          ],
        ),
        body: TransactionListBody(cubit: _cubit, onRefresh: _loadPayments, cardBuilder: _buildCard),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> payment, int index) {
    final l10n = context.l10n;
    final plan = payment['subscription_plans'] as Map<String, dynamic>? ?? {};
    final cm = payment['courses'] as Map<String, dynamic>? ?? {};
    final title = plan['name'] as String? ?? cm['title'] as String? ?? l10n.courseSubscriptionFallback;
    final gw = _gw(payment, l10n);
    final amt = _amt(payment, l10n);
    final date = _fmtDate(payment['created_at'] as String?);
    final ss = resolveStatusStyle(payment['status'] as String?,
        pendingLabel: l10n.statusPending, failedLabel: l10n.statusFailed, paidLabel: l10n.statusPaid);
    final color = _palette[index % _palette.length];
    final email = Supabase.instance.client.auth.currentUser?.email;
    return TransactionCard(
      color: color, title: title, gateway: gw, amount: amt, date: date, statusStyle: ss,
      onTap: () {
        final args = <String, dynamic>{'id': payment['gateway_transaction_id'] ?? payment['id'] ?? '', 'title': title, 'category': gw, 'price': amt, 'date': date, 'status': ss.label};
        if (email != null && email.isNotEmpty) args['email'] = email;
        Navigator.pushNamed(context, AppRouter.studentEReceipt, arguments: args);
      },
    );
  }
}
