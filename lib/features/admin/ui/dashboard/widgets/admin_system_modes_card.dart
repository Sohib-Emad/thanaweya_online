import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/services/app_system_config_repo.dart';

/// Card for admins to toggle Maintenance Mode and Force Update Mode.
class AdminSystemModesCard extends StatefulWidget {
  const AdminSystemModesCard({super.key});

  @override
  State<AdminSystemModesCard> createState() => _AdminSystemModesCardState();
}

class _AdminSystemModesCardState extends State<AdminSystemModesCard> {
  final _configRepo = AppSystemConfigRepo();
  late AppSystemConfig _config;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _config = _configRepo.cachedConfig;
    _refreshConfig();
  }

  Future<void> _refreshConfig() async {
    final fresh = await _configRepo.fetchConfig();
    if (mounted) {
      setState(() => _config = fresh);
    }
  }

  void _showMaintenanceDialog(bool turnOn) {
    if (!turnOn) {
      _toggleMaintenance(false, _config.maintenanceMessage);
      return;
    }

    final msgCtrl = TextEditingController(text: _config.maintenanceMessage);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              const Icon(Icons.build_circle_rounded, color: Color(0xFFF59E0B)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'تفعيل وضع الصيانة والإصلاح 🛠️',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15.sp),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'عند تفعيل هذا الوضع، سيتم إغلاق التطبيق في وجه كافة المستخدمين وتوجيههم لشاشة الصيانة.',
                style: GoogleFonts.cairo(fontSize: 12.5.sp, color: const Color(0xFF475569)),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                style: GoogleFonts.cairo(fontSize: 12.5.sp),
                decoration: InputDecoration(
                  labelText: 'رسالة الصيانة للمستخدمين',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _toggleMaintenance(true, msgCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('تفعيل الصيانة الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMaintenance(bool on, String msg) async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await _configRepo.setMaintenanceMode(enabled: on, message: msg.isNotEmpty ? msg : null);
    if (mounted) {
      setState(() {
        _config = _configRepo.cachedConfig;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(on ? 'تم تفعيل وضع الصيانة 🛠️' : 'تم إيقاف وضع الصيانة وعودة التطبيق للعمل ✅'),
          backgroundColor: on ? const Color(0xFFF59E0B) : const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUpdateDialog(bool turnOn) {
    if (!turnOn) {
      _toggleUpdate(false, _config.updateMessage, _config.updateUrl);
      return;
    }

    final msgCtrl = TextEditingController(text: _config.updateMessage);
    final urlCtrl = TextEditingController(text: _config.updateUrl);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              const Icon(Icons.system_update_rounded, color: Color(0xFF0284C7)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'تفعيل وضع التحديث الإجباري 🚀',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15.sp),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'عند تفعيل هذا الوضع، سيُلزم جميع المستخدمين بتحديث التطبيق ولن يتمكنوا من التخطي.',
                style: GoogleFonts.cairo(fontSize: 12.5.sp, color: const Color(0xFF475569)),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: msgCtrl,
                maxLines: 2,
                style: GoogleFonts.cairo(fontSize: 12.5.sp),
                decoration: InputDecoration(
                  labelText: 'رسالة التحديث',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: urlCtrl,
                style: GoogleFonts.cairo(fontSize: 12.5.sp),
                decoration: InputDecoration(
                  labelText: 'رابط التحديث / المتجر',
                  labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _toggleUpdate(true, msgCtrl.text.trim(), urlCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('تفعيل التحديث الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUpdate(bool on, String msg, String url) async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await _configRepo.setUpdateMode(
      enabled: on,
      message: msg.isNotEmpty ? msg : null,
      updateUrl: url.isNotEmpty ? url : null,
    );
    if (mounted) {
      setState(() {
        _config = _configRepo.cachedConfig;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(on ? 'تم تفعيل وضع التحديث الإجباري 🚀' : 'تم إيقاف وضع التحديث الإجباري ✅'),
          backgroundColor: on ? const Color(0xFF0284C7) : const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.settings_suggest_rounded, color: Color(0xFF7C3AED), size: 20),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التحكم في حالة التطبيق العامة',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'وضع الصيانة والإصلاح والتحديث الإجباري لكافة المستخدمين',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1),
          SizedBox(height: 14.h),

          // ─── 1. Maintenance Mode Switch ────────────────────────────────
          _buildModeTile(
            title: 'وضع الصيانة والإصلاح 🛠️',
            subtitle: _config.isMaintenanceMode
                ? 'مفعل: التطبيق محجوب بشاشة صيانة حالياً'
                : 'معطل: التطبيق يعمل بصورة طبيعية للجميع',
            icon: Icons.build_circle_outlined,
            activeColor: const Color(0xFFF59E0B),
            isActive: _config.isMaintenanceMode,
            onChanged: (val) => _showMaintenanceDialog(val),
          ),

          SizedBox(height: 12.h),

          // ─── 2. Force Update Mode Switch ──────────────────────────────
          _buildModeTile(
            title: 'وضع التحديث الإجباري 🚀',
            subtitle: _config.isUpdateRequired
                ? 'مفعل: يُلزم المستخدمين بالتحديث قبل الدخول'
                : 'معطل: يمكن استخدام الإصدار الحالي',
            icon: Icons.system_update_rounded,
            activeColor: const Color(0xFF0284C7),
            isActive: _config.isUpdateRequired,
            onChanged: (val) => _showUpdateDialog(val),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
    required bool isActive,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.08) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: isActive ? activeColor : const Color(0xFF64748B), size: 22.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isActive ? activeColor : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeThumbColor: activeColor,
            onChanged: _loading ? null : onChanged,
          ),
        ],
      ),
    );
  }
}
