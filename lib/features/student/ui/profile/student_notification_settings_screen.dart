import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/notebook_theme.dart';

class StudentNotificationSettingsScreen extends StatefulWidget {
  const StudentNotificationSettingsScreen({super.key});

  @override
  State<StudentNotificationSettingsScreen> createState() =>
      _StudentNotificationSettingsScreenState();
}

class _StudentNotificationSettingsScreenState
    extends State<StudentNotificationSettingsScreen> {
  final Map<String, bool> _settings = {
    'العروض الخاصة': true,
    'الأصوات والتنبيهات': true,
    'الاهتزاز': false,
    'الإشعارات العامة': true,
    'الخصومات والعروض الترويجية': false,
    'معاملات وسائل الدفع': true,
    'تحديثات التطبيق': true,
    'الخدمات الجديدة': false,
    'النصائح والإرشادات': false,
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'التنبيهات والإشعارات',
          subtitle: 'تحكم في تنبيهات دفترك',
        ),
        body: NotebookPaper(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              NotebookCard(
                ruled: true,
                ruledStartY: 24,
                borderRadius: 12,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Column(
                  children: _settings.keys.map((key) {
                    final isVal = _settings[key]!;
                    return SwitchListTile(
                      value: isVal,
                      activeTrackColor: NotebookColors.green,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      title: Text(
                        key,
                        style: NotebookText.body(13.sp),
                      ),
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _settings[key] = val);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
