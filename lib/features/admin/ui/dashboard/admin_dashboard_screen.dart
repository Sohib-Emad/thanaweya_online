import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repos/admin_dashboard_repo.dart';
import '../../logic/admin_dashboard_cubit.dart';
import 'widgets/widgets.dart';

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

  void _onNavTap(int index) {
    switch (index) {
      case 1: Navigator.pushNamed(context, AppRouter.adminAllTeachers); break;
      case 2: Navigator.pushNamed(context, AppRouter.adminManageSubjects); break;
      case 3: Navigator.pushNamed(context, AppRouter.adminSubscriptionPlans); break;
      case 4: Navigator.pushNamed(context, AppRouter.adminPlatformReports); break;
    }
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
              return RefreshIndicator(
                onRefresh: () => _cubit.loadDashboard(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0), child: const DashboardHeader()),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                    if (state.status == AdminDashboardStatus.loading)
                      const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                    else ...[
                      SliverToBoxAdapter(child: DashboardStatsList(stats: state.stats)),
                      SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                      const SliverToBoxAdapter(child: AdminQuickActionsGrid()),
                      SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                      const SliverToBoxAdapter(child: AdminSystemModesCard()),
                      SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                      SliverToBoxAdapter(child: RecentTeachersList(teachers: state.recentTeachers)),
                    ],
                    SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: DashboardBottomNav(currentIndex: 0, onTap: _onNavTap),
      ),
    );
  }
}
