import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/notebook_theme.dart';

class StudentLanguageScreen extends StatefulWidget {
  const StudentLanguageScreen({super.key});

  @override
  State<StudentLanguageScreen> createState() => _StudentLanguageScreenState();
}

class _StudentLanguageScreenState extends State<StudentLanguageScreen> {
  String _selectedLanguage = 'العربية';

  final List<String> _languages = [
    'العربية',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'اختر اللغة',
          subtitle: 'لغة عرض الدفتر',
        ),
        body: NotebookPaper(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              NotebookSectionHeader(title: 'اللغات المتاحة'),
              SizedBox(height: 12.h),
              ..._languages.map(_buildLanguageItem),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String lang) {
    final isSelected = _selectedLanguage == lang;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 24,
        marginTab: isSelected,
        borderRadius: 12,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedLanguage = lang);
          Navigator.pop(context, lang);
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                lang,
                style: NotebookText.body(13.sp)
                    .copyWith(fontWeight: isSelected ? FontWeight.w900 : null),
              ),
            ),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? NotebookColors.green : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? NotebookColors.green
                      : NotebookColors.pencil.withAlpha(120),
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
