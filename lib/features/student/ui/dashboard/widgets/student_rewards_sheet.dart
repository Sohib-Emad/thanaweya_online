import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/student/data/repos/student_rewards_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_rewards_cubit.dart';

/// Modal bottom sheet displaying points balance, daily gift check-in, and point missions.
class StudentRewardsSheet extends StatelessWidget {
  final StudentRewardsCubit cubit;

  const StudentRewardsSheet({super.key, required this.cubit});

  static Future<void> show(BuildContext context, StudentRewardsCubit cubit) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: StudentRewardsSheet(cubit: cubit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.88.sh),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A000000),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: BlocConsumer<StudentRewardsCubit, StudentRewardsState>(
                listener: (context, state) {
                  if (state.justClaimedDaily) {
                    _showCelebrationDialog(context);
                  }
                },
                builder: (context, state) {
                  final summary = state.summary;
                  final totalPoints = summary?.totalPoints ?? 0;
                  final canClaim = summary?.canClaimDaily ?? true;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
                    children: [
                      // Header with Balance & Tier
                      _buildHeaderCard(totalPoints, summary?.tierName ?? 'مبتدئ 🚀'),
                      SizedBox(height: 16.h),

                      // Daily Gift Card
                      _buildDailyGiftCard(context, canClaim, state.status == StudentRewardsStatus.claiming),
                      SizedBox(height: 20.h),

                      // Section Title: Missions
                      Row(
                        children: [
                          Icon(Icons.task_alt_rounded,
                              size: 18.r, color: const Color(0xFF0284C7)),
                          SizedBox(width: 8.w),
                          Text(
                            'مهام كسب النقاط الإضافية',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Missions List
                      ...state.missions.map((m) => _buildMissionCard(context, m)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int totalPoints, String tierName) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رصيد نقاطك الحالي',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.stars_rounded,
                          color: const Color(0xFFF59E0B), size: 28.r),
                      SizedBox(width: 8.w),
                      Text(
                        '$totalPoints',
                        style: GoogleFonts.cairo(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFF8FAFC),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'نقطة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(20),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withAlpha(60),
                  ),
                ),
                child: Text(
                  tierName,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGiftCard(BuildContext context, bool canClaim, bool isClaiming) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canClaim
              ? [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)]
              : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: canClaim
              ? const Color(0xFFF59E0B).withAlpha(120)
              : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: canClaim ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                if (canClaim)
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: const Center(
              child: Text('🎁', style: TextStyle(fontSize: 26)),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6.w,
                  runSpacing: 3.h,
                  children: [
                    Text(
                      'الهدية اليومية',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '+5 نقاط',
                        style: GoogleFonts.cairo(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  canClaim
                      ? 'احصل على 5 نقاط مجانية كل يوم عند فتح التطبيق!'
                      : 'تم تحصيل هدية اليوم بنجاح ✅ (عد غداً)',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (canClaim)
            ElevatedButton(
              onPressed: isClaiming
                  ? null
                  : () {
                      HapticFeedback.heavyImpact();
                      cubit.claimDailyGift();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 2,
              ),
              child: isClaiming
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'تحصيل 🎁',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            )
          else
            Icon(Icons.check_circle_rounded,
                color: const Color(0xFF059669), size: 28.r),
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, PointMission mission) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: mission.isCompleted
              ? const Color(0xFF10B981).withAlpha(80)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(mission.iconEmoji,
                  style: TextStyle(fontSize: 20.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mission.title,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withAlpha(15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFF0284C7).withAlpha(40),
                        ),
                      ),
                      child: Text(
                        '+${mission.pointsReward} نقطة',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  mission.description,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (mission.isCompleted)
            Icon(Icons.check_circle_rounded,
                color: const Color(0xFF10B981), size: 24.r)
          else if (mission.routeToOpen != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              color: const Color(0xFF0284C7),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, mission.routeToOpen!);
              },
            ),
        ],
      ),
    );
  }

  void _showCelebrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              const Text('🎉', style: TextStyle(fontSize: 50)),
              SizedBox(height: 12.h),
              Text(
                'مبروك! حصلت على +5 نقاط',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Text(
                'تمت إضافة نقاط الهدية اليومية إلى رصيدك وترتيبك في لوحة المتفوقين!',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'رائع 🚀',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
