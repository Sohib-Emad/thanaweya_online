import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/teacher_about_tab.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/teacher_courses_tab.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/teacher_cover_card.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/whatsapp_contact_card.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen displaying a teacher's profile, bio, contact info, and published courses.
class TeacherProfileBody extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final String displayName;
  final Map<String, dynamic>? profile;
  final List<CourseModel> courses;
  final bool isLoadingCourses;
  final VoidCallback onRefreshCourses;

  const TeacherProfileBody({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.displayName,
    required this.profile,
    this.courses = const [],
    this.isLoadingCourses = false,
    required this.onRefreshCourses,
  });

  @override
  State<TeacherProfileBody> createState() => _TeacherProfileBodyState();
}

class _TeacherProfileBodyState extends State<TeacherProfileBody> {
  int _selectedTab = 0; // 0 = بيانات المعلم, 1 = الكورسات المنشورة

  @override
  Widget build(BuildContext context) {
    final bio = widget.profile?['bio'] as String? ?? '';
    final mode = widget.profile?['teaching_mode'] as String? ?? 'online';
    final governorate = widget.profile?['governorate'] as String? ?? '';
    final system = widget.profile?['teaching_system'] as String? ?? '';
    final stages = widget.profile?['stages'] as List<dynamic>?;
    final subjectName =
        (widget.profile?['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '';
    final usersMap = widget.profile?['users'] as Map<String, dynamic>?;
    final phone = usersMap?['phone'] as String? ?? '';
    final teacherName = usersMap?['full_name'] as String? ?? widget.name;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teacher Header Cover
          TeacherCoverCard(
            avatarUrl: widget.avatarUrl,
            name: widget.name,
            displayName: widget.displayName,
            verifiedLabel: context.l10n.verifiedTeacher,
          ),
          SizedBox(height: 16.h),

          // Two Sections Navigation Selector (قسم بيانات المعلم & قسم الكورسات)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(4.r),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    index: 0,
                    title: 'بيانات المعلم',
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: _buildTabButton(
                    index: 1,
                    title: 'الكورسات المنشورة',
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book_rounded,
                    badgeCount: widget.courses.length,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Section Content
          if (_selectedTab == 0) ...[
            // Section 1: Teacher Profile & Info
            if (phone.isNotEmpty) ...[
              WhatsAppContactCard(
                phone: phone,
                teacherName: teacherName,
                onPressed: () => _launchWhatsApp(context, phone, teacherName),
              ),
              SizedBox(height: 14.h),
            ],
            TeacherAboutTab(
              bio: bio,
              mode: mode,
              governorate: governorate,
              system: system,
              stages: stages,
              subjectName: subjectName,
            ),
          ] else ...[
            // Section 2: Teacher Published Courses
            TeacherCoursesTab(
              courses: widget.courses,
              isLoading: widget.isLoadingCourses,
              onRefresh: widget.onRefreshCourses,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required IconData icon,
    required IconData activeIcon,
    int? badgeCount,
  }) {
    final isSelected = _selectedTab == index;

    return InkWell(
      onTap: () {
        if (_selectedTab != index) {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        }
      },
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? NotebookColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 16.r,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 5.w),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                SizedBox(width: 5.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : NotebookColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: GoogleFonts.cairo(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : NotebookColors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  Future<void> _launchWhatsApp(
      BuildContext context, String phone, String teacherName) async {
    final cleanedPhone = _cleanPhoneNumber(phone);
    final message = context.l10n.whatsappMessage(teacherName);
    final url = Uri.parse(
        'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.whatsappOpenFailed),
        backgroundColor: NotebookColors.marginRed,
      ));
    }
  }
}
