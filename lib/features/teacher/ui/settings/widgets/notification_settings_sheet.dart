import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/teacher/ui/settings/widgets/settings_switch_row.dart';

/// Bottom sheet for configuring notification toggles.
class NotificationSettingsSheet extends StatefulWidget {
  final bool notifyNewStudents;
  final bool notifyExamFinished;
  final bool notifyLowPerformance;
  final bool notifyCodeUsed;
  final ValueChanged<bool> onNewStudentsChanged;
  final ValueChanged<bool> onExamFinishedChanged;
  final ValueChanged<bool> onLowPerformanceChanged;
  final ValueChanged<bool> onCodeUsedChanged;

  const NotificationSettingsSheet({
    super.key,
    required this.notifyNewStudents, required this.notifyExamFinished,
    required this.notifyLowPerformance, required this.notifyCodeUsed,
    required this.onNewStudentsChanged, required this.onExamFinishedChanged,
    required this.onLowPerformanceChanged, required this.onCodeUsedChanged,
  });

  static Future<void> show(BuildContext context, {
    required bool notifyNewStudents, required bool notifyExamFinished,
    required bool notifyLowPerformance, required bool notifyCodeUsed,
    required ValueChanged<bool> onNewStudentsChanged, required ValueChanged<bool> onExamFinishedChanged,
    required ValueChanged<bool> onLowPerformanceChanged, required ValueChanged<bool> onCodeUsedChanged,
  }) {
    return showModalBottomSheet(context: context, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => NotificationSettingsSheet(
            notifyNewStudents: notifyNewStudents, notifyExamFinished: notifyExamFinished,
            notifyLowPerformance: notifyLowPerformance, notifyCodeUsed: notifyCodeUsed,
            onNewStudentsChanged: onNewStudentsChanged, onExamFinishedChanged: onExamFinishedChanged,
            onLowPerformanceChanged: onLowPerformanceChanged, onCodeUsedChanged: onCodeUsedChanged));
  }

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  late bool _ns, _ef, _lp, _cu;

  @override
  void initState() {
    super.initState();
    _ns = widget.notifyNewStudents; _ef = widget.notifyExamFinished;
    _lp = widget.notifyLowPerformance; _cu = widget.notifyCodeUsed;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 16.h),
            Text('إعدادات الإشعارات والتنبيهات',
                style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            SizedBox(height: 14.h),
            SettingsSwitchRow(title: 'إشعار انضمام طالب جديد للكورس', subtitle: 'تلقي تنبيه عند اشتراك أي طالب جديد',
                value: _ns, onChanged: (v) { setSheetState(() => _ns = v); widget.onNewStudentsChanged(v); }),
            const Divider(height: 1),
            SettingsSwitchRow(title: 'إشعار تسليم امتحان جديد', subtitle: 'تلقي تنبيه عند تسليم طالب لإجابته',
                value: _ef, onChanged: (v) { setSheetState(() => _ef = v); widget.onExamFinishedChanged(v); }),
            const Divider(height: 1),
            SettingsSwitchRow(title: 'تنبيهات مستوى الطلاب', subtitle: 'تلقي تقرير ذكي عند نزول درجات طالب',
                value: _lp, onChanged: (v) { setSheetState(() => _lp = v); widget.onLowPerformanceChanged(v); }),
            const Divider(height: 1),
            SettingsSwitchRow(title: 'إشعار استخدام كود التفعيل', subtitle: 'تنبيه عند تفعيل كود بواسطة طالب',
                value: _cu, onChanged: (v) { setSheetState(() => _cu = v); widget.onCodeUsedChanged(v); }),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity, height: 44.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('حفظ الإعدادات', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12.5.sp)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
