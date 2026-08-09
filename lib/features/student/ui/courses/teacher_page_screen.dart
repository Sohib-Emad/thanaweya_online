import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

class TeacherPageScreen extends StatefulWidget {
  final String teacherId;
  final String title;
  final String? avatarUrl;

  const TeacherPageScreen({
    super.key,
    this.teacherId = '',
    this.title = '',
    this.avatarUrl,
  });

  @override
  State<TeacherPageScreen> createState() => _TeacherPageScreenState();
}

class _TeacherPageScreenState extends State<TeacherPageScreen> {
  late final StudentCoursesCubit _coursesCubit;

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    if (widget.teacherId.isNotEmpty) {
      _coursesCubit.loadTeacherProfile(widget.teacherId);
    }
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
  }

  String get _teacherDisplayName {
    final raw = widget.title.trim();
    if (raw.isEmpty) return 'صفحة المدرس';
    return raw.startsWith('أ.') ? raw : 'أ. $raw';
  }

  String _cleanPhoneNumber(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '20${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('20') && cleaned.length == 10) {
      cleaned = '20$cleaned';
    }
    return cleaned;
  }

  Future<void> _launchWhatsApp(String phone, String teacherName) async {
    final cleanedPhone = _cleanPhoneNumber(phone);
    final message = 'السلام عليكم أ. $teacherName، أريد الاستفسار عن حصصك وسناترك التعليمية من تطبيق ثانوية أونلاين.';
    final urlStr = 'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}';
    final url = Uri.parse(urlStr);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح الواتساب، يرجى التحقق من تثبيت التطبيق'),
            backgroundColor: NotebookColors.marginRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: _teacherDisplayName,
          subtitle: 'ملف المدرس وبيانات التواصل والسناتر',
        ),
        body: NotebookPaper(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Signed cover card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: NotebookColors.surfaceBright,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: NotebookColors.ink.withAlpha(35),
                          ),
                        ),
                        child: Row(
                          children: [
                            NotebookTeacherAvatar(
                              avatarUrl: widget.avatarUrl,
                              name: widget.title.trim().replaceFirst('أ. ', ''),
                              size: 60.r,
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _teacherDisplayName,
                                    style: NotebookText.heading(16.sp),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'مدرس معتمد على ثانوية أونلاين',
                                    style: NotebookText.note(11.sp),
                                  ),
                                  SizedBox(height: 7.h),
                                  // signature underline
                                  Container(
                                    width: 44.w,
                                    height: 2.h,
                                    color: NotebookColors.marginRed.withAlpha(
                                      160,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Profile Content Tab (integrated directly)
                      _buildAboutTeacherTab(context),
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

  Widget _buildAboutTeacherTab(BuildContext context) {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      bloc: _coursesCubit,
      builder: (context, state) {
        if (state.teacherProfileStatus == StudentCoursesStatus.loading &&
            state.teacherProfile == null) {
          return Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: Center(
              child: CircularProgressIndicator(
                color: NotebookColors.green,
              ),
            ),
          );
        }

        final profile = state.teacherProfile;
        if (profile == null) {
          return const NotebookEmptyNote(
            icon: Icons.info_outline_rounded,
            message: 'تعذر تحميل معلومات المدرس',
          );
        }

        final bio = profile['bio'] as String? ?? '';
        final mode = profile['teaching_mode'] as String? ?? 'online';
        final governorate = profile['governorate'] as String? ?? '';
        final system = profile['teaching_system'] as String? ?? '';
        final stages = profile['stages'] as List<dynamic>?;
        final subjectName = (profile['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '';
        final usersMap = profile['users'] as Map<String, dynamic>?;
        final phone = usersMap?['phone'] as String? ?? '';
        final teacherName = usersMap?['full_name'] as String? ?? widget.title.replaceFirst('أ. ', '');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WhatsApp Contact Card
            if (phone.isNotEmpty) ...[
              NotebookCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: const Color(0xFF075E54),
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'التواصل السريع',
                          style: NotebookText.strong(14.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'يمكنك التواصل مباشرة مع المعلم للاستفسار عن السناتر، المواعيد، أو أي تفاصيل دراسية أخرى.',
                      style: NotebookText.body(11.sp, color: NotebookColors.pencil),
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchWhatsApp(phone, teacherName),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shadowColor: Colors.black12,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: Icon(Icons.send_rounded, size: 20.r),
                        label: Text(
                          'تواصل عبر الواتساب',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Bio card
            NotebookCard(
              ruled: true,
              ruledStartY: 46,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: NotebookColors.green,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'النبذة التعريفية',
                        style: NotebookText.strong(14.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    bio.isNotEmpty
                        ? bio
                        : 'لا توجد نبذة تعريفية متوفرة حالياً لهذا المعلم.',
                    style: NotebookText.body(12.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Teaching mode and center card
            NotebookCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTeachingModeIcon(mode),
                        color: NotebookColors.green,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'مكان وطريقة التدريس',
                        style: NotebookText.strong(14.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    Icons.laptop_chromebook_rounded,
                    'طريقة التدريس',
                    _formatTeachingMode(mode),
                  ),
                  if (mode.toLowerCase() == 'center' ||
                      mode.toLowerCase() == 'both') ...[
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'مكان السنتر والتدريس',
                      'يتواجد في سناتر محافظة $governorate',
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Academic details card
            NotebookCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: NotebookColors.green,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'المراحل والأنظمة الدراسية',
                        style: NotebookText.strong(14.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    Icons.subject_rounded,
                    'المادة الدراسية',
                    subjectName.isNotEmpty ? subjectName : 'غير محدد',
                  ),
                  _buildInfoRow(
                    Icons.layers_rounded,
                    'المراحل الدراسية',
                    _formatStagesList(stages),
                  ),
                  _buildInfoRow(
                    Icons.settings_outlined,
                    'نظام التدريس',
                    _formatSystem(system),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: NotebookColors.pencil, size: 16.r),
          SizedBox(width: 10.w),
          Text('$label: ', style: NotebookText.note(11.sp)),
          Expanded(
            child: Text(
              value,
              style: NotebookText.body(11.sp),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStagesList(List<dynamic>? stages) {
    if (stages == null || stages.isEmpty) return 'غير محدد';
    final stageNames = stages.map((s) {
      switch (s.toString().toLowerCase()) {
        case 'first':
          return 'الصف الأول الثانوي';
        case 'second':
          return 'الصف الثاني الثانوي';
        case 'third':
          return 'الصف الثالث الثانوي';
        default:
          return s.toString();
      }
    }).toList();
    return stageNames.join(' • ');
  }

  String _formatSystem(String? system) {
    if (system == null || system.isEmpty) return 'غير محدد';
    switch (system.toLowerCase()) {
      case 'general':
        return 'ثانوية عامة';
      case 'azhari':
        return 'ثانوية أزهرية';
      case 'stem':
        return 'مدارس المتفوقين (STEM)';
      default:
        return system;
    }
  }

  String _formatTeachingMode(String? mode) {
    if (mode == null) return 'أونلاين';
    switch (mode.toLowerCase()) {
      case 'online':
        return 'أونلاين (من خلال المنصة فقط)';
      case 'center':
        return 'حضور مباشر في السنتر فقط';
      case 'both':
        return 'أونلاين ومن خلال السناتر التعليمية';
      default:
        return mode;
    }
  }

  IconData _getTeachingModeIcon(String? mode) {
    if (mode == null) return Icons.laptop_chromebook_rounded;
    switch (mode.toLowerCase()) {
      case 'online':
        return Icons.laptop_chromebook_rounded;
      case 'center':
        return Icons.location_city_rounded;
      case 'both':
        return Icons.business_center_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
