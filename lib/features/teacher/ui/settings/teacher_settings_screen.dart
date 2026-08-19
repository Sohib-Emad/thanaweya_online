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
  final _academyCtl = TextEditingController();
  final _subjectCtl = TextEditingController();
  bool _notifyNS = true, _notifyEF = true, _notifyLP = true, _notifyCU = true;

  @override
  void initState() { super.initState(); _loadData(); }

  @override
  void dispose() {
    _nameCtl.dispose(); _emailCtl.dispose(); _phoneCtl.dispose();
    _academyCtl.dispose(); _subjectCtl.dispose();
    super.dispose();
  }

  void _loadData() {
    final u = Supabase.instance.client.auth.currentUser;
    if (u == null) return;
    _nameCtl.text = u.userMetadata?['full_name']?.toString() ?? 'أحمد محمود';
    _emailCtl.text = u.email ?? '';
    _phoneCtl.text = u.userMetadata?['phone']?.toString() ?? '01012345678';
    _academyCtl.text = u.userMetadata?['academy_name']?.toString() ?? 'أكاديمية المتفوقين';
    _subjectCtl.text = u.userMetadata?['subject']?.toString() ?? 'الفيزياء والكيمياء';
  }

  String get _idCode {
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '7458';
    return 'T${uid.length >= 5 ? uid.substring(0, 5).toUpperCase() : uid}';
  }

  String get _name => _nameCtl.text.isNotEmpty ? _nameCtl.text : 'أحمد محمود';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: DeskTopBar(title: 'الملف الشخصي والإعدادات', subtitle: 'إدارة بيانات الحساب والمنصة والأمان', automaticallyImplyBack: false),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
          child: Column(children: [
            ProfileHeaderCard(name: _name, email: _emailCtl.text, teacherIdCode: _idCode, onEditTap: _openEdit),
            SizedBox(height: 22.h),
            SectionCard(children: [
              MenuItem(icon: Icons.person_outline_rounded, title: 'تعديل الملف الشخصي', subtitle: 'الاسم، رقم الهاتف، والمسمى الأكاديمي', onTap: _openEdit),
              MenuItem(icon: Icons.school_outlined, title: 'اسم الأكاديمية والمنصة', trailingText: _academyCtl.text, onTap: _openEdit),
              MenuItem(icon: Icons.subject_rounded, title: 'المادة والتخصص', trailingText: _subjectCtl.text, onTap: _openEdit),
            ]),
            SizedBox(height: 14.h),
            SectionCard(children: [
              MenuItem(icon: Icons.lock_outline_rounded, title: 'تغيير كلمة المرور', subtitle: 'تحديث كلمة سر الحساب للأمان', onTap: () => ChangePasswordDialog.show(context)),
              MenuItem(icon: Icons.notifications_none_rounded, title: 'إعدادات الإشعارات', subtitle: 'تخصيص التنبيهات الفورية', onTap: _openNotif),
            ]),
            SizedBox(height: 14.h),
            SectionCard(children: [
              MenuItem(icon: Icons.workspace_premium_outlined, title: 'باقات واشتراكات المعلم', trailingText: 'ترقية الحساب', trailingColor: const Color(0xFFD97706), onTap: () => Navigator.pushNamed(context, AppRouter.teacherPlans)),
              MenuItem(icon: Icons.vpn_key_outlined, title: 'أكواد التفعيل', subtitle: 'توليد وإدارة كروت الاشتراك', onTap: () => Navigator.pushNamed(context, AppRouter.teacherCards)),
              MenuItem(icon: Icons.analytics_outlined, title: 'التحليلات', subtitle: 'معدلات نجاح وتفاعل الطلاب', onTap: () => Navigator.pushNamed(context, AppRouter.teacherAnalytics)),
            ]),
            SizedBox(height: 14.h),
            SectionCard(children: [
              MenuItem(icon: Icons.translate_rounded, title: 'لغة التطبيق', trailingText: 'العربية (مصر)', onTap: () {}),
              MenuItem(icon: Icons.share_outlined, title: 'دعوة الزملاء', subtitle: 'نسخ رابط المنصة', onTap: _copyLink),
              MenuItem(icon: Icons.help_outline_rounded, title: 'الدعم الفني', subtitle: 'تواصل مع فريق الدعم', onTap: _snackSupport),
              MenuItem(icon: Icons.description_outlined, title: 'الشروط والخصوصية', onTap: () {}),
            ]),
            SizedBox(height: 14.h),
            SectionCard(children: [
              MenuItem(icon: Icons.logout_rounded, title: 'تسجيل الخروج', subtitle: 'الخروج الآمن من الحساب', isDanger: true, onTap: () => ConfirmSignOutDialog.show(context)),
            ]),
          ]),
        ),
      ),
    );
  }

  void _openEdit() {
    EditProfileSheet.show(context,
        initialName: _nameCtl.text, initialEmail: _emailCtl.text,
        initialPhone: _phoneCtl.text, initialAcademy: _academyCtl.text,
        initialSubject: _subjectCtl.text, onSaved: () => setState(_loadData));
  }

  void _openNotif() {
    NotificationSettingsSheet.show(context,
        notifyNewStudents: _notifyNS, notifyExamFinished: _notifyEF,
        notifyLowPerformance: _notifyLP, notifyCodeUsed: _notifyCU,
        onNewStudentsChanged: (v) => setState(() => _notifyNS = v),
        onExamFinishedChanged: (v) => setState(() => _notifyEF = v),
        onLowPerformanceChanged: (v) => setState(() => _notifyLP = v),
        onCodeUsedChanged: (v) => setState(() => _notifyCU = v));
  }

  void _copyLink() {
    Clipboard.setData(const ClipboardData(text: 'https://thanaweya.online/app'));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم نسخ رابط المنصة!', style: GoogleFonts.cairo()), backgroundColor: const Color(0xFF0284C7)));
  }

  void _snackSupport() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فريق الدعم متاح على مدار الساعة', style: GoogleFonts.cairo()), backgroundColor: const Color(0xFF0284C7)));
  }
}
