import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class StudentTransactionsScreen extends StatefulWidget {
  final bool showBackButton;

  const StudentTransactionsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<StudentTransactionsScreen> createState() =>
      _StudentTransactionsScreenState();
}

class _StudentTransactionsScreenState
    extends State<StudentTransactionsScreen> {
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'SK345680976',
      'title': 'كورس بناء الهوية الشخصية (Personal Branding)',
      'category': 'تطوير الذات والتصميم',
      'price': '799 ج.م',
      'date': '20 نوفمبر 2023 / 15:45',
      'status': 'مدفوع',
      'studentName': 'صهيب عماد',
      'email': 'sohib@gmail.com',
      'color': const Color(0xFF0FA37F),
    },
    {
      'title': 'احتراف تصميم 3D بلندر (Blender 3D)',
      'category': 'تصميم UI/UX والـ 3D',
      'price': '650 ج.م',
      'date': '18 نوفمبر 2023 / 12:30',
      'status': 'مدفوع',
      'studentName': 'صهيب عماد',
      'email': 'sohib@gmail.com',
      'color': const Color(0xFF2563EB),
    },
    {
      'title': 'دورة تطوير الويب المتكاملة Full Stack',
      'category': 'تطوير البرمجيات والويب',
      'price': '950 ج.م',
      'date': '10 نوفمبر 2023 / 09:15',
      'status': 'مدفوع',
      'studentName': 'صهيب عماد',
      'email': 'sohib@gmail.com',
      'color': const Color(0xFF7C3AED),
    },
    {
      'title': 'دورة تصميم الواجهات UI/UX الشاملة',
      'category': 'إدارة وتصميم المنتج',
      'price': '500 ج.م',
      'date': '05 نوفمبر 2023 / 14:00',
      'status': 'مدفوع',
      'studentName': 'صهيب عماد',
      'email': 'sohib@gmail.com',
      'color': const Color(0xFFEA580C),
    },
    {
      'title': 'ورشة العمل الجماعي وتطبيقات الفيكما',
      'category': 'المالية والمحاسبة',
      'price': '350 ج.م',
      'date': '01 نوفمبر 2023 / 18:20',
      'status': 'مدفوع',
      'studentName': 'صهيب عماد',
      'email': 'sohib@gmail.com',
      'color': const Color(0xFF059669),
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
          leading: widget.showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: const Color(0xFF0F172A),
                    size: 20.r,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          centerTitle: false,
          title: Text(
            'المعاملات المالية (Transactions)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: const Color(0xFF0F172A),
                size: 22.r,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
          physics: const BouncingScrollPhysics(),
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final item = _transactions[index];
            final color = item['color'] as Color;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(
                  context,
                  AppRouter.studentEReceipt,
                  arguments: item,
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 14.h),
                padding: EdgeInsets.all(14.r),
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
                  children: [
                    // Course Thumbnail
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: color,
                          size: 30.r,
                        ),
                      ),
                    ),

                    SizedBox(width: 14.w),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item['category'],
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 6.h),

                          // Green Paid Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            child: Text(
                              'مدفوع • Paid',
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0FA37F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['price'],
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.studentPrimary,
                          ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: const Color(0xFF94A3B8),
                          size: 20.r,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
