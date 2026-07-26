import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/courses_list_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/students/students_list_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeDashboardView(context),
              const CoursesListScreen(),
              const StudentsListScreen(),
              const StudentsListScreen(),
              _buildSettingsDashboardView(context),
            ],
          ),
        ),
        bottomNavigationBar: _buildFloatingBottomNavBar(),
      ),
    );
  }

  // 1. Executive KPI Home Dashboard View (Tab 0)
  Widget _buildHomeDashboardView(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Greeting + Profile Avatar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً بك في لوحة التحكّم 👋',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          MockData.mockUserName,
                          style: GoogleFonts.cairo(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),

                    // Avatar Container with Emerald Border
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 4),
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFECFDF5),
                          border: Border.all(
                            color: const Color(0xFF0FA37F),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x150FA37F),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22.r,
                          backgroundColor: AppColors.teacherPrimaryLight,
                          child: Icon(
                            Icons.person_rounded,
                            size: 26.r,
                            color: AppColors.teacherPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Primary Featured Revenue & Subscription KPI Hero Card
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0FA37F), Color(0xFF065F46)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x250FA37F),
                        blurRadius: 16,
                        offset: Offset(0, 8),
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
                              Row(
                                children: [
                                  Text(
                                    'أرباح الشهر الحالي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      color: const Color(0xFFA7F3D0),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up_rounded,
                                          color: Colors.white,
                                          size: 12.r,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '+18.5%',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '54,800 ج.م',
                                style: GoogleFonts.cairo(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 28.r,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Divider(color: Colors.white.withAlpha(40), height: 1),
                      SizedBox(height: 14.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderMetricItem(
                            'الطلاب المتنشطين',
                            '1,420 طالب',
                          ),
                          Container(
                            height: 24.h,
                            width: 1,
                            color: Colors.white.withAlpha(40),
                          ),
                          _buildHeaderMetricItem('أكواد التفعيل', '980 كود'),
                          Container(
                            height: 24.h,
                            width: 1,
                            color: Colors.white.withAlpha(40),
                          ),
                          _buildHeaderMetricItem('عدد الكورسات', '12 كورس'),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Core Key Performance Indicators (4 KPI Grid)
                Row(
                  children: [
                    Text(
                      'مؤشرات الأداء الرئيسية (KPIs)',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.analytics_rounded,
                      color: AppColors.teacherPrimary,
                      size: 20.r,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.25,
                  children: [
                    _buildKpiCard(
                      title: 'إجمالي المشتركين',
                      value: '1,420',
                      subtext: '+120 هذا الأسبوع',
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                    _buildKpiCard(
                      title: 'معدل الحضور',
                      value: '94.2%',
                      subtext: 'تفاعل ممتاز',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                    _buildKpiCard(
                      title: 'نسبة النجاح',
                      value: '88.5%',
                      subtext: 'متوسط 88/100',
                      icon: Icons.auto_awesome_rounded,
                      color: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFFFBEB),
                    ),
                    _buildKpiCard(
                      title: 'ساعات المشاهدة',
                      value: '4,850 س',
                      subtext: 'أكثر من الشهر الماضي',
                      icon: Icons.play_circle_fill_rounded,
                      color: const Color(0xFF9333EA),
                      bgColor: const Color(0xFFF3E8FF),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // Quick Action Buttons Section
                Text(
                  'الإجراءات السريعة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'إضافة كورس',
                        color: const Color(0xFF0FA37F),
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.qr_code_2_rounded,
                        label: 'أكواد تفعيل',
                        color: const Color(0xFF2563EB),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.teacherActivationCodes,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.quiz_rounded,
                        label: 'إنشاء امتحان',
                        color: const Color(0xFFD97706),
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // System Breakdown KPIs (الثانوية العامة vs البكالوريا IB)
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x050F172A),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'توزيع الطلاب حسب النظام 📊',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '1,420 طالب',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Stacked Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: SizedBox(
                          height: 12.h,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 78,
                                child: Container(
                                  color: const Color(0xFF0FA37F),
                                ),
                              ),
                              Expanded(
                                flex: 22,
                                child: Container(
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSystemLegendItem(
                            title: 'الثانوية العامة (قديم)',
                            percentage: '78%',
                            count: '1,107 طالب',
                            color: const Color(0xFF0FA37F),
                          ),
                          _buildSystemLegendItem(
                            title: 'نظام البكالوريا (IB)',
                            percentage: '22%',
                            count: '313 طالب',
                            color: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // Recent Student Subscriptions Live Stream
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أحدث المشتركين الجدد',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _currentIndex = 2),
                      child: Text(
                        'عرض قائمة الطلاب',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: const Color(0xFF0FA37F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                _buildRecentSubscriptionItem(
                  studentName: 'أحمد محمود العبد',
                  subject: 'مراجعة الفيزياء الكهربية',
                  system: 'ثانوية عامة (قديم)',
                  time: 'منذ 5 دقائق',
                  isActivated: true,
                ),
                SizedBox(height: 10.h),
                _buildRecentSubscriptionItem(
                  studentName: 'سارة محمد الشريف',
                  subject: 'مسار الطب وعلوم الحياة (IB)',
                  system: 'البكالوريا (IB)',
                  time: 'منذ 25 دقيقة',
                  isActivated: true,
                ),
                SizedBox(height: 10.h),
                _buildRecentSubscriptionItem(
                  studentName: 'عمر خالد حسن',
                  subject: 'الفيزياء الحديثة والتطبيقية',
                  system: 'ثانوية عامة (قديم)',
                  time: 'منذ ساعة',
                  isActivated: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10.sp,
            color: const Color(0xFFA7F3D0),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 20.r),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: const Color(0xFF10B981),
                size: 16.r,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtext,
                style: GoogleFonts.cairo(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x050F172A),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22.r),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemLegendItem({
    required String title,
    required String percentage,
    required String count,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ($percentage)',
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              count,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSubscriptionItem({
    required String studentName,
    required String subject,
    required String system,
    required String time,
    required bool isActivated,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: const Color(0xFFECFDF5),
            child: Icon(
              Icons.person_rounded,
              color: const Color(0xFF0FA37F),
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      studentName,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: system.contains('IB')
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        system,
                        style: GoogleFonts.cairo(
                          fontSize: 9.sp,
                          color: system.contains('IB')
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF0FA37F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Settings View (Tab 4)
  Widget _buildSettingsDashboardView(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات والملف الشخصي ⚙️',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 20.h),

          // Profile Header Card
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.teacherPrimaryLight,
                  child: Icon(
                    Icons.person_rounded,
                    size: 32.r,
                    color: AppColors.teacherPrimary,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MockData.mockUserName,
                        style: GoogleFonts.cairo(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'معلم فيزياء | الثانوية العامة',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          _LightSettingsOptionRow(
            icon: Icons.person_outline_rounded,
            title: 'تعديل الملف الشخصي والبيانات',
            onTap: () {},
          ),
          SizedBox(height: 10.h),
          _LightSettingsOptionRow(
            icon: Icons.notifications_none_rounded,
            title: 'إعدادات الإشعارات والتنبيهات',
            onTap: () {
              Navigator.pushNamed(context, AppRouter.notifications);
            },
          ),
          SizedBox(height: 10.h),
          _LightSettingsOptionRow(
            icon: Icons.qr_code_2_rounded,
            title: 'أكواد التفعيل المتاحة',
            onTap: () {
              Navigator.pushNamed(context, AppRouter.teacherActivationCodes);
            },
          ),

          SizedBox(height: 32.h),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.roleSelection,
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              icon: Icon(Icons.logout_rounded, size: 20.r),
              label: Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Floating Light Bottom Navigation Bar with Central Hero Circular Action Button
  Widget _buildFloatingBottomNavBar() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0F172A),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LightNavBarItem(
              icon: Icons.home_filled,
              isSelected: _currentIndex == 0,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 0);
              },
            ),
            _LightNavBarItem(
              icon: Icons.grid_view_rounded,
              isSelected: _currentIndex == 1,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 1);
              },
            ),

            // Central Hero Floating Circular Action Button (Add Course / Action)
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                _showQuickCreateModal(context);
              },
              child: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0FA37F), Color(0xFF10B981)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x500FA37F),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.add_rounded, color: Colors.white, size: 28.r),
              ),
            ),

            _LightNavBarItem(
              icon: Icons.people_alt_rounded,
              isSelected: _currentIndex == 3,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 3);
              },
            ),
            _LightNavBarItem(
              icon: Icons.person_rounded,
              isSelected: _currentIndex == 4,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 4);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'إجراء سريع جديد ✨',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 20.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      color: const Color(0xFF0FA37F),
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'إنشاء دورة تعليمية جديدة',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.teacherCourses);
                  },
                ),
                const Divider(color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: const Color(0xFFD97706),
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'إنشاء اختبار إلكتروني جديد',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.teacherExams);
                  },
                ),
                const Divider(color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      color: const Color(0xFF9333EA),
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'توليد أكواد تفعيل للطلاب',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRouter.teacherActivationCodes,
                    );
                  },
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Light Navigation Bar Item Widget
class _LightNavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LightNavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24.r,
          color: isSelected ? const Color(0xFF0FA37F) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _LightSettingsOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LightSettingsOptionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF64748B), size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              size: 22.r,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
