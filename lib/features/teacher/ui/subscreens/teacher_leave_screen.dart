import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/widgets.dart';

/// Screen for managing teacher leave and absence requests —
/// lists past requests and allows submitting new ones.
class TeacherLeaveScreen extends StatefulWidget {
  const TeacherLeaveScreen({super.key});

  @override
  State<TeacherLeaveScreen> createState() => _TeacherLeaveScreenState();
}

class _TeacherLeaveScreenState extends State<TeacherLeaveScreen> {
  final List<Map<String, dynamic>> _requests = [
    {
      'id': '1',
      'type': 'إجازة اعتيادية',
      'reason': 'ظروف عائلية خيرة',
      'startDate': '2026-08-20',
      'endDate': '2026-08-22',
      'status': 'مقبول',
      'statusColor': DeskColors.primary,
    },
    {
      'id': '2',
      'type': 'استئذان حصة',
      'reason': 'مراجعة طبية طارئة',
      'startDate': '2026-08-15',
      'endDate': '2026-08-15',
      'status': 'قيد المراجعة',
      'statusColor': DeskColors.accent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'طلب الإجازات والاستئذان',
          subtitle: 'سجل الطلبات السابقة ومتابعة حالة القبول',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.r),
            itemCount: _requests.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (_, i) => LeaveRequestCard(item: _requests[i]),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            LeaveRequestSheet.show(context);
          },
          backgroundColor: DeskColors.primary,
          foregroundColor: Colors.white,
          icon: Icon(Icons.add_rounded, size: 20.r),
          label: Text(
            'طلب جديد',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
