import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/notifications/widgets/widgets.dart';

/// Notifications hub for teachers — displays student interactions,
/// exam submissions, and course updates with category filtering.
class TeacherNotificationsScreen extends StatefulWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  State<TeacherNotificationsScreen> createState() =>
      _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState
    extends State<TeacherNotificationsScreen> {
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _notifications = const [
    {
      'id': '1',
      'category': 1,
      'title': 'انضمام طالب جديد',
      'body': 'قام الطالب «أحمد محمد» بالاشتراك في كورس الفيزياء الحديثة.',
      'time': 'منذ 10 دقائق',
      'isRead': false,
      'icon': Icons.person_add_rounded,
      'color': DeskColors.primary,
    },
    {
      'id': '2',
      'category': 2,
      'title': 'تسليم امتحان جديد',
      'body': 'قامت الطالبة «سارة إبراهيم» بتسليم إجابات امتحان الشامل بنسبة 95%.',
      'time': 'منذ ساعتين',
      'isRead': false,
      'icon': Icons.quiz_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'id': '3',
      'category': 3,
      'title': 'تحديث كورس جديد',
      'body': 'تم نشر المحاضرة رقم 3 في كورس الكيمياء العضوية بنجاح.',
      'time': 'أمس',
      'isRead': true,
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF0EA5E9),
    },
  ];

  static const _categories = ['الكل', 'الطلاب', 'الامتحانات', 'الكورسات'];

  List<Map<String, dynamic>> get _filtered => _selectedCategory == 0
      ? _notifications
      : _notifications
          .where((n) => n['category'] == _selectedCategory)
          .toList();

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _notifications) {
        (n as dynamic)['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديد جميع الإشعارات كمقروءة',
            style: GoogleFonts.cairo()),
        backgroundColor: DeskColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'مركز الإشعارات والتنبيهات',
          subtitle: 'متابعة تفاعلات الطلاب وتسليم الامتحانات',
          automaticallyImplyBack: true,
          actions: [
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'تحديد الكل كمقروء',
                style: GoogleFonts.cairo(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: DeskColors.primary,
                ),
              ),
            ),
          ],
        ),
        body: DeskSurface(
          child: Column(
            children: [
              SizedBox(height: 14.h),
              CategoryFilterChips(
                categories: _categories,
                selectedIndex: _selectedCategory,
                onSelected: (i) => setState(() => _selectedCategory = i),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: filtered.isEmpty
                    ? const DeskEmptyNote(
                        message: 'لا توجد إشعارات بهذه الفئة',
                        icon: Icons.notifications_off_outlined,
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 8.h),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) =>
                            NotificationCard(item: filtered[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
