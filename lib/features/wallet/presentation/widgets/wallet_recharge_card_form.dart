import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_colors.dart';
import 'package:thanaweya_online/core/theme/notebook_text.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/qr_scanner_sheet.dart';

class WalletRechargeCardForm extends StatefulWidget {
  final bool isRecharging;
  final ValueChanged<String> onRecharge;

  const WalletRechargeCardForm({
    super.key,
    required this.isRecharging,
    required this.onRecharge,
  });

  @override
  State<WalletRechargeCardForm> createState() => _WalletRechargeCardFormState();
}

class _WalletRechargeCardFormState extends State<WalletRechargeCardForm> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _codeController.text = text.toUpperCase();
      });
    }
  }

  Future<void> _scanQrCode() async {
    HapticFeedback.selectionClick();
    final scanned = await QrScannerSheet.show(context);
    if (scanned != null && scanned.trim().isNotEmpty) {
      final clean = scanned.trim().toUpperCase();
      setState(() {
        _codeController.text = clean;
      });
      HapticFeedback.mediumImpact();
      widget.onRecharge(clean);
    }
  }

  void _submit() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال أو لصق كود كارت الشحن أولاً',
            style: NotebookText.strong(12.sp, color: Colors.white),
          ),
          backgroundColor: NotebookColors.marginRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    _codeController.clear();
    widget.onRecharge(code);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: NotebookColors.rulerCard,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: NotebookColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  color: NotebookColors.green,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'شحن رصيد بكارت السنتر',
                style: NotebookText.strong(14.sp, color: NotebookColors.ink),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'أدخل كود الكارت المطبوع المكون من حروف وأرقام للشحن الفوري',
            style: NotebookText.note(11.sp, color: NotebookColors.pencil),
          ),
          SizedBox(height: 14.h),

          // Card Code Input Field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: NotebookColors.ink,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'مثال: RSLN-8492-9102',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0,
                        color: Colors.black26,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),
                ),
                // Action: Paste
                IconButton(
                  icon: Icon(
                    Icons.content_paste_rounded,
                    color: NotebookColors.ink.withValues(alpha: 0.6),
                    size: 20.r,
                  ),
                  tooltip: 'لصق من الحافظة',
                  onPressed: _pasteFromClipboard,
                ),
                // Action: Scan QR
                IconButton(
                  icon: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: NotebookColors.green,
                    size: 20.r,
                  ),
                  tooltip: 'مسح QR كود',
                  onPressed: _scanQrCode,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: widget.isRecharging ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: NotebookColors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: widget.isRecharging
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 20.r),
                        SizedBox(width: 6.w),
                        Text(
                          'شحن الرصيد الآن',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
