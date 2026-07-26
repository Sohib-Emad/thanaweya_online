import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class StudentNotificationSettingsScreen extends StatefulWidget {
  const StudentNotificationSettingsScreen({super.key});

  @override
  State<StudentNotificationSettingsScreen> createState() =>
      _StudentNotificationSettingsScreenState();
}

class _StudentNotificationSettingsScreenState
    extends State<StudentNotificationSettingsScreen> {
  final Map<String, bool> _settings = {
    'Special Offers (العروض الخاصة)': true,
    'Sound (الأصوات والتنبيهات)': true,
    'Vibrate (الاهتزاز)': false,
    'General Notification (الإشعارات العامة)': true,
    'Promo & Discount (الخصومات والبرومو)': false,
    'Payment Options (معاملات وسائل الدفع)': true,
    'App Update (تحديثات التطبيق)': true,
    'New Service Available (الخدمات الجديدة)': false,
    'New Tips Available (النصائح والإرشادات)': false,
  };

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
            'التنبيهات والإشعارات (Notification)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          physics: const BouncingScrollPhysics(),
          children: _settings.keys.map((key) {
            final isVal = _settings[key]!;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: SwitchListTile(
                value: isVal,
                activeTrackColor: AppColors.studentPrimary,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                title: Text(
                  key,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _settings[key] = val);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
