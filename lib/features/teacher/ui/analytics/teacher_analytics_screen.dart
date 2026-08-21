import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/ui/analytics/widgets/widgets.dart';

/// Analytics dashboard showing real student performance metrics,
/// trend charts, challenging exams, and score distribution for the logged-in teacher.
class TeacherAnalyticsScreen extends StatefulWidget {
  const TeacherAnalyticsScreen({super.key});
  @override
  State<TeacherAnalyticsScreen> createState() =>
      _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState extends State<TeacherAnalyticsScreen> {
  int _selectedRange = 2; // Default to 'هذا الشهر'
  static const _ranges = ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذا الفصل'];
  bool _isLoading = true;

  int _totalStudents = 0;
  int _totalCourses = 0;
  int _totalLessons = 0;
  int _totalExams = 0;
  int _totalSubmissions = 0;
  double _averageScore = 0.0;
  double _passRate = 0.0;

  List<Map<String, dynamic>> _rawSubmissions = [];
  List<Map<String, dynamic>> _rawExams = [];
  List<Map<String, dynamic>> _challengingExams = [];

  List<FlSpot> _trendSpots = [];
  String _trendLabel = 'مستقر ↔';
  Color _trendColor = const Color(0xFF0284C7);

  double _excellentRatio = 0.0;
  String _excellentText = '0%';
  double _veryGoodRatio = 0.0;
  String _veryGoodText = '0%';
  double _goodRatio = 0.0;
  String _goodText = '0%';
  double _needsImprovementRatio = 0.0;
  String _needsImprovementText = '0%';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;

    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Load Courses created by this teacher
      final coursesRes = await client
          .from('courses')
          .select('id, title')
          .eq('teacher_id', uid);
      final totalCourses = coursesRes.length;

      // 2. Load Lessons for teacher's courses
      int totalLessons = 0;
      if (totalCourses > 0) {
        final courseIds = coursesRes.map((c) => c['id']).toList();
        final lessonsRes = await client
            .from('lessons')
            .select('id')
            .inFilter('course_id', courseIds);
        totalLessons = lessonsRes.length;
      }

      // 3. Load Exams created by this teacher
      final examsRes = await client
          .from('exams')
          .select('id, title, total_points')
          .eq('teacher_id', uid);
      final totalExams = examsRes.length;
      _rawExams = List<Map<String, dynamic>>.from(examsRes);

      // 4. Load Teacher's real students count
      int studentsCount = 0;
      try {
        final studentsResult = await TeacherStudentsRepo().getStudents(uid);
        studentsResult.when(
          success: (students) => studentsCount = students.length,
          failure: (_, _) {},
        );
      } catch (_) {}

      // 5. Load All Exam Submissions for teacher's exams
      List<Map<String, dynamic>> submissions = [];
      if (totalExams > 0) {
        final examIds = examsRes.map((e) => e['id']).toList();
        try {
          final subsRes = await client
              .from('exam_submissions')
              .select('id, exam_id, score, total_points, submitted_at, student_id')
              .inFilter('exam_id', examIds)
              .order('submitted_at', ascending: true);
          submissions = List<Map<String, dynamic>>.from(subsRes);
        } catch (_) {}
      }
      _rawSubmissions = submissions;

      if (mounted) {
        setState(() {
          _totalCourses = totalCourses;
          _totalLessons = totalLessons;
          _totalExams = totalExams;
          _totalStudents = studentsCount;
        });
        _calculateRangeMetrics();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateRangeMetrics() {
    DateTime? cutoff;
    final now = DateTime.now();
    switch (_selectedRange) {
      case 0: // اليوم
        cutoff = DateTime(now.year, now.month, now.day);
        break;
      case 1: // هذا الأسبوع
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case 2: // هذا الشهر
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case 3: // هذا الفصل
      default:
        cutoff = null;
        break;
    }

    // Filter submissions by date range
    final filtered = cutoff == null
        ? _rawSubmissions
        : _rawSubmissions.where((s) {
            final submittedAtStr = s['submitted_at'] as String?;
            if (submittedAtStr == null || submittedAtStr.isEmpty) return true;
            final date = DateTime.tryParse(submittedAtStr);
            return date == null || date.isAfter(cutoff!);
          }).toList();

    final totalSubs = filtered.length;

    double avgScore = 0.0;
    double passRate = 0.0;
    int excellentCount = 0;
    int veryGoodCount = 0;
    int goodCount = 0;
    int needsImprovementCount = 0;
    int passCount = 0;
    double totalPct = 0;

    for (final sub in filtered) {
      final score = (sub['score'] as num?)?.toDouble() ?? 0.0;
      final max = (sub['total_points'] as num?)?.toDouble() ?? 100.0;
      final pct = max > 0 ? (score / max) * 100 : 0.0;
      totalPct += pct;

      if (pct >= 50.0) {
        passCount++;
      }

      if (pct >= 90.0) {
        excellentCount++;
      } else if (pct >= 80.0) {
        veryGoodCount++;
      } else if (pct >= 65.0) {
        goodCount++;
      } else {
        needsImprovementCount++;
      }
    }

    if (totalSubs > 0) {
      avgScore = totalPct / totalSubs;
      passRate = (passCount / totalSubs) * 100;
    }

    // ─── Challenging Exams Calculation ──────────────────────────────────────
    final examStats = <String, Map<String, dynamic>>{};
    for (final ex in _rawExams) {
      final exId = ex['id'] as String? ?? '';
      examStats[exId] = {
        'title': ex['title'] as String? ?? 'امتحان',
        'submissions': 0,
        'failed': 0,
        'totalPct': 0.0,
      };
    }

    for (final sub in filtered) {
      final exId = sub['exam_id'] as String? ?? '';
      if (examStats.containsKey(exId)) {
        final score = (sub['score'] as num?)?.toDouble() ?? 0.0;
        final max = (sub['total_points'] as num?)?.toDouble() ?? 100.0;
        final pct = max > 0 ? (score / max) * 100 : 0.0;
        examStats[exId]!['submissions'] = (examStats[exId]!['submissions'] as int) + 1;
        examStats[exId]!['totalPct'] = (examStats[exId]!['totalPct'] as double) + pct;
        if (pct < 50.0) {
          examStats[exId]!['failed'] = (examStats[exId]!['failed'] as int) + 1;
        }
      }
    }

    final challengingList = <Map<String, dynamic>>[];
    for (final entry in examStats.entries) {
      final subs = entry.value['submissions'] as int;
      if (subs > 0) {
        final failed = entry.value['failed'] as int;
        final totPct = entry.value['totalPct'] as double;
        final exAvg = totPct / subs;
        final failRate = (failed / subs) * 100;
        challengingList.add({
          'title': entry.value['title'],
          'avg': '${exAvg.toInt()}%',
          'failRate': '${failRate.toInt()}%',
          'failRateNum': failRate,
          'color': failRate >= 30
              ? 0xFFE11D48
              : (failRate >= 15 ? 0xFFEA580C : 0xFFD97706),
        });
      }
    }

    // Sort by failure rate descending
    challengingList.sort((a, b) => (b['failRateNum'] as double).compareTo(a['failRateNum'] as double));

    // ─── Trend Spots Calculation ────────────────────────────────────────────
    final spots = <FlSpot>[];
    if (filtered.length >= 2) {
      final step = (filtered.length / 6).clamp(1, 100).toInt();
      int spotIdx = 0;
      for (int i = 0; i < filtered.length; i += step) {
        final sub = filtered[i];
        final score = (sub['score'] as num?)?.toDouble() ?? 0.0;
        final max = (sub['total_points'] as num?)?.toDouble() ?? 100.0;
        final pct = max > 0 ? (score / max) * 100 : 70.0;
        spots.add(FlSpot(spotIdx.toDouble(), pct));
        spotIdx++;
        if (spots.length >= 6) break;
      }
    }

    String trendLabel = 'مستقر ↔';
    Color trendColor = const Color(0xFF0284C7);
    if (spots.length >= 2) {
      final first = spots.first.y;
      final last = spots.last.y;
      if (last > first + 3) {
        trendLabel = 'تصاعدي ↗';
        trendColor = const Color(0xFF16A34A);
      } else if (last < first - 3) {
        trendLabel = 'تراجعي ↘';
        trendColor = const Color(0xFFE11D48);
      }
    }

    setState(() {
      _totalSubmissions = totalSubs;
      _averageScore = avgScore;
      _passRate = passRate;
      _challengingExams = challengingList.take(4).toList();
      _trendSpots = spots;
      _trendLabel = trendLabel;
      _trendColor = trendColor;

      _excellentRatio = totalSubs > 0 ? excellentCount / totalSubs : 0.0;
      _excellentText = '${(_excellentRatio * 100).toInt()}% ($excellentCount)';
      _veryGoodRatio = totalSubs > 0 ? veryGoodCount / totalSubs : 0.0;
      _veryGoodText = '${(_veryGoodRatio * 100).toInt()}% ($veryGoodCount)';
      _goodRatio = totalSubs > 0 ? goodCount / totalSubs : 0.0;
      _goodText = '${(_goodRatio * 100).toInt()}% ($goodCount)';
      _needsImprovementRatio = totalSubs > 0 ? needsImprovementCount / totalSubs : 0.0;
      _needsImprovementText = '${(_needsImprovementRatio * 100).toInt()}% ($needsImprovementCount)';

      _isLoading = false;
    });
  }

  void _onRangeChanged(int index) {
    setState(() => _selectedRange = index);
    _calculateRangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'التحليلات ومؤشرات الأداء',
          subtitle:
              'معدلات نجاح الطلاب، الامتحانات الصعبة، وتوزيع الدرجات',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.all(18.r),
                    children: [
                      RangeFilter(
                        selectedIndex: _selectedRange,
                        ranges: _ranges,
                        onSelected: _onRangeChanged,
                      ),
                      SizedBox(height: 16.h),
                      _buildTopMetricsGrid(),
                      SizedBox(height: 18.h),
                      PerformanceTrendChart(
                        spots: _trendSpots,
                        trendLabel: _trendLabel,
                        trendColor: _trendColor,
                      ),
                      SizedBox(height: 18.h),
                      ChallengingExamsList(
                        exams: _challengingExams,
                      ),
                      SizedBox(height: 18.h),
                      ScoreDistributionChart(
                        excellentRatio: _excellentRatio,
                        excellentText: _excellentText,
                        veryGoodRatio: _veryGoodRatio,
                        veryGoodText: _veryGoodText,
                        goodRatio: _goodRatio,
                        goodText: _goodText,
                        needsImprovementRatio: _needsImprovementRatio,
                        needsImprovementText: _needsImprovementText,
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopMetricsGrid() {
    final avgScoreText = _totalSubmissions > 0
        ? '${_averageScore.toStringAsFixed(1)}%'
        : '0.0%';
    final passRateText = _totalSubmissions > 0
        ? '${_passRate.toStringAsFixed(1)}%'
        : '0.0%';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: 'متوسط درجات الطلاب',
                value: avgScoreText,
                subtitle: _totalSubmissions > 0
                    ? 'بناءً على $_totalSubmissions حل مكتمل'
                    : 'لا توجد اختبارات مسجلة بعد',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF0FA37F),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: MetricTile(
                title: 'نسبة النجاح العامة',
                value: passRateText,
                subtitle: _totalStudents > 0
                    ? 'لدى $_totalStudents طالب مسجل 🎯'
                    : 'لا يوجد طلاب مشتركين بعد',
                icon: Icons.verified_outlined,
                color: const Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: 'الدورات والدروس',
                value: '$_totalCourses كورس',
                subtitle: '$_totalLessons درس تعليمي',
                icon: Icons.play_circle_outline_rounded,
                color: const Color(0xFF9333EA),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: MetricTile(
                title: 'إجمالي الاختبارات',
                value: '$_totalExams اختبار',
                subtitle: '$_totalSubmissions حل مكتمل',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
