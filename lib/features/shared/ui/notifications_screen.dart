// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — الإشعارات (shared, both roles)
// STORY: both the student's دفتر and the teacher's سبورة lead here. The page
//   adopts the world of whoever is reading it: notebook paper for the student,
//   the chalkboard for the teacher. Notifications come from real events
//   (teacher approval, subscription activation, published lessons/exams) in
//   the `notifications` table — never from mock lists.
// VIEWPORT: page shows a top bar with the unread count, category chalk/ink
//   chips (الكل/الدروس/الامتحانات/النظام), then real rows with a colored
//   category icon, title, body and relative time. Unread rows are tinted with
//   a dot; tapping marks one read, "تحديد الكل كمقروء" marks all.
// FINISH: real data or a themed empty state; never a fake notification.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/data/repos/notifications_repo.dart';
import 'package:thanaweya_online/features/shared/logic/notifications_cubit.dart';
import 'package:thanaweya_online/features/shared/models/notification_model.dart';

const _filters = <({String key, String label})>[
  (key: 'all', label: 'الكل'),
  (key: 'lessons', label: 'الدروس'),
  (key: 'exams', label: 'الامتحانات'),
  (key: 'system', label: 'النظام'),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _cubit = NotificationsCubit(repo: NotificationsRepo());
  late final bool _isTeacher;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _isTeacher =
        Supabase.instance.client.auth.currentUser?.userMetadata?['role'] ==
            'teacher';
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadNotifications(userId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  List<NotificationModel> _filtered(List<NotificationModel> all) {
    if (_selectedCategory == 'all') return all;
    return all.where((n) => n.category == _selectedCategory).toList();
  }

  ({IconData icon, Color color, String label}) _categoryStyle(
    String category,
  ) {
    switch (category) {
      case 'lessons':
        return (
          icon: Icons.play_circle_fill_rounded,
          color: _isTeacher
              ? ChalkboardColors.accent
              : NotebookColors.green,
          label: 'الدروس',
        );
      case 'exams':
        return (
          icon: Icons.assignment_turned_in_rounded,
          color: _isTeacher
              ? ChalkboardColors.chalkBlue
              : const Color(0xFF3F7FBF),
          label: 'الامتحانات',
        );
      default:
        return (
          icon: Icons.verified_rounded,
          color: _isTeacher
              ? ChalkboardColors.chalkYellow
              : const Color(0xFFD97706),
          label: 'النظام',
        );
    }
  }

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    _cubit.markAllAsRead();
  }

  void _markAsRead(NotificationModel item) {
    if (item.isRead) return;
    HapticFeedback.selectionClick();
    _cubit.markAsRead(item.id);
  }

  PreferredSizeWidget _buildTopBar(List<NotificationModel> all) {
    final unread = all.where((n) => !n.isRead).length;
    final subtitle = unread > 0 ? 'لديك $unread إشعار جديد' : 'لا إشعارات جديدة';

    final action = unread > 0
        ? GestureDetector(
            onTap: _markAllAsRead,
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تحديد الكل كمقروء',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: _isTeacher
                          ? ChalkboardColors.accent
                          : NotebookColors.green,
                    ),
                  ),
                ],
              ),
            ),
          )
        : null;

    if (_isTeacher) {
      return ChalkTopBar(
        title: 'الإشعارات',
        subtitle: subtitle,
        actions: [?action],
      );
    }
    return NotebookTopBar(
      title: 'الإشعارات',
      subtitle: subtitle,
      actions: [?action],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _filters[index];
          final selected = _selectedCategory == f.key;
          void onTap() {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = f.key);
          }

          if (_isTeacher) {
            return ChalkChip(label: f.label, selected: selected, onTap: onTap);
          }
          return NotebookChip(label: f.label, selected: selected, onTap: onTap);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final style = _categoryStyle(item.category);
    final isRead = item.isRead;

    Widget card = Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isRead
            ? (_isTeacher ? ChalkboardColors.surface : NotebookColors.surface)
            : (_isTeacher
                ? ChalkboardColors.surfaceBright
                : NotebookColors.surfaceBright),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isRead
              ? (_isTeacher
                  ? ChalkboardColors.ink.withAlpha(40)
                  : NotebookColors.ink.withAlpha(38))
              : style.color.withAlpha(90),
          width: isRead ? 1 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isTeacher
                    ? ChalkboardColors.groundDeep
                    : NotebookColors.ink)
                .withAlpha(16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: style.color.withAlpha(24),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(style.icon, color: style.color, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                          color: _isTeacher
                              ? ChalkboardColors.ink
                              : NotebookColors.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (!isRead) ...[
                      SizedBox(width: 8.w),
                      Container(
                        width: 9.r,
                        height: 9.r,
                        decoration: BoxDecoration(
                          color: style.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.body.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.body,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _isTeacher
                          ? ChalkboardColors.chalkSoft
                          : NotebookColors.pencil,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      style.label,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: style.color,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 3.r,
                      height: 3.r,
                      decoration: BoxDecoration(
                        color: _isTeacher
                            ? ChalkboardColors.chalkFaint
                            : NotebookColors.pencil,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      Formatters.timeAgo(item.createdAt),
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: _isTeacher
                            ? ChalkboardColors.chalkFaint
                            : NotebookColors.pencil,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => _markAsRead(item),
      child: card,
    );
  }

  Widget _buildEmpty({required bool categoryEmpty}) {
    final message = categoryEmpty
        ? 'لا توجد إشعارات في هذا التصنيف'
        : 'لا توجد إشعارات بعد';
    if (_isTeacher) {
      return ChalkEmptyNote(
        message: message,
        subMessage: 'ستصل هنا إشعارات تفعيل حسابك وأحداث المنصة',
        icon: Icons.notifications_none_rounded,
      );
    }
    return NotebookEmptyNote(
      message: message,
      icon: Icons.notifications_none_rounded,
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.status == NotificationsStatus.loading &&
        state.notifications.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: _isTeacher
              ? ChalkboardColors.accent
              : NotebookColors.green,
          strokeWidth: 2.6,
        ),
      );
    }

    if (state.status == NotificationsStatus.error &&
        state.notifications.isEmpty) {
      final message = state.errorMessage ?? 'تعذر تحميل الإشعارات';
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 42.r,
                color: _isTeacher
                    ? ChalkboardColors.chalkFaint
                    : NotebookColors.pencil,
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _isTeacher
                      ? ChalkboardColors.chalkSoft
                      : NotebookColors.pencil,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),
              if (_isTeacher)
                ChalkPrimaryButton(
                  label: 'إعادة المحاولة',
                  icon: Icons.refresh_rounded,
                  expanded: false,
                  onPressed: () {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) _cubit.loadNotifications(userId);
                  },
                )
              else
                NotebookPrimaryButton(
                  label: 'إعادة المحاولة',
                  icon: Icons.refresh_rounded,
                  expanded: false,
                  onPressed: () {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) _cubit.loadNotifications(userId);
                  },
                ),
            ],
          ),
        ),
      );
    }

    final filtered = _filtered(state.notifications);
    if (filtered.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: _buildEmpty(categoryEmpty: state.notifications.isNotEmpty),
      );
    }

    return RefreshIndicator(
      color: _isTeacher ? ChalkboardColors.accent : NotebookColors.green,
      onRefresh: () async => _cubit.refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) => _buildNotificationCard(filtered[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        bloc: _cubit,
        builder: (context, state) {
          final content = Column(
            children: [
              SizedBox(height: 12.h),
              _buildFilterChips(),
              SizedBox(height: 14.h),
              Expanded(child: _buildBody(state)),
            ],
          );
          return Scaffold(
            backgroundColor: _isTeacher
                ? ChalkboardColors.ground
                : NotebookColors.ground,
            appBar: _buildTopBar(state.notifications),
            body: _isTeacher
                ? ChalkboardSurface(child: content)
                : NotebookPaper(child: content),
          );
        },
      ),
    );
  }
}
