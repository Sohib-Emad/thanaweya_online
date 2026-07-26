import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _ratingStars = 5;
  final TextEditingController _reviewTextController = TextEditingController();

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
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
            'كتابة تقييم (Write a Review)',
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
                  // Course Summary Card Header
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Rating Stars Selector
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ما هو تقييمك للكورس؟',
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _ratingStars = index + 1);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Icon(
                                  index < _ratingStars ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: const Color(0xFFFBBF24),
                                  size: 36.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Add Photo / Video Box
                  Text(
                    'إضافة صورة أو فيديو (اختياري):',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 110.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: const Color(0xFF0FA37F),
                          size: 38.r,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'انقر هنا لرفع الملفات',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Write Review TextArea
                  Text(
                    'اكتب تقييمك بالتفصيل:',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _reviewTextController,
                      maxLines: 4,
                      style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'ما هي تجربتك مع هذا الكورس والمدرس؟ شارك برأيك لمساعدة بقية الطلاب...',
                        hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Submit Button at bottom
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'شاطر! تم إرسال تقييمك بنجاح.',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF0FA37F),
                        ),
                      );
                      Navigator.pop(context);
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
                          'إرسال التقييم (Submit Review)',
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
                            Icons.send_rounded,
                            color: const Color(0xFF0FA37F),
                            size: 18.r,
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
