import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/logic/admin_push_tokens_cubit.dart';
import 'package:thanaweya_online/features/admin/ui/notifications/widgets/copy_tokens_options_dialog.dart';
import 'package:thanaweya_online/features/admin/ui/notifications/widgets/send_admin_notification_dialog.dart';

class AdminPushTokensScreen extends StatefulWidget {
  const AdminPushTokensScreen({super.key});

  @override
  State<AdminPushTokensScreen> createState() => _AdminPushTokensScreenState();
}

class _AdminPushTokensScreenState extends State<AdminPushTokensScreen> {
  late final AdminPushTokensCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = AdminPushTokensCubit()..loadTokens();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openSendNotificationDialog({
    String? specificUserId,
    String? specificUserName,
  }) {
    showDialog(
      context: context,
      builder: (_) => SendAdminNotificationDialog(
        cubit: _cubit,
        specificUserId: specificUserId,
        specificUserName: specificUserName,
      ),
    );
  }

  void _openCopyTokensDialog(List<Map<String, dynamic>> tokens) {
    if (tokens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد توكنز لنسخها', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => CopyTokensOptionsDialog(tokens: tokens),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text(
            'أجهزة وتوكنز الإشعارات (FCM)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.textPrimary,
              tooltip: 'تحديث',
              onPressed: () => _cubit.loadTokens(),
            ),
          ],
        ),
        body: BlocBuilder<AdminPushTokensCubit, AdminPushTokensState>(
          builder: (context, state) {
            if (state.status == AdminPushTokensStatus.loading &&
                state.allTokens.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.adminPrimary),
              );
            }

            if (state.status == AdminPushTokensStatus.error &&
                state.allTokens.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 48.r,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'تعذر تحميل توكنز الإشعارات',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton.icon(
                      onPressed: () => _cubit.loadTokens(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _cubit.loadTokens(),
              color: AppColors.adminPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Action Buttons Bar
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openSendNotificationDialog(),
                            icon: Icon(Icons.campaign_rounded, size: 18.r),
                            label: Text(
                              'إرسال إشعار فوري',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.adminPrimary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openCopyTokensDialog(state.filteredTokens),
                            icon: Icon(Icons.copy_all_rounded, size: 18.r),
                            label: Text(
                              'نسخ كل التوكنز',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              backgroundColor: const Color(0xFFEFF6FF),
                              side: const BorderSide(color: Color(0xFFBFDBFE)),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Stats Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'إجمالي الأجهزة',
                            value: '${state.totalCount}',
                            icon: Icons.devices_rounded,
                            color: const Color(0xFF6366F1),
                            bgColor: const Color(0xFFEEF2FF),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'الطلاب',
                            value: '${state.studentsCount}',
                            icon: Icons.school_rounded,
                            color: const Color(0xFF0EA5E9),
                            bgColor: const Color(0xFFF0F9FF),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'المعلمين',
                            value: '${state.teachersCount}',
                            icon: Icons.person_rounded,
                            color: const Color(0xFF10B981),
                            bgColor: const Color(0xFFECFDF5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => _cubit.search(v),
                        style: GoogleFonts.cairo(fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'ابحث باسم الطالب/المعلم، الإيميل، أو التوكن...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                            size: 20.r,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _cubit.search('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Role & Platform Filters Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'الكل (${state.totalCount})',
                            isSelected: state.roleFilter == 'all',
                            onTap: () => _cubit.filterByRole('all'),
                          ),
                          SizedBox(width: 8.w),
                          _buildFilterChip(
                            label: 'طلاب 🎓 (${state.studentsCount})',
                            isSelected: state.roleFilter == 'student',
                            onTap: () => _cubit.filterByRole('student'),
                          ),
                          SizedBox(width: 8.w),
                          _buildFilterChip(
                            label: 'معلمين 👨‍🏫 (${state.teachersCount})',
                            isSelected: state.roleFilter == 'teacher',
                            onTap: () => _cubit.filterByRole('teacher'),
                          ),
                          SizedBox(width: 14.w),
                          Container(width: 1.w, height: 24.h, color: const Color(0xFFCBD5E1)),
                          SizedBox(width: 14.w),
                          _buildPlatformChip(
                            label: 'Android 🤖 (${state.androidCount})',
                            isSelected: state.platformFilter == 'android',
                            onTap: () => _cubit.filterByPlatform(
                              state.platformFilter == 'android' ? 'all' : 'android',
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildPlatformChip(
                            label: 'iOS 🍏 (${state.iosCount})',
                            isSelected: state.platformFilter == 'ios',
                            onTap: () => _cubit.filterByPlatform(
                              state.platformFilter == 'ios' ? 'all' : 'ios',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Result count banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التوكنز المسجلة (${state.filteredTokens.length})',
                          style: GoogleFonts.cairo(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'محدثة تلقائياً',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Tokens List
                    if (state.filteredTokens.isEmpty) ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.phonelink_erase_rounded,
                                size: 48.r,
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'لا توجد توكنز مطابقة لخيارات البحث',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.filteredTokens.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final item = state.filteredTokens[index];
                          return _buildTokenCard(context, item);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.r, color: color),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.adminPrimary : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.adminPrimary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF334155) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTokenCard(BuildContext context, Map<String, dynamic> item) {
    final rawName = item['full_name'] as String? ?? 'مستخدم';
    final email = item['email'] as String? ?? '';
    final role = (item['role'] as String? ?? 'student').toLowerCase();
    final platform = (item['platform'] as String? ?? 'android').toLowerCase();
    final token = item['token'] as String? ?? '';
    final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String? ?? '';
    final isTeacher = role == 'teacher';
    final isStudent = role == 'student';
    final subjectName = item['subject_name'] as String? ?? '';
    final avatarUrl = item['avatar_url'] as String?;

    final displayName = isTeacher
        ? (rawName.startsWith('أ.') ? rawName : 'أ. $rawName')
        : rawName;

    final roleLabel = isTeacher
        ? (subjectName.isNotEmpty ? 'معلم $subjectName 👨‍🏫' : 'معلم 👨‍🏫')
        : isStudent
            ? 'طالب 🎓'
            : 'مسؤول 🛡️';
    final roleColor = isTeacher
        ? const Color(0xFF10B981)
        : isStudent
            ? const Color(0xFF0EA5E9)
            : const Color(0xFF8B5CF6);
    final roleBg = isTeacher
        ? const Color(0xFFECFDF5)
        : isStudent
            ? const Color(0xFFF0F9FF)
            : const Color(0xFFF5F3FF);

    final isAndroid = platform == 'android';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isTeacher
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isTeacher
                ? const Color(0xFF10B981).withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: roleColor.withValues(alpha: 0.15),
                backgroundImage:
                    avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(
                        displayName.isNotEmpty ? displayName.characters.first : 'U',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                          color: roleColor,
                          fontSize: 14.sp,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: roleBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            roleLabel,
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Platform Tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isAndroid
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAndroid ? Icons.android_rounded : Icons.apple_rounded,
                      size: 13.r,
                      color: isAndroid
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF475569),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isAndroid ? 'Android' : 'iOS',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isAndroid
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Token Box with Copy Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.vpn_key_rounded,
                  size: 14.r,
                  color: const Color(0xFF64748B),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    token,
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11.sp,
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6.w),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: token));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            SizedBox(width: 8.w),
                            Text(
                              'تم نسخ توكن $displayName بنجاح!',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF16A34A),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.adminPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 12.r,
                          color: AppColors.adminPrimary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'نسخ',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.adminPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Bottom Action Row (Send Direct Notification & Last Updated)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                updatedAt.isNotEmpty
                    ? 'آخر نشاط: ${_formatDate(updatedAt)}'
                    : '',
                style: GoogleFonts.cairo(
                  fontSize: 10.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: () => _openSendNotificationDialog(
                  specificUserId: item['user_id'] as String?,
                  specificUserName: displayName,
                ),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 13.r,
                        color: const Color(0xFF2563EB),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'إرسال إشعار لهذا المستخدم',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
