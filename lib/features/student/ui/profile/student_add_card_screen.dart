import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

import '../../../../core/theme/notebook_theme.dart';

class StudentAddCardScreen extends StatefulWidget {
  const StudentAddCardScreen({super.key});

  @override
  State<StudentAddCardScreen> createState() => _StudentAddCardScreenState();
}

class _StudentAddCardScreenState extends State<StudentAddCardScreen> {
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  @override
  void dispose() {
    _cubit.close();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _detectBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'MasterCard';
    return 'Card';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveCard() async {
    final cardHolder = _cardNameController.text.trim();
    final cardNumber = _cardNumberController.text
        .replaceAll(' ', '')
        .replaceAll('-', '');
    final expiry = _expiryController.text.trim();

    if (cardHolder.isEmpty) {
      _showSnack('يرجى إدخال اسم صاحب البطاقة');
      return;
    }
    if (cardNumber.length < 4) {
      _showSnack('يرجى إدخال رقم بطاقة صحيح');
      return;
    }

    final parts = expiry.split('/');
    int? expiryMonth;
    int? expiryYear;
    if (parts.length == 2) {
      expiryMonth = int.tryParse(parts[0].trim());
      final yy = int.tryParse(parts[1].trim());
      if (yy != null) expiryYear = 2000 + yy;
    }
    if (expiryMonth == null || expiryYear == null) {
      _showSnack('يرجى إدخال تاريخ انتهاء صحيح (MM/YY)');
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showSnack('يجب تسجيل الدخول أولاً');
      return;
    }

    final cardLast4 = cardNumber.substring(cardNumber.length - 4);
    final saved = await _cubit.addPaymentMethod(
      studentId: userId,
      cardHolder: cardHolder,
      cardLast4: cardLast4,
      cardBrand: _detectBrand(cardNumber),
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
    );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إضافة البطاقة بنجاح',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: NotebookColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      _showSnack('حدث خطأ أثناء إضافة البطاقة، حاول مرة أخرى');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'إضافة بطاقة جديدة',
          subtitle: 'سجّل وسيلة دفع جديدة في دفترك',
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotebookSectionHeader(title: 'بيانات البطاقة'),
                SizedBox(height: 12.h),

                NotebookCard(
                  ruled: true,
                  ruledStartY: 20,
                  borderRadius: 12,
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(
                        label: 'اسم صاحب البطاقة *',
                        controller: _cardNameController,
                        hint: 'أدخل الاسم المطبوع على البطاقة',
                        onChanged: (val) => setState(() {}),
                      ),
                      SizedBox(height: 18.h),

                      _buildField(
                        label: 'رقم البطاقة *',
                        controller: _cardNumberController,
                        hint: '•••• •••• •••• ••••',
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() {}),
                      ),
                      SizedBox(height: 18.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildField(
                              label: 'تاريخ الانتهاء *',
                              controller: _expiryController,
                              hint: 'MM/YY',
                              keyboardType: TextInputType.datetime,
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildField(
                              label: 'رمز الأمان *',
                              controller: _cvvController,
                              hint: '•••',
                              keyboardType: TextInputType.number,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                NotebookPrimaryButton(
                  label: 'إضافة البطاقة',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _saveCard();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NotebookText.strong(12.sp)),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: NotebookText.body(13.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: NotebookText.note(12.sp)
                .copyWith(color: NotebookColors.pencil.withAlpha(180)),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6.h),
          ),
        ),
        Container(
          height: 1.4,
          color: NotebookColors.ink.withAlpha(70),
        ),
      ],
    );
  }
}
