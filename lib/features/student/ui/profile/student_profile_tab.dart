import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';
import '../../../auth/logic/auth_cubit.dart';

class StudentProfileTab extends StatefulWidget {
  final bool isTabMode;

  const StudentProfileTab({
    super.key,
    this.isTabMode = true,
  });

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  String _selectedLanguage = 'العربية';
  String _fullName = 'طالب';
  String _email = '';

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;
    final fullName = user?.userMetadata?['full_name']?.toString().trim() ?? '';
    _fullName = fullName.isEmpty ? 'طالب' : fullName;
    _email = user?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: widget.isTabMode ? 'الملف الشخصي' : 'Profile',
          subtitle: widget.isTabMode ? 'بياناتك وإعداداتك' : null,
          automaticallyImplyBack: !widget.isTabMode,
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 120.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Avatar — signed name at the top of the page
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100.r,
                            height: 100.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NotebookColors.surfaceBright,
                              border: Border.all(
                                color: NotebookColors.green,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: NotebookColors.surfaceBright,
                              child: Text(
                                _fullName.substring(0, 1),
                                style: GoogleFonts.cairo(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.w900,
                                  color: NotebookColors.ink,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentEditProfile,
                                );
                              },
                              child: Container(
                                width: 32.r,
                                height: 32.r,
                                decoration: BoxDecoration(
                                  color: NotebookColors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: NotebookColors.surfaceBright,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.photo_camera_rounded,
                                  color: Colors.white,
                                  size: 16.r,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _fullName,
                        style: NotebookText.heading(18.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _email,
                        style: NotebookText.note(12.sp),
                      ),
                      SizedBox(height: 6.h),
                      // signature underline beneath the name
                      Container(
                        width: 56.w,
                        height: 2.h,
                        color: NotebookColors.marginRed.withAlpha(160),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 26.h),

                // Menu — one ruled page of settings
                NotebookCard(
                  ruled: true,
                  ruledStartY: 24,
                  borderRadius: 12,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'تعديل الملف الشخصي',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.studentEditProfile,
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.payment_rounded,
                        title: 'خيارات وسائل الدفع',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.studentPaymentOptions,
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'إعدادات التنبيهات',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.studentNotificationSettings,
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.password_rounded,
                        title: 'تغيير كلمة المرور',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.studentChangePassword,
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.translate_rounded,
                        title: 'لغة التطبيق',
                        trailingText: _selectedLanguage,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRouter.studentLanguage,
                          );
                          if (result != null && result is String) {
                            setState(() => _selectedLanguage = result);
                          }
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        title: 'الشروط والأحكام والسياسات',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.studentTerms,
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'مركز الدعم والمساعدة',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'مركز المساعدة والدعم الفني',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              backgroundColor: AppColors.studentPrimary,
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.mail_outline_rounded,
                        title: 'دعوة الأصدقاء للمنصة',
                        onTap: () {
                          Clipboard.setData(
                            const ClipboardData(
                              text: 'انضم لمنصة الثانوية أونلاين: https://thanaweya.online/invite',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم نسخ رابط الدعوة بنجاح',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              backgroundColor: const Color(0xFF0FA37F),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: NotebookColors.ink.withAlpha(30),
                      ),
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'تسجيل الخروج',
                        isDanger: true,
                        onTap: () => _confirmLogout(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? trailingText,
    Widget? trailingWidget,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isDanger
                    ? NotebookColors.marginRed.withAlpha(14)
                    : NotebookColors.surfaceBright,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isDanger
                      ? NotebookColors.marginRed.withAlpha(90)
                      : NotebookColors.ink.withAlpha(28),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isDanger ? NotebookColors.marginRed : NotebookColors.ink,
                size: 19.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: NotebookText.body(13.sp).copyWith(
                  color: isDanger ? NotebookColors.marginRed : null,
                  fontWeight: isDanger ? FontWeight.w800 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailingText != null)
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        trailingText,
                        style: NotebookText.note(11.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: isDanger
                        ? NotebookColors.marginRed
                        : NotebookColors.pencil,
                    size: 20.r,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: NotebookColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: NotebookColors.marginRed.withAlpha(80)),
          ),
          title: Text(
            'تسجيل الخروج',
            style: NotebookText.strong(16.sp),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج من الحساب؟',
            style: NotebookText.body(13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'إلغاء',
                style: NotebookText.strong(13.sp),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'تسجيل الخروج',
                style: NotebookText.strong(13.sp).copyWith(
                  color: NotebookColors.marginRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    HapticFeedback.mediumImpact();
    context.read<AuthCubit>().signOut();
    Navigator.pushReplacementNamed(context, AppRouter.login);
  }
}
