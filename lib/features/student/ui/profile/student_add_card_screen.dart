import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

import '../../../../core/constants/app_colors.dart';

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
            'تمت إضافة البطاقة بنجاح 💳',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.studentPrimary,
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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'إضافة بطاقة جديدة (Add New Card)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Blue Wave Credit Card Graphic Preview (Matching Screen 54)
              Container(
                width: double.infinity,
                height: 190.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332563EB),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative Wave Lines
                    Positioned(
                      top: -20,
                      left: -20,
                      child: Container(
                        width: 140.r,
                        height: 140.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(20),
                        ),
                      ),
                    ),

                    // Card Info Content
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.sim_card_rounded,
                                color: const Color(0xFFFBBF24),
                                size: 36.r,
                              ),
                              Text(
                                'VISA / MasterCard',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                            ],
                          ),

                          Text(
                            _cardNumberController.text.isEmpty
                                ? '**** **** **** ****'
                                : _cardNumberController.text,
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'صاحب البطاقة (CARD HOLDER)',
                                    style: GoogleFonts.cairo(
                                      fontSize: 9.sp,
                                      color: Colors.white.withAlpha(180),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _cardNameController.text.toUpperCase(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'VALID THRU',
                                    style: GoogleFonts.cairo(
                                      fontSize: 9.sp,
                                      color: Colors.white.withAlpha(180),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _expiryController.text,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Form Inputs
              _buildField(
                label: 'اسم صاحب البطاقة (Card Name)*',
                controller: _cardNameController,
                hint: 'أدخل الاسم المطبوع على البطاقة',
                onChanged: (val) => setState(() {}),
              ),

              SizedBox(height: 16.h),

              _buildField(
                label: 'رقم البطاقة (Card Number)*',
                controller: _cardNumberController,
                hint: '**** **** **** ****',
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() {}),
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: 'تاريخ الانتهاء (Expiry Date)*',
                      controller: _expiryController,
                      hint: 'MM/YY',
                      keyboardType: TextInputType.datetime,
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildField(
                      label: 'رمز الأمان (CVV)*',
                      controller: _cvvController,
                      hint: '***',
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Bottom Add Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _saveCard();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 4,
                    shadowColor: const Color(0x332563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'إضافة البطاقة (Add New Card)',
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 34.r,
                        height: 34.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: const Color(0xFF2563EB),
                          size: 18.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
