import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/locale_controller.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

class StudentLanguageScreen extends StatefulWidget {
  const StudentLanguageScreen({super.key});

  @override
  State<StudentLanguageScreen> createState() => _StudentLanguageScreenState();
}

class _StudentLanguageScreenState extends State<StudentLanguageScreen> {
  final List<Map<String, String>> _languages = const [
    {'label': 'العربية', 'code': 'ar'},
    {'label': 'English', 'code': 'en'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.chooseLanguage,
        subtitle: l10n.languageSubtitle,
      ),
      body: NotebookPaper(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
          physics: const BouncingScrollPhysics(),
          children: [
            NotebookSectionHeader(title: l10n.availableLanguages),
              SizedBox(height: 12.h),
              ..._languages.map(_buildLanguageItem),
            ],
          ),
        ),
    );
  }

  Widget _buildLanguageItem(Map<String, String> lang) {
    final selected = LocaleController.instance.locale.languageCode == lang['code'];

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 24,
        marginTab: selected,
        borderRadius: 12,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        onTap: () async {
          HapticFeedback.selectionClick();
          await LocaleController.instance.setLocale(lang['code']!);
          if (!mounted) return;
          Navigator.pop(context, lang['label']);
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                lang['label']!,
                style: NotebookText.body(13.sp)
                    .copyWith(fontWeight: selected ? FontWeight.w900 : null),
              ),
            ),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? NotebookColors.green : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? NotebookColors.green
                      : NotebookColors.pencil.withAlpha(120),
                  width: 2,
                ),
              ),
              child: selected
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
