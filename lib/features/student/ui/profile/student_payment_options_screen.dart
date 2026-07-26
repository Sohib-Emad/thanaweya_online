import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class StudentPaymentOptionsScreen extends StatefulWidget {
  const StudentPaymentOptionsScreen({super.key});

  @override
  State<StudentPaymentOptionsScreen> createState() =>
      _StudentPaymentOptionsScreenState();
}

class _StudentPaymentOptionsScreenState
    extends State<StudentPaymentOptionsScreen> {
  final List<Map<String, dynamic>> _cards = [
    {
      'name': 'MasterCard الإلكترونية',
      'number': '**** **** **76 3054',
      'brand': 'MasterCard',
      'isConnected': true,
    },
    {
      'name': 'Visa Card الثانوية',
      'number': '**** **** **88 4092',
      'brand': 'Visa',
      'isConnected': true,
    },
    {
      'name': 'محفظة ميزة / فودافون كاش',
      'number': '01012345678',
      'brand': 'Wallet',
      'isConnected': true,
    },
  ];

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
            'خيارات وسائل الدفع (Payment Option)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                physics: const BouncingScrollPhysics(),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: AppColors.studentPrimary.withAlpha(15),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.credit_card_rounded,
                                color: AppColors.studentPrimary,
                                size: 24.r,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card['name'],
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  card['number'],
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Connected Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            'متصل • Connected',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0FA37F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Add New Card Button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(context, AppRouter.studentAddCard);
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
                        'إضافة بطاقة جديدة (Add New Card)',
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
                          Icons.add_rounded,
                          color: const Color(0xFF2563EB),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
