import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/firebase/notification_storage.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_profile_cubit.dart';

/// Top header displaying the teacher's greeting, name, code, actions, and avatar on the left.
/// Without any card/container wrapper for a modern integrated look.
class TeacherHeaderCard extends StatelessWidget {
  const TeacherHeaderCard({
    super.key,
    required this.teacherName,
    required this.greetingLabel,
    required this.teacherIdCode,
    required this.onNotificationsTap,
    required this.onSettingsTap,
    required this.onAvatarTap,
  });

  final String teacherName;
  final String greetingLabel;
  final String teacherIdCode;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
      builder: (context, state) {
        final avatarUrl = state.user?.avatarUrl;
        final displayName = state.user?.fullName.isNotEmpty == true
            ? state.user!.fullName
            : teacherName;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            children: [
              // ─── Right side: Greeting & Name ────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$greetingLabel 👋',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'كود الحساب: $teacherIdCode',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0369A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Left side: Action Buttons & Avatar ─────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Notifications Icon with badge
                  ValueListenableBuilder<int>(
                    valueListenable: NotificationStorage.unreadCountNotifier,
                    builder: (context, unreadCount, _) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _HeaderIconBtn(
                            icon: Icons.notifications_none_rounded,
                            onTap: onNotificationsTap,
                            tooltip: 'الإشعارات',
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: unreadCount > 9 ? 4.w : 0,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16.r,
                                  minHeight: 16.r,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  shape: unreadCount > 9
                                      ? BoxShape.rectangle
                                      : BoxShape.circle,
                                  borderRadius: unreadCount > 9
                                      ? BorderRadius.circular(8.r)
                                      : null,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444).withAlpha(120),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(width: 8.w),

                  // Settings Icon
                  _HeaderIconBtn(
                    icon: Icons.settings_outlined,
                    onTap: onSettingsTap,
                    tooltip: 'الإعدادات',
                  ),
                  SizedBox(width: 10.w),

                  // Teacher Avatar on the far left
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAvatarTap();
                    },
                    child: Container(
                      width: 46.r,
                      height: 46.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0284C7),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: avatarUrl,
                                fit: BoxFit.cover,
                                width: 46.r,
                                height: 46.r,
                                errorWidget: (_, _, _) => _buildInitials(displayName),
                              )
                            : _buildInitials(displayName),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitials(String name) {
    return Center(
      child: Text(
        name.trim().isNotEmpty ? name.trim()[0] : 'م',
        style: GoogleFonts.cairo(
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _HeaderIconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              icon,
              size: 19.r,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}
