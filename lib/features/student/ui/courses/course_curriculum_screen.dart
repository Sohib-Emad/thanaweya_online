import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class CourseCurriculumScreen extends StatefulWidget {
  final bool isCompleted;

  const CourseCurriculumScreen({super.key, this.isCompleted = false});

  @override
  State<CourseCurriculumScreen> createState() => _CourseCurriculumScreenState();
}

class _CourseCurriculumScreenState extends State<CourseCurriculumScreen> {
  final List<Map<String, dynamic>> _sections = const [
    {
      'sectionNumber': 'القسم 01',
      'title': 'المقدمة والأساسيات (Introduction)',
      'totalDuration': '25 دقيقة',
      'lessons': [
        {
          'number': '01',
          'title': 'لماذا نعتمد 3D Blender في التصميم؟',
          'duration': '15 دقيقة',
          'isUnlocked': true,
        },
        {
          'number': '02',
          'title': 'إعداد وتحضير واجهة البرنامج وتثبيته',
          'duration': '10 دقائق',
          'isUnlocked': true,
        },
      ],
    },
    {
      'sectionNumber': 'القسم 02',
      'title': 'التصميم والتطبيق العملي (Graphic Design)',
      'totalDuration': '55 دقيقة',
      'lessons': [
        {
          'number': '03',
          'title': 'نظرة عامة على أدوات النمذجة والتحكم',
          'duration': '20 دقيقة',
          'isUnlocked': false,
        },
        {
          'number': '04',
          'title': 'التعامل مع الإطارات والطبقات الرسمية',
          'duration': '25 دقيقة',
          'isUnlocked': false,
        },
        {
          'number': '05',
          'title': 'التظليل والإضاءة الشاملة ثلاثية الأبعاد',
          'duration': '10 دقائق',
          'isUnlocked': false,
        },
      ],
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
            'منهج الكورس (My Courses)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Top Search Input & Filter Button (Matching Screens 37 & 40)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'البحث عن درس أو محتوى...',
                              hintStyle: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: const Color(0xFF94A3B8),
                                size: 20.r,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(context, AppRouter.studentFilter);
                        },
                        child: Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: AppColors.studentPrimary,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x200FA37F),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 22.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Curriculum Sections List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 110.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _sections.length,
                    itemBuilder: (context, sectionIndex) {
                      final sec = _sections[sectionIndex];
                      final sectionNumber = sec['sectionNumber'] as String;
                      final title = sec['title'] as String;
                      final totalDuration = sec['totalDuration'] as String;
                      final lessons =
                          sec['lessons'] as List<Map<String, dynamic>>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$sectionNumber - $title',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                totalDuration,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          ...lessons.map((les) {
                            final num = les['number'] as String;
                            final lesTitle = les['title'] as String;
                            final dur = les['duration'] as String;
                            final unlocked = les['isUnlocked'] as bool;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentVideoPlayer,
                                  arguments: {
                                    'lessonId': num,
                                    'title': lesTitle,
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x060F172A),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38.r,
                                      height: 38.r,
                                      decoration: BoxDecoration(
                                        color: unlocked
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          num,
                                          style: GoogleFonts.cairo(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w800,
                                            color: unlocked
                                                ? const Color(0xFF0FA37F)
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lesTitle,
                                            style: GoogleFonts.cairo(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            dur,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32.r,
                                      height: 32.r,
                                      decoration: BoxDecoration(
                                        color: unlocked
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFCBD5E1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        unlocked
                                            ? Icons.play_arrow_rounded
                                            : Icons.lock_outline_rounded,
                                        color: Colors.white,
                                        size: 18.r,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 14.h),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            // Bottom Floating Action Sheet (Matching Screen 37 & Screen 40)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x150F172A),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      if (widget.isCompleted) ...[
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pushNamed(
                              context,
                              AppRouter.studentCertificate,
                            );
                          },
                          child: Container(
                            width: 52.r,
                            height: 52.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: const Color(0xFF2563EB),
                              size: 26.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pushNamed(
                                context,
                                AppRouter.studentVideoPlayer,
                                arguments: {
                                  'lessonId': '01',
                                  'title': 'درس التمهيد للثانوية العامة',
                                },
                              );
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
                                  widget.isCompleted
                                      ? 'إعادة بدء الكورس (Start Course Again)'
                                      : 'متابعة التعلم (Continue Course)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  width: 32.r,
                                  height: 32.r,
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
