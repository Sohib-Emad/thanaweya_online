import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/change_password_dialog.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/confirm_sign_out_dialog.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/edit_profile_sheet.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/menu_item.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/notification_settings_sheet.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/profile_header_card.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/section_card.dart';

/// Teacher settings & profile management screen.
class TeacherSettingsScreen extends StatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  State<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  String _currentPlanText = 'ترقية الحساب';
  Color _currentPlanColor = const Color(0xFFD97706);
  bool _notifyNS = true, _notifyEF = true, _notifyLP = true, _notifyCU = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final u = Supabase.instance.client.auth.currentUser;
    if (u == null) return;

    _nameCtl.text = u.userMetadata?['full_name']?.toString() ?? 'معلم منصة ثانوية';
    _emailCtl.text = u.email ?? '';
    _phoneCtl.text = u.userMetadata?['phone']?.toString() ?? '';

    // Load teacher plan from public.teachers table
    try {
      final data = await Supabase.instance.client
          .from('teachers')
          .select('selected_plan, approval_status, subscription_amount')
          .eq('id', u.id)
          .maybeSingle();

      if (data != null && mounted) {
        final plan = data['selected_plan']?.toString() ?? '';
        final status = data['approval_status']?.toString() ?? '';
        setState(() {
          if (plan == 'yearly' || plan == 'annual') {
            _currentPlanText = status == 'approved' ? 'الباقة السنوية (مفعلة)' : 'الباقة السنوية (قيد التفعيل)';
            _currentPlanColor = status == 'approved' ? const Color(0xFF0FA37F) : const Color(0xFFD97706);
          } else if (plan == 'term') {
            _currentPlanText = status == 'approved' ? 'باقة الترم (مفعلة)' : 'باقة الترم (قيد التفعيل)';
            _currentPlanColor = status == 'approved' ? const Color(0xFF0FA37F) : const Color(0xFFD97706);
          } else if (plan == 'monthly') {
            _currentPlanText = status == 'approved' ? 'الباقة الشهرية (مفعلة)' : 'الباقة الشهرية (قيد التفعيل)';
            _currentPlanColor = status == 'approved' ? const Color(0xFF0FA37F) : const Color(0xFFD97706);
          } else {
            _currentPlanText = 'ترقية الحساب';
            _currentPlanColor = const Color(0xFFD97706);
          }
        });
      }
    } catch (_) {}
  }

  String get _idCode {
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '7458';
    return 'T${uid.length >= 5 ? uid.substring(0, 5).toUpperCase() : uid}';
  }

  String get _name => _nameCtl.text.isNotEmpty ? _nameCtl.text : 'معلم منصة ثانوية';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: DeskTopBar(
          title: 'الملف الشخصي والإعدادات',
          subtitle: 'إدارة بيانات الحساب والمنصة والأمان',
          automaticallyImplyBack: false,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
          child: Column(
            children: [
              ProfileHeaderCard(
                name: _name,
                email: _emailCtl.text,
                teacherIdCode: _idCode,
                onEditTap: _openEdit,
              ),
              SizedBox(height: 22.h),

              // ─── Personal Info ───────────────────────────────────────────
              SectionCard(
                children: [
                  MenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'تعديل الملف الشخصي',
                    subtitle: 'الاسم، رقم الهاتف، والبيانات الشخصية',
                    onTap: _openEdit,
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // ─── Security & Notifications ─────────────────────────────────
              SectionCard(
                children: [
                  MenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'تغيير كلمة المرور',
                    subtitle: 'تحديث كلمة سر الحساب للأمان',
                    onTap: () => ChangePasswordDialog.show(context),
                  ),
                  MenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'إعدادات الإشعارات',
                    subtitle: 'تخصيص التنبيهات الفورية',
                    onTap: _openNotif,
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // ─── Subscriptions & Cards & Analytics ───────────────────────
              SectionCard(
                children: [
                  MenuItem(
                    icon: Icons.workspace_premium_outlined,
                    title: 'باقات واشتراكات المعلم',
                    trailingText: _currentPlanText,
                    trailingColor: _currentPlanColor,
                    onTap: () => Navigator.pushNamed(context, AppRouter.teacherPlans).then((_) => _loadData()),
                  ),
                  MenuItem(
                    icon: Icons.analytics_outlined,
                    title: 'التحليلات ومؤشرات الأداء',
                    subtitle: 'معدلات نجاح وتفاعل الطلاب ودرجات الاختبارات',
                    onTap: () => Navigator.pushNamed(context, AppRouter.teacherAnalytics),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // ─── General & Support ─────────────────────────────────────────
              SectionCard(
                children: [
                  MenuItem(
                    icon: Icons.person_pin_rounded,
                    title: 'عن مالك ومبرمج المنصة',
                    subtitle: 'المهندس صهيب عماد - مبرمج التطبيق',
                    onTap: () => Navigator.pushNamed(context, AppRouter.aboutOwner),
                  ),
                  MenuItem(
                    icon: Icons.share_outlined,
                    title: 'دعوة الزملاء',
                    subtitle: 'نسخ رابط المنصة',
                    onTap: _copyLink,
                  ),
                  MenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'الدعم الفني',
                    subtitle: 'تواصل مع فريق الدعم على مدار الساعة',
                    onTap: _snackSupport,
                  ),
                  MenuItem(
                    icon: Icons.description_outlined,
                    title: 'الشروط والخصوصية',
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // ─── Sign Out ──────────────────────────────────────────────────
              SectionCard(
                children: [
                  MenuItem(
                    icon: Icons.logout_rounded,
                    title: 'تسجيل الخروج',
                    subtitle: 'الخروج الآمن من الحساب',
                    isDanger: true,
                    onTap: () => ConfirmSignOutDialog.show(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEdit() {
    EditProfileSheet.show(
      context,
      initialName: _nameCtl.text,
      initialEmail: _emailCtl.text,
      initialPhone: _phoneCtl.text,
      onSaved: () => setState(_loadData),
    );
  }

  void _openNotif() {
    NotificationSettingsSheet.show(
      context,
      notifyNewStudents: _notifyNS,
      notifyExamFinished: _notifyEF,
      notifyLowPerformance: _notifyLP,
      notifyCodeUsed: _notifyCU,
      onNewStudentsChanged: (v) => setState(() => _notifyNS = v),
      onExamFinishedChanged: (v) => setState(() => _notifyEF = v),
      onLowPerformanceChanged: (v) => setState(() => _notifyLP = v),
      onCodeUsedChanged: (v) => setState(() => _notifyCU = v),
    );
  }

  void _copyLink() {
    Clipboard.setData(
      const ClipboardData(text: 'https://thanaweya-online-website.vercel.app/'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ رابط المنصة!', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF0FA37F),
      ),
    );
  }

  void _snackSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('فريق الدعم متاح على مدار الساعة عبر واتساب', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF0FA37F),
      ),
    );
  }
}
