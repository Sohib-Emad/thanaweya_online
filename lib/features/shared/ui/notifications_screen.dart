import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/data/repos/notifications_repo.dart';
import 'package:thanaweya_online/features/shared/logic/notifications_cubit.dart';
import 'package:thanaweya_online/features/shared/ui/widgets/notification_card.dart';
import 'package:thanaweya_online/features/shared/ui/widgets/notification_filter_chips.dart';
import 'package:thanaweya_online/features/shared/ui/widgets/notifications_empty_state.dart';
import 'package:thanaweya_online/features/shared/ui/widgets/notifications_error_view.dart';
import 'package:thanaweya_online/features/shared/ui/widgets/notifications_top_bar.dart';

/// Notifications screen for both student and teacher roles.
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
    if (userId != null) _cubit.loadNotifications(userId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _retry() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) _cubit.loadNotifications(userId);
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
              NotificationFilterChips(
                selectedCategory: _selectedCategory,
                isTeacher: _isTeacher,
                onCategoryChanged: (k) =>
                    setState(() => _selectedCategory = k),
              ),
              SizedBox(height: 14.h),
              Expanded(child: _buildBody(state)),
            ],
          );
          return Scaffold(
            backgroundColor:
                _isTeacher ? DeskColors.ground : NotebookColors.ground,
            appBar: NotificationsTopBar(
              allNotifications: state.notifications,
              isTeacher: _isTeacher,
              onMarkAllRead: _cubit.markAllAsRead,
            ),
            body: _isTeacher
                ? DeskSurface(child: content)
                : NotebookPaper(child: content),
          );
        },
      ),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.status == NotificationsStatus.loading &&
        state.notifications.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: _isTeacher ? DeskColors.primary : NotebookColors.green,
          strokeWidth: 2.6,
        ),
      );
    }
    if (state.status == NotificationsStatus.error &&
        state.notifications.isEmpty) {
      return NotificationsErrorView(
        message: state.errorMessage ?? 'تعذر تحميل الإشعارات',
        isTeacher: _isTeacher,
        onRetry: _retry,
      );
    }
    final filtered = _selectedCategory == 'all'
        ? state.notifications
        : state.notifications
            .where((n) => n.category == _selectedCategory)
            .toList();
    if (filtered.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: NotificationsEmptyState(
          message: state.notifications.isNotEmpty
              ? 'لا توجد إشعارات في هذا التصنيف'
              : 'لا توجد إشعارات بعد',
          isTeacher: _isTeacher,
        ),
      );
    }
    return RefreshIndicator(
      color: _isTeacher ? DeskColors.primary : NotebookColors.green,
      onRefresh: () async => _cubit.refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = filtered[index];
          return NotificationCard(
            item: item,
            isTeacher: _isTeacher,
            onTap: () {
              if (!item.isRead) {
                HapticFeedback.selectionClick();
                _cubit.markAsRead(item.id);
              }
            },
          );
        },
      ),
    );
  }
}
