import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_reports_repo.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'package:thanaweya_online/features/shared/widgets/stat_card.dart';

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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final res = await _repo.getPlatformReports();
    if (!mounted) return;

    res.when(
      success: (data) => setState(() {
        _data = data;
        _isLoading = false;
      }),
      failure: (msg, _) => setState(() {
        _error = msg;
        _isLoading = false;
      }),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث البيانات',
              onPressed: _loadReports,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _data == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 56.r, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(_error!, style: AppTextStyles.body2, textAlign: TextAlign.center),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: _loadReports,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final d = _data!;
    final teacherApprovalRate = d.totalTeachers > 0
        ? ((d.approvedTeachers / d.totalTeachers) * 100).toInt()
        : 100;
    final publishedCourseRate = d.totalCourses > 0
        ? ((d.publishedCourses / d.totalCourses) * 100).toInt()
        : 100;

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),

          // ─── Key Stats Grid ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: StatCard(
              title: 'إجمالي المستخدمين المسجلين',
              value: '${d.totalUsers}',
              subtitle: '👨‍🎓 ${d.totalStudents} طالب  |  👨‍🏫 ${d.totalTeachers} معلم',
              icon: Icons.people_alt_rounded,
              color: AppColors.teacherPrimary,
            ),
          ),
          SliverToBoxAdapter(
            child: StatCard(
              title: 'الاشتراكات النشطة والإيرادات',
              value: '${d.activeSubscriptions} اشتراك',
              subtitle: 'إجمالي المحصل: ${d.estimatedRevenue.toStringAsFixed(0)} ج.م',
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.success,
            ),
          ),
          SliverToBoxAdapter(
            child: StatCard(
              title: 'المحتوى والدروس',
              value: '${d.totalCourses} دورة تدريبية',
              subtitle: '📚 ${d.totalLessons} درس  |  📝 ${d.totalExams} اختبار',
              icon: Icons.video_library_rounded,
              color: AppColors.adminPrimary,
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20.h)),

          // ─── Teachers Status Breakdown ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text('حالة طلبات المعلمين', style: AppTextStyles.h3),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
          SliverToBoxAdapter(
            child: AppCard(
              child: Column(
                children: [
                  _ReportRow(
                    label: 'المعلمون المعتمدون',
                    value: '${d.approvedTeachers}',
                    badgeColor: AppColors.success,
                  ),
                  Divider(height: 20.h),
                  _ReportRow(
                    label: 'طلبات قيد المراجعة',
                    value: '${d.pendingTeachers}',
                    badgeColor: AppColors.warning,
                  ),
                  Divider(height: 20.h),
                  _ReportRow(
                    label: 'طلبات مرفوضة',
                    value: '${d.rejectedTeachers}',
                    badgeColor: AppColors.error,
                  ),
                  Divider(height: 20.h),
                  _ReportRow(
                    label: 'معدل القبول والتفعيل',
                    value: '$teacherApprovalRate%',
                    badgeColor: AppColors.adminPrimary,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // ─── Platform Performance Summary ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text('مؤشرات أداء المنصة', style: AppTextStyles.h3),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
          SliverToBoxAdapter(
            child: AppCard(
              child: Column(
                children: [
                  _ReportRow(label: 'الدورات المنشورة', value: '${d.publishedCourses} من ${d.totalCourses} ($publishedCourseRate%)'),
                  Divider(height: 20.h),
                  _ReportRow(label: 'إجمالي الدروس المرفوعة', value: '${d.totalLessons} درس'),
                  Divider(height: 20.h),
                  _ReportRow(label: 'إجمالي الاختبارات المنشأة', value: '${d.totalExams} اختبار'),
                  Divider(height: 20.h),
                  _ReportRow(label: 'إجمالي حلول الطلاب للاختبارات', value: '${d.totalSubmissions} إجابة'),
                ],
              ),
            ),
          ),

          // ─── Subject Distribution ────────────────────────────────────────
          if (d.subjectDistribution.isNotEmpty) ...[
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text('توزيع المعلمين حسب المواد', style: AppTextStyles.h3),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            SliverToBoxAdapter(
              child: AppCard(
                child: Column(
                  children: [
                    for (int i = 0; i < d.subjectDistribution.length; i++) ...[
                      if (i > 0) Divider(height: 18.h),
                      _ReportRow(
                        label: d.subjectDistribution[i]['name'] as String? ?? 'مادة',
                        value: '${d.subjectDistribution[i]['count']} معلم',
                        badgeColor: AppColors.studentPrimary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? badgeColor;

  const _ReportRow({
    required this.label,
    required this.value,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (badgeColor != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: badgeColor!.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
          ),
      ],
    );
  }
}
