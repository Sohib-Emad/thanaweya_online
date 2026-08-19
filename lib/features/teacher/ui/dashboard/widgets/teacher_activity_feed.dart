import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Activity feed section showing recent platform activity.
class TeacherActivityFeed extends StatelessWidget {
  const TeacherActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'title': 'طالب جديد انضم للكورس',
        'subtitle': 'انضم أحمد علي لكورس الرياضيات للصف الثالث الثانوي',
        'time': 'منذ 15 دقيقة',
        'icon': Icons.person_add_alt_1_rounded,
        'color': const Color(0xFF0284C7),
      },
      {
        'title': 'طالب أنهى امتحان',
        'subtitle': 'أنهت مريم حسن امتحان التفاضل والتكامل بدرجة 95%',
        'time': 'منذ ساعتين',
        'icon': Icons.task_alt_rounded,
        'color': const Color(0xFF16A34A),
      },
      {
        'title': 'تم إنشاء أكواد تفعيل جديدة',
        'subtitle': 'تم توليد 50 كود تفعيل لكورس المراجعة النهائية',
        'time': 'اليوم، 10:00 ص',
        'icon': Icons.vpn_key_rounded,
        'color': const Color(0xFFD97706),
      },
    ];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      size: 17.r, color: const Color(0xFF1E293B)),
                  SizedBox(width: 6.w),
                  Text(
                    'آخر الأنشطة والتفاعلات',
                    style: GoogleFonts.cairo(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Text(
                'مباشر',
                style: GoogleFonts.cairo(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 12, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, i) {
              final act = activities[i];
              final color = act['color'] as Color;
              return Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: color.withAlpha(16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(act['icon'] as IconData,
                        color: color, size: 16.r),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act['title'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          act['subtitle'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    act['time'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
