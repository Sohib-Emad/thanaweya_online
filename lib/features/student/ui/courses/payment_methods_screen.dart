import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedMethodIndex = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'انستا باي (InstaPay)',
      'subtitle': 'دفع لحظي مباشر عبر التطبيق',
      'icon': Icons.flash_on_rounded,
      'color': const Color(0xFF2563EB),
    },
    {
      'name': 'فودافون كاش / المحافظ الإلكترونية',
      'subtitle': '01012345678',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFFDC2626),
    },
    {
      'name': 'فوري (Fawry Pay)',
      'subtitle': 'دفع بكود الخدمة في أي منفذ فوري',
      'icon': Icons.storefront_rounded,
      'color': const Color(0xFFD97706),
    },
    {
      'name': 'كارت تفعيل الكورس (Activation Code)',
      'subtitle': 'كود مباشر مفعل من المدرس',
      'icon': Icons.confirmation_number_rounded,
      'color': const Color(0xFF0FA37F),
    },
  ];

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon Graphic Container
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    color: const Color(0xFF0FA37F),
                    size: 44.r,
                  ),
                ),
                SizedBox(height: 12.h),

                // Stars row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFFBBF24),
                      size: 24.r,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),
                Text(
                  'تهانينا! 🎉 (Congratulations)',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'تم عملية الاشتراك وشراء الكورس بنجاح.\nيمكنك الآن البدء في دراسة المحاضرات!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 20.h),

                // Watch Course Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRouter.studentVideoPlayer);
                  },
                  child: Text(
                    'مشاهدة المحاضرات الآن 🎬',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0FA37F),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // E-Receipt Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, AppRouter.studentHome);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إيصال الدفع الإلكتروني (E-Receipt)',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18.r),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            'وسائل الدفع (Payment Methods)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Summary Header Box
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0FA37F).withAlpha(30),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: const Color(0xFF0FA37F),
                            size: 32.r,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الفيزياء الكهربية ⚡',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0FA37F),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'مبادئ وتطبيقات الفيزياء الكهربية والدوائر',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'الإجمالي: 499 ج.م',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    'اختر طريقة الدفع المناسبة لك:',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  ..._paymentMethods.asMap().entries.map((e) {
                    final index = e.key;
                    final method = e.value;
                    final isSelected = _selectedMethodIndex == index;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedMethodIndex = index);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0FA37F) : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42.r,
                              height: 42.r,
                              decoration: BoxDecoration(
                                color: (method['color'] as Color).withAlpha(20),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                method['icon'] as IconData,
                                color: method['color'] as Color,
                                size: 22.r,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['name'] as String,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    method['subtitle'] as String,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 22.r,
                              height: 22.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? const Color(0xFF0FA37F) : Colors.white,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF0FA37F) : const Color(0xFFCBD5E1),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check_rounded, color: Colors.white, size: 14.r)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Floating Bottom Action Button
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      _showSuccessDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      elevation: 4,
                      shadowColor: const Color(0x330FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Text(
                          'تأكيد ودفع 499 ج.م (Enroll Course)',
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: const Color(0xFF0FA37F),
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
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
