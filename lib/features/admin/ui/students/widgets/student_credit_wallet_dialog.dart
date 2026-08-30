import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

class StudentCreditWalletDialog extends StatefulWidget {
  final String studentId;
  final String studentName;
  final double currentBalance;
  final ValueChanged<double> onCredited;

  const StudentCreditWalletDialog({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.currentBalance,
    required this.onCredited,
  });

  @override
  State<StudentCreditWalletDialog> createState() => _StudentCreditWalletDialogState();
}

class _StudentCreditWalletDialogState extends State<StudentCreditWalletDialog> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController(text: 'إيداع رصيد من لوحة الإدارة');
  bool _loading = false;
  String? _error;

  static const List<double> _quickAmounts = [50, 100, 150, 200, 500];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _amountCtrl.text.trim();
    final amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      setState(() => _error = 'يرجى إدخال مبلغ صحيح أكبر من صفر');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    HapticFeedback.mediumImpact();
    final repo = AdminStudentsRepo();
    final res = await repo.creditStudentWallet(
      studentId: widget.studentId,
      amount: amount,
      reason: _reasonCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    res.when(
      success: (newBalance) {
        widget.onCredited(newBalance);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ${amount.toStringAsFixed(2)} ج.م لخزنة الطالب بنجاح ✅'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      failure: (msg, _) {
        setState(() => _error = msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        actionsPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF16A34A), size: 22),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شحن خزنة الطالب',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.sp, color: AppColors.textPrimary),
                  ),
                  Text(
                    widget.studentName,
                    style: GoogleFonts.cairo(fontSize: 12.sp, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الرصيد الحالي
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الرصيد الحالي في الخزنة:', style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B))),
                    Text(
                      '${widget.currentBalance.toStringAsFixed(2)} ج.م',
                      style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              Text('اختر مبلغاً سريعاً:', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: _quickAmounts.map((amt) {
                  final isSelected = _amountCtrl.text == amt.toInt().toString();
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _amountCtrl.text = amt.toInt().toString();
                        _error = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        '+${amt.toInt()} ج.م',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 14.h),

              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  labelText: 'المبلغ المراد إضافته (ج.م) *',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                  prefixIcon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF16A34A)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),

              SizedBox(height: 12.h),

              TextField(
                controller: _reasonCtrl,
                style: GoogleFonts.cairo(fontSize: 12.5.sp),
                decoration: InputDecoration(
                  labelText: 'سبب الإيداع / ملاحظة (اختياري)',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                  prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),

              if (_error != null) ...[
                SizedBox(height: 10.h),
                Text(
                  _error!,
                  style: GoogleFonts.cairo(fontSize: 11.5.sp, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? SizedBox(width: 16.r, height: 16.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(
              _loading ? 'جاري الإيداع...' : 'تأكيد الإيداع',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }
}
