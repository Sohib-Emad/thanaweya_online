import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../data/repos/admin_dashboard_repo.dart';
import '../../logic/admin_dashboard_cubit.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _cubit = AdminDashboardCubit(repo: AdminDashboardRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadDashboard();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
            bloc: _cubit,
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44.r,
                                height: 44.r,
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('لوحة إدارة المنصة',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                  Text('مدير النظام',
                                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.adminPrimaryLight,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text('مسؤول',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.adminPrimary, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                  if (state.status == AdminDashboardStatus.loading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: StatCard(
                        title: 'طلبات معلمين معلقة',
                        value: (state.stats['pending_requests'] ?? 0).toString(),
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: StatCard(
                        title: 'إجمالي المعلمين',
                        value: (state.stats['total_teachers'] ?? 0).toString(),
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.teacherPrimary,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: StatCard(
                        title: 'إجمالي الطلاب',
                        value: (state.stats['total_students'] ?? 0).toString(),
                        icon: Icons.school_rounded,
                        color: AppColors.studentPrimary,
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text('آخر المعلمين المنضمين',
                            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList.separated(
                        itemCount: state.recentTeachers.length,
                        separatorBuilder: (_, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final teacher = state.recentTeachers[index];
                          final users = teacher['users'] as Map<String, dynamic>? ?? {};
                          final name = users['full_name'] as String? ?? '';
                          final initials = name.isNotEmpty ? name[0] : 'م';
                          final subjects = teacher['subjects'] as Map<String, dynamic>? ?? {};
                          return AppCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: AppColors.warning.withAlpha(25),
                                  child: Text(initials,
                                      style: TextStyle(
                                          color: AppColors.warning, fontWeight: FontWeight.w700)),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700)),
                                      SizedBox(height: 2.h),
                                      Text(subjects['name_ar'] as String? ?? '',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          elevation: 1,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.adminPrimary,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outlined), activeIcon: Icon(Icons.people_rounded), label: 'المعلمين'),
            BottomNavigationBarItem(icon: Icon(Icons.subject_rounded), activeIcon: Icon(Icons.subject_rounded), label: 'المواد'),
            BottomNavigationBarItem(icon: Icon(Icons.card_membership_outlined), activeIcon: Icon(Icons.card_membership_rounded), label: 'الباقات'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart_rounded), label: 'التقارير'),
          ],
        ),
      ),
    );
  }
}
