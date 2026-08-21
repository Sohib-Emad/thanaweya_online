import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen showcasing the Platform Owner and Lead Flutter Developer (Sohib Emad).
class AboutOwnerScreen extends StatelessWidget {
  const AboutOwnerScreen({super.key});

  static const String _phone = '201096462825';
  static const String _displayPhone = '01096462825';

  Future<void> _openWhatsApp(BuildContext context) async {
    HapticFeedback.lightImpact();
    final url =
        'https://wa.me/$_phone?text=${Uri.encodeComponent('مرحباً بشمهندس صهيب، أتواصل معك بخصوص منصة ثانوية أونلاين.')}';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showSnack(context, 'تعذر فتح تطبيق واتساب');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'تعذر فتح الرابط');
      }
    }
  }

  Future<void> _makeCall(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('tel:$_displayPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showSnack(context, 'تعذر إجراء المكالمة');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, 'تعذر بدء الاتصال');
      }
    }
  }

  void _copyPhone(BuildContext context) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(const ClipboardData(text: _displayPhone));
    _showSnack(context, 'تم نسخ رقم الهاتف: $_displayPhone ✅');
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'عن مالك ومبرمج المنصة',
            style: GoogleFonts.cairo(
              color: const Color(0xFF0F172A),
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Profile Hero Card ───────────────────────────────────────
              _buildHeroCard(),
              SizedBox(height: 16.h),

              // ─── Contact Action Buttons ──────────────────────────────────
              _buildQuickContactRow(context),
              SizedBox(height: 20.h),

              // ─── Experience & Roles ──────────────────────────────────────
              _buildSectionTitle(
                'الخبرات والمسؤوليات البرمجية',
                Icons.work_outline_rounded,
              ),
              SizedBox(height: 10.h),
              _buildRolesCard(),
              SizedBox(height: 20.h),

              // ─── About Platform Vision ───────────────────────────────────
              _buildSectionTitle(
                'رؤية منصة ثانوية أونلاين',
                Icons.lightbulb_outline_rounded,
              ),
              SizedBox(height: 10.h),
              _buildVisionCard(),
              SizedBox(height: 20.h),

              // ─── Footer ──────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'تم تطوير التطبيق بكل شغف ودقة ❤️',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'جميع الحقوق محفوظة © منصة ثانوية أونلاين',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      child: Column(
        children: [
          // Avatar with badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/owner.png',
                    width: 105.r,
                    height: 105.r,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 105.r,
                      height: 105.r,
                      color: const Color(0xFF334155),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF0284C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Name
          Text(
            'Sohib Emad | صهيب عماد',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Main Title
          Text(
            'Software Engineer | Flutter Developer',
            style: GoogleFonts.poppins(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF38BDF8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),

          // Location badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFF87171),
                  size: 15,
                ),
                SizedBox(width: 5.w),
                Text(
                  'البحيرة، مصر (El Beheira, Egypt)',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: const Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactRow(BuildContext context) {
    return Row(
      children: [
        // WhatsApp Button
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: () => _openWhatsApp(context),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              'تواصل واتساب',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 2,
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // Phone Call Button
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () => _makeCall(context),
            icon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF0F172A),
              size: 18,
            ),
            label: Text(
              'اتصال',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // Copy Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: IconButton(
            tooltip: 'نسخ الرقم',
            icon: const Icon(
              Icons.copy_rounded,
              color: Color(0xFF475569),
              size: 20,
            ),
            onPressed: () => _copyPhone(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0284C7), size: 20),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildRolesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          _buildRoleItem(
            icon: Icons.rocket_launch_rounded,
            iconColor: const Color(0xFF0284C7),
            title: 'Founder & Lead Mobile Developer',
            company: 'منصة ثانوية أونلاين (Thanaweya Online)',
            description:
                'تصميم وبناء البنية المعمارية الكاملة لتطبيق الطالب والمعلم ولوحة الأدمن بأعلى معايير الجودة والأمان.',
          ),
          Divider(height: 24.h, color: const Color(0xFFF1F5F9)),
          _buildRoleItem(
            icon: Icons.laptop_mac_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Freelance Flutter Developer',
            company: 'العمل الحر (Freelancing Projects)',
            description:
                'بناء وتطوير تطبيقات الموبايل المتكاملة وتقديم استشارات وحلول برمجية للعملاء والمشاريع الناشئة.',
          ),
          Divider(height: 24.h, color: const Color(0xFFF1F5F9)),
          _buildRoleItem(
            icon: Icons.groups_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'IT Member & Flutter Developer',
            company: 'GDG Damanhur (Google Developer Groups)',
            description:
                'عضو فعال في مجتمع المطورين والمساهمة في الفعاليات والأنشطة التقنية.',
          ),
          Divider(height: 24.h, color: const Color(0xFFF1F5F9)),
          _buildRoleItem(
            icon: Icons.code_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Junior Flutter Developer (سابقاً)',
            company: 'Buildyounique (سابقاً)',
            description:
                'تطوير واجهات المستخدم التفاعلية وإدارة الحالة وحلول تطبيقات الهواتف الذكية.',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String company,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                company,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                description,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  color: const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نهدف في منصة ثانوية أونلاين إلى إعادة تعريف تجربة التعليم الإلكتروني لطلاب ومعلمي الثانوية العامة في مصر، عبر توفير بيئة تعليمية ذكية، متكاملة، وآمنة تضمن سهولة المتابعة والتقييم المستمر بأحدث التقنيات.',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: const Color(0xFF334155),
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
