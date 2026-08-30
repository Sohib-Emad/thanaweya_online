import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_reports_repo.dart';
import 'package:thanaweya_online/features/shared/widgets/stat_card.dart';
import 'widgets/reports_teacher_status_card.dart';
import 'widgets/reports_performance_card.dart';
import 'widgets/reports_subject_distribution_card.dart';

class PlatformReportsScreen extends StatefulWidget {
  const PlatformReportsScreen({super.key});

  @override
  State<PlatformReportsScreen> createState() => _PlatformReportsScreenState();
}

class _PlatformReportsScreenState extends State<PlatformReportsScreen> {
  final _repo = AdminReportsRepo();
  AdminReportsData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() { _isLoading = true; _error = null; });
    final res = await _repo.getPlatformReports();
    if (!mounted) return;
    res.when(
      success: (data) => setState(() { _data = data; _isLoading = false; }),
      failure: (msg, _) => setState(() { _error = msg; _isLoading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.platformReports),
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'تحديث البيانات', onPressed: _loadReports)],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _data == null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline_rounded, size: 56.r, color: AppColors.error),
        SizedBox(height: 16.h),
        Text(_error!, style: AppTextStyles.body2),
        SizedBox(height: 20.h),
        ElevatedButton.icon(onPressed: _loadReports, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
      ]));
    }

    final d = _data!;
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          SliverToBoxAdapter(child: StatCard(title: 'إجمالي المستخدمين المسجلين', value: '${d.totalUsers}', subtitle: '👨‍🎓 ${d.totalStudents} طالب  |  👨‍🏫 ${d.totalTeachers} معلم', icon: Icons.people_alt_rounded, color: AppColors.teacherPrimary)),
          SliverToBoxAdapter(child: StatCard(title: 'الاشتراكات النشطة والإيرادات', value: '${d.activeSubscriptions} اشتراك', subtitle: 'إجمالي المحصل: ${d.estimatedRevenue.toStringAsFixed(0)} ج.م', icon: Icons.account_balance_wallet_rounded, color: AppColors.success)),
          SliverToBoxAdapter(child: StatCard(title: 'المحتوى والدروس', value: '${d.totalCourses} دورة تدريبية', subtitle: '📚 ${d.totalLessons} درس  |  📝 ${d.totalExams} اختبار', icon: Icons.video_library_rounded, color: AppColors.adminPrimary)),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverToBoxAdapter(child: ReportsTeacherStatusCard(data: d)),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          SliverToBoxAdapter(child: ReportsPerformanceCard(data: d)),
          if (d.subjectDistribution.isNotEmpty) ...[
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            SliverToBoxAdapter(child: ReportsSubjectDistributionCard(subjectDistribution: d.subjectDistribution)),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
    );
  }
}
