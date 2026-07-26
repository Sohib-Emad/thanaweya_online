import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'الدروس', 'الامتحانات', 'النظام'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n1',
      'title': 'تم رفع فيديو درس جديد 🎉',
      'body':
          'قام أ. محمد علي بنشر درس "الجبر والهندسة الفراغية - الجزء الأول" الآن.',
      'time': 'منذ 10 دقائق',
      'category': 'الدروس',
      'isRead': false,
      'icon': Icons.play_circle_fill_rounded,
      'color': const Color(0xFF0FA37F),
    },
    {
      'id': 'n2',
      'title': 'نتيجة امتحان الفيزياء الكهربية 📊',
      'body': 'تهانينا! حصلت على 28/30 في اختبار الفصل الأول مع أ. فاطمة حسن.',
      'time': 'منذ ساعتين',
      'category': 'الامتحانات',
      'isRead': false,
      'icon': Icons.assignment_turned_in_rounded,
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 'n3',
      'title': 'تذكير بموعد بث مباشر ⏰',
      'body':
          'يبدأ البث المباشر لمراجعة الفيزياء الحديثة اليوم الساعة 8:00 مساءً.',
      'time': 'منذ 4 ساعات',
      'category': 'الدروس',
      'isRead': true,
      'icon': Icons.live_tv_rounded,
      'color': const Color(0xFFD97706),
    },
    {
      'id': 'n4',
      'title': 'تم تفعيل كود الاشتراك بنجاح ✨',
      'body':
          'تم تفعيل اشتراكك في مادة العلوم بنجاح، يمكنك الآن متابعة جميع الدروس.',
      'time': 'أمس',
      'category': 'النظام',
      'isRead': true,
      'icon': Icons.verified_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'n5',
      'title': 'إضافة كويز تجريبي جديد 📝',
      'body':
          'أضاف أ. خالد إبراهيم اختباراً قصيراً في وحدة الكيمياء، ابدأ الآن.',
      'time': 'منذ يومين',
      'category': 'الامتحانات',
      'isRead': true,
      'icon': Icons.quiz_rounded,
      'color': const Color(0xFF8B5CF6),
    },
  ];

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (var item in _notifications) {
        item['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedFilter == 'الكل') return true;
      return n['category'] == _selectedFilter;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF0F172A),
              size: 30.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'الإشعارات 🔔',
            style: GoogleFonts.cairo(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'تحديد الكل كمقروء',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.studentPrimary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 12.h),

            // Horizontal Category Filters
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final f = _filters[index];
                  final isSelected = _selectedFilter == f;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilter = f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.studentPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.studentPrimary
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          f,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 14.h),

            // Notifications List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 54.r,
                            color: const Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'لا توجد إشعارات حالياً',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isRead = item['isRead'] as bool;
                        final icon = item['icon'] as IconData;
                        final iconColor = item['color'] as Color;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => item['isRead'] = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? Colors.white
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isRead
                                    ? const Color(0xFFF1F5F9)
                                    : AppColors.studentPrimary.withAlpha(80),
                                width: isRead ? 1.0 : 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x050F172A),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: iconColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: iconColor,
                                    size: 22.r,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] as String,
                                              style: GoogleFonts.cairo(
                                                fontSize: 14.sp,
                                                fontWeight: isRead
                                                    ? FontWeight.w700
                                                    : FontWeight.w900,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8.r,
                                              height: 8.r,
                                              decoration: const BoxDecoration(
                                                color: AppColors.studentPrimary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        item['body'] as String,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF475569),
                                          height: 1.4,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        item['time'] as String,
                                        style: GoogleFonts.cairo(
                                          fontSize: 10.sp,
                                          color: const Color(0xFF94A3B8),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
