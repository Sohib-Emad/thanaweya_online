import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_teachers_cubit.dart';
import 'package:thanaweya_online/features/admin/ui/widgets/admin_password_tile.dart';

class AllTeachersScreen extends StatefulWidget {
  const AllTeachersScreen({super.key});

  @override
  State<AllTeachersScreen> createState() => _AllTeachersScreenState();
}

class _AllTeachersScreenState extends State<AllTeachersScreen> {
  final _cubit = AdminTeachersCubit(repo: AdminTeachersRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadAllTeachers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _formatPlan(String? plan) {
    switch (plan) {
      case 'yearly':
      case 'annual':
        return 'الباقة السنوية';
      case 'term':
        return 'باقة الترم';
      case 'monthly':
        return 'الباقة الشهرية';
      default:
        return plan ?? 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('إدارة المعلمين والتجديد'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث',
              onPressed: () => _cubit.loadAllTeachers(),
            ),
          ],
        ),
        body: BlocBuilder<AdminTeachersCubit, AdminTeachersState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminTeachersStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.allTeachers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 64.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text('لا يوجد معلمين مسجلين حالياً', style: AppTextStyles.h3),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _cubit.loadAllTeachers(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                itemCount: state.allTeachers.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final teacher = state.allTeachers[index];
                  final teacherId = teacher['id'] as String? ?? '';
                  final status = teacher['approval_status'] as String? ?? 'pending';
                  final users = teacher['users'] as Map<String, dynamic>? ?? {};
                  final name = users['full_name'] as String? ?? 'معلم';
                  final email = users['email'] as String? ?? '';
                  final phone = users['phone'] as String? ?? '';
                  final initials = name.isNotEmpty ? name[0] : 'م';
                  final subjects = teacher['subjects'] as Map<String, dynamic>? ?? {};
                  final subjectName = subjects['name_ar'] as String? ?? 'المادة العامة';
                  final plan = _formatPlan(teacher['selected_plan'] as String?);
                  final requiresRenewal = teacher['requires_renewal'] == true;

                  Color statusColor;
                  String statusText;
                  switch (status) {
                    case 'approved':
                      statusColor = AppColors.success;
                      statusText = 'معتمد ونشط';
                      break;
                    case 'banned':
                      statusColor = const Color(0xFFDC2626);
                      statusText = 'محظور 🚫';
                      break;
                    case 'rejected':
                      statusColor = AppColors.error;
                      statusText = 'مرفوض';
                      break;
                    default:
                      statusColor = AppColors.warning;
                      statusText = 'قيد المراجعة';
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: requiresRenewal
                            ? AppColors.warning.withValues(alpha: 0.6)
                            : AppColors.cardBorder,
                        width: requiresRenewal ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (requiresRenewal ? AppColors.warning : Colors.black)
                              .withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Header: Avatar, Name, Status ────────────────────────────
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundColor: AppColors.adminPrimaryLight,
                              child: Text(
                                initials,
                                style: GoogleFonts.cairo(
                                  color: AppColors.adminPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '$subjectName • $plan',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (email.isNotEmpty || phone.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              if (phone.isNotEmpty) ...[
                                Icon(Icons.phone_outlined, size: 14.r, color: AppColors.textTertiary),
                                SizedBox(width: 4.w),
                                Text(phone, style: AppTextStyles.caption),
                                SizedBox(width: 14.w),
                              ],
                              if (email.isNotEmpty) ...[
                                Icon(Icons.email_outlined, size: 14.r, color: AppColors.textTertiary),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: AppTextStyles.caption,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],

                        // Password Row (View, Copy, Edit)
                        AdminPasswordTile(
                          userId: teacher['id'] as String? ?? '',
                          userName: name,
                          initialPassword: (teacher['plain_password'] as String?) ??
                              (users['plain_password'] as String?) ??
                              '',
                          onPasswordChanged: (newPass) async {
                            final res = await AdminTeachersRepo().updateUserPassword(
                              teacher['id'] as String? ?? '',
                              newPass,
                            );
                            return res.when(
                              success: (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تحديث كلمة المرور بنجاح ✅'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                return true;
                              },
                              failure: (err, _) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ: $err'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return false;
                              },
                            );
                          },
                        ),

                        SizedBox(height: 12.h),
                        const Divider(height: 1),
                        SizedBox(height: 10.h),

                        // ─── Renewal Alert Control (إظهار إنذار التجديد للمعلم) ──────
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: requiresRenewal
                                ? const Color(0xFFFEF3C7)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    requiresRenewal
                                        ? Icons.warning_amber_rounded
                                        : Icons.notifications_off_outlined,
                                    color: requiresRenewal
                                        ? const Color(0xFFD97706)
                                        : AppColors.textTertiary,
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        requiresRenewal
                                            ? 'إنذار التجديد مفعل لدى المعلم ⚠️'
                                            : 'تنبيه انتهاء الاشتراك (طلب التجديد)',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                          color: requiresRenewal
                                              ? const Color(0xFF92400E)
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        requiresRenewal
                                            ? 'يظهر تنبيه ثابت للمعلم لتجديد باقته فوراً'
                                            : 'تفعيل هذا الخيار سيظهر إنذاراً ثابتاً للمعلم',
                                        style: GoogleFonts.cairo(
                                          fontSize: 10.5.sp,
                                          color: requiresRenewal
                                              ? const Color(0xFFB45309)
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: requiresRenewal,
                                activeThumbColor: const Color(0xFFD97706),
                                onChanged: (val) {
                                  HapticFeedback.selectionClick();
                                  _cubit.toggleRenewalAlert(teacherId, val);
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // ─── Ban Control (حظر / إلغاء حظر المعلم) ────────
                        Builder(builder: (context) {
                          final isBanned = status == 'banned';
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isBanned
                                  ? const Color(0xFFFEF2F2)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10.r),
                              border: isBanned
                                  ? Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5))
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isBanned
                                          ? Icons.block_rounded
                                          : Icons.check_circle_outline_rounded,
                                      color: isBanned
                                          ? const Color(0xFFDC2626)
                                          : AppColors.textTertiary,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isBanned
                                              ? 'الحساب محظور حالياً 🚫'
                                              : 'حالة الحساب طبيعية',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w800,
                                            color: isBanned
                                                ? const Color(0xFF991B1B)
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          isBanned
                                              ? 'يتم منع المعلم من الدخول للتطبيق فوراً'
                                              : 'حظر المعلم لمنعه من استخدام التطبيق',
                                          style: GoogleFonts.cairo(
                                            fontSize: 10.5.sp,
                                            color: isBanned
                                                ? const Color(0xFFB91C1C)
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => _confirmBanToggle(
                                    context,
                                    teacherId,
                                    isBanned,
                                    name,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isBanned
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    isBanned ? 'فك الحظر' : 'حظر الحساب',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        SizedBox(height: 10.h),

                        // ─── Quick Actions: View Students & View Active Codes ────────
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.adminStudents,
                                    arguments: teacherId,
                                  );
                                },
                                icon: const Icon(Icons.school_outlined, size: 16),
                                label: Text(
                                  'طلاب المعلم',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.studentPrimary,
                                  side: BorderSide(
                                    color: AppColors.studentPrimary.withValues(alpha: 0.5),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.adminActiveCodes,
                                    arguments: teacherId,
                                  );
                                },
                                icon: const Icon(Icons.vpn_key_outlined, size: 16),
                                label: Text(
                                  'الأكواد النشطة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF16A34A),
                                  side: BorderSide(
                                    color: const Color(0xFF16A34A).withValues(alpha: 0.5),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmBanToggle(
    BuildContext context,
    String teacherId,
    bool isCurrentlyBanned,
    String teacherName,
  ) {
    HapticFeedback.mediumImpact();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            title: Row(
              children: [
                Icon(
                  isCurrentlyBanned ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                  color: isCurrentlyBanned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
                SizedBox(width: 8.w),
                Text(
                  isCurrentlyBanned ? 'فك حظر المعلم' : 'حظر حساب المعلم 🚫',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentlyBanned
                      ? 'هل أنت متأكد من فك الحظر عن المعلم «$teacherName» وتمكينه من الدخول مجدداً؟'
                      : 'هل أنت متأكد من حظر حساب المعلم «$teacherName»؟ سيتم منعه من الدخول فوراً وستظهر له شاشة الحظر.',
                  style: GoogleFonts.cairo(fontSize: 13.sp, height: 1.5),
                ),
                if (!isCurrentlyBanned) ...[
                  SizedBox(height: 14.h),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: 'سبب الحظر (اختياري)...',
                      hintStyle: GoogleFonts.cairo(fontSize: 12.sp),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF64748B))),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  final reason = reasonController.text.trim();
                  _cubit.toggleBanTeacher(
                    teacherId,
                    !isCurrentlyBanned,
                    reason: reason.isNotEmpty ? reason : null,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCurrentlyBanned
                            ? 'تم فك الحظر عن المعلم بنجاح ✅'
                            : 'تم حظر حساب المعلم بنجاح 🚫',
                      ),
                      backgroundColor: isCurrentlyBanned
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentlyBanned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(
                  isCurrentlyBanned ? 'تأكيد فك الحظر' : 'تأكيد الحظر',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
