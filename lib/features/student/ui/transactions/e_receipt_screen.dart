import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class EReceiptScreen extends StatelessWidget {
  final Map<String, dynamic>? transactionData;

  const EReceiptScreen({
    super.key,
    this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    final title = transactionData?['title'] ?? 'كورس 3D Character Illustration';
    final category = transactionData?['category'] ?? 'تطوير البرمجيات (Web Development)';
    final price = transactionData?['price'] ?? '799 ج.م';
    final date = transactionData?['date'] ?? '20 نوفمبر 2023 / 15:45';
    final studentName = transactionData?['studentName'] ?? 'صهيب عماد (Alex)';
    final email = transactionData?['email'] ?? 'sohibemad@gmail.com';
    final transactionId = transactionData?['id'] ?? 'SK345680976';

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
            'إيصال الدفع الإلكتروني (E-Receipt)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: const Color(0xFF0F172A),
                  size: 20.r,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 6,
              onSelected: (value) {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تنفيذ الأمر: $value 🧾',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF0FA37F),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'مشاركة الإيصال',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مشاركة (Share)',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.send_rounded, size: 18.r, color: const Color(0xFF2563EB)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'تحميل PDF',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تحميل (Download)',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.download_rounded, size: 18.r, color: const Color(0xFF0FA37F)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'طباعة الإيصال',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'طباعة (Print)',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.print_rounded, size: 18.r, color: const Color(0xFF64748B)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Top Receipt Barcode Illustration Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Verified Check Illustration
                    Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: const Color(0xFF0FA37F),
                          size: 44.r,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Barcode graphic
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        32,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: (index % 4 == 0) ? 2.w : 1.w),
                          width: (index % 3 == 0) ? 3.w : (index % 2 == 0) ? 2.w : 1.w,
                          height: 48.h,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Barcode Numbers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '25234567',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '28646345',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),
                    const Divider(color: Color(0xFFF1F5F9)),
                    SizedBox(height: 16.h),

                    // Receipt Info Table
                    _buildReceiptRow('اسم الطالب (Name)', studentName),
                    SizedBox(height: 14.h),
                    _buildReceiptRow('البريد الإلكتروني (Email ID)', email),
                    SizedBox(height: 14.h),
                    _buildReceiptRow('اسم الكورس (Course)', title),
                    SizedBox(height: 14.h),
                    _buildReceiptRow('التصنيف (Category)', category),
                    SizedBox(height: 14.h),
                    
                    // Transaction ID with copy button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'رقم المعاملة (Transaction ID)',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              transactionId,
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: transactionId));
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم نسخ رقم المعاملة 📋',
                                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.copy_rounded,
                                color: const Color(0xFF2563EB),
                                size: 16.r,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _buildReceiptRow('المبلغ المدفوع (Price)', price, isBoldPrice: true),
                    SizedBox(height: 14.h),
                    _buildReceiptRow('تاريخ المعاملة (Date)', date),
                    SizedBox(height: 14.h),

                    // Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'حالة الدفع (Status)',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            'مدفوع • Paid',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0FA37F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBoldPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.cairo(
              fontSize: isBoldPrice ? 15.sp : 12.sp,
              fontWeight: isBoldPrice ? FontWeight.w900 : FontWeight.w800,
              color: isBoldPrice ? AppColors.studentPrimary : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
