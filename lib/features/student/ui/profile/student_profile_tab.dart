import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

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
  bool _isDarkMode = false;
  String _selectedLanguage = 'English (US)';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: widget.isTabMode
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
                title: Text(
                  'الملف الشخصي (Profile)',
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
              )
            : AppBar(
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
                  'Profile',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Avatar & Name Box
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
                            color: const Color(0xFFE2E8F0),
                            border: Border.all(
                              color: AppColors.studentPrimary,
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFFCBD5E1),
                            child: Icon(
                              Icons.person_rounded,
                              size: 54.r,
                              color: Colors.white,
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
                                color: AppColors.studentPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
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
                      'صهيب عماد (Alex)',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'sohibemad.redial@gmail.com',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Menu Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x060F172A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'تعديل الملف الشخصي',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.studentEditProfile,
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.payment_rounded,
                      title: 'Payment Option',
                      subtitle: 'خيارات وسائل الدفع',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.studentPaymentOptions,
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'إعدادات التنبيهات',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.studentNotificationSettings,
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.security_rounded,
                      title: 'Security',
                      subtitle: 'الأمان وحماية الحساب',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.studentSecurity,
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.translate_rounded,
                      title: 'Language',
                      subtitle: 'لغة التطبيق',
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
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'الوضع الداكن',
                      trailingWidget: Switch(
                        value: _isDarkMode,
                        activeTrackColor: AppColors.studentPrimary,
                        onChanged: (val) {
                          setState(() => _isDarkMode = val);
                        },
                      ),
                      onTap: () {
                        setState(() => _isDarkMode = !_isDarkMode);
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      subtitle: 'الشروط والأحكام والسياسات',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.studentTerms,
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      subtitle: 'مركز الدعم والمساعدة',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'مركز المساعدة والدعم الفني 🎧',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: AppColors.studentPrimary,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildMenuItem(
                      icon: Icons.mail_outline_rounded,
                      title: 'Invite Friends',
                      subtitle: 'دعوة الأصدقاء للمنصة',
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(
                            text: 'انضم لمنصة الثانوية أونلاين: https://thanaweya.online/invite',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم نسخ رابط الدعوة بنجاح 🚀',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: const Color(0xFF0FA37F),
                          ),
                        );
                      },
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailingText,
    Widget? trailingWidget,
  }) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF0F172A),
          size: 20.r,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          color: const Color(0xFF94A3B8),
        ),
      ),
      trailing: trailingWidget ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(
                  trailingText,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_left_rounded,
                color: const Color(0xFF94A3B8),
                size: 22.r,
              ),
            ],
          ),
    );
  }
}
