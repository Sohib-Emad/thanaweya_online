import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class StudentSecurityScreen extends StatefulWidget {
  const StudentSecurityScreen({super.key});

  @override
  State<StudentSecurityScreen> createState() => _StudentSecurityScreenState();
}

class _StudentSecurityScreenState extends State<StudentSecurityScreen> {
  bool _rememberMe = true;
  bool _biometricId = true;
  bool _faceId = false;

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
            'الأمان وحماية الحساب (Security)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSwitchItem(
                      title: 'تذكر حسابي (Remember Me)',
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val),
                    ),
                    _buildSwitchItem(
                      title: 'بصمة الاصبع (Biometric ID)',
                      value: _biometricId,
                      onChanged: (val) => setState(() => _biometricId = val),
                    ),
                    _buildSwitchItem(
                      title: 'بصمة الوجه (Face ID)',
                      value: _faceId,
                      onChanged: (val) => setState(() => _faceId = val),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: ListTile(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تفعيل Google Authenticator 🔑',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              backgroundColor: AppColors.studentPrimary,
                            ),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        title: Text(
                          'مصادقة جوجل (Google Authenticator)',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_left_rounded,
                          color: const Color(0xFF94A3B8),
                          size: 22.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تغيير رمز الـ PIN 🔐',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                      ),
                      child: Text(
                        'تغيير رمز الـ PIN (Change PIN)',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم فتح شاشة تغيير كلمة المرور 🔑',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: AppColors.studentPrimary,
                          ),
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
                            'تغيير كلمة المرور (Change Password)',
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: SwitchListTile(
        value: value,
        activeTrackColor: AppColors.studentPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
      ),
    );
  }
}
