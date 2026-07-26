import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class StudentLanguageScreen extends StatefulWidget {
  const StudentLanguageScreen({super.key});

  @override
  State<StudentLanguageScreen> createState() => _StudentLanguageScreenState();
}

class _StudentLanguageScreenState extends State<StudentLanguageScreen> {
  String _selectedLanguage = 'English (US)';

  final List<String> _subCategories = [
    'English (US)',
    'English (UK)',
  ];

  final List<String> _allLanguages = [
    'English (US)',
    'العربية (Arabic)',
    'Hindi',
    'Bengali',
    'Deutsch',
    'Italian',
    'Korean',
    'Francais',
    'Russian',
    'Polish',
    'Spanish',
    'Mandarin',
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
            'اختر اللغة (Language)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
          physics: const BouncingScrollPhysics(),
          children: [
            // SubCategories Header
            Text(
              'اللغات الشائعة (SubCategories):',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 10.h),
            ..._subCategories.map((lang) => _buildLanguageItem(lang)),

            SizedBox(height: 24.h),

            // All Languages Header
            Text(
              'جميع اللغات (All Languages):',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 10.h),
            ..._allLanguages.map((lang) => _buildLanguageItem(lang)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String lang) {
    final isSelected = _selectedLanguage == lang;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedLanguage = lang);
        Navigator.pop(context, lang);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.studentPrimary : const Color(0xFFF1F5F9),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.studentPrimary : const Color(0xFF0F172A),
              ),
            ),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.studentPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.studentPrimary
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14.r,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
