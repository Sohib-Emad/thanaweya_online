import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/services/app_system_config_repo.dart';
import 'admin_mode_switch_tile.dart';
import 'admin_maintenance_dialog.dart';
import 'admin_force_update_dialog.dart';

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
    _configRepo.fetchConfig().then((fresh) { if (mounted) setState(() => _config = fresh); });
  }

  Future<void> _toggleMaintenance(bool on, String msg) async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await _configRepo.setMaintenanceMode(enabled: on, message: msg.isNotEmpty ? msg : null);
    if (!mounted) return;
    setState(() { _config = _configRepo.cachedConfig; _loading = false; });
    _snack(on ? 'تم تفعيل وضع الصيانة 🛠️' : 'تم إيقاف وضع الصيانة ✅', on ? const Color(0xFFF59E0B) : const Color(0xFF16A34A));
  }

  Future<void> _toggleUpdate(bool on, String msg, String url) async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await _configRepo.setUpdateMode(enabled: on, message: msg.isNotEmpty ? msg : null, updateUrl: url.isNotEmpty ? url : null);
    if (!mounted) return;
    setState(() { _config = _configRepo.cachedConfig; _loading = false; });
    _snack(on ? 'تم تفعيل وضع التحديث 🚀' : 'تم إيقاف وضع التحديث ✅', on ? const Color(0xFF0284C7) : const Color(0xFF16A34A));
  }

  void _snack(String text, Color bg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: bg, behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w), padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(18.r), border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(10.r)), child: const Icon(Icons.settings_suggest_rounded, color: Color(0xFF7C3AED), size: 20)),
            SizedBox(width: 10.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('التحكم في حالة التطبيق العامة', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('وضع الصيانة والتحديث الإجباري للمستخدمين', style: GoogleFonts.cairo(fontSize: 10.5.sp, color: AppColors.textSecondary)),
            ])),
          ]),
          SizedBox(height: 14.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          AdminModeSwitchTile(
            title: 'وضع الصيانة والإصلاح 🛠️', subtitle: _config.isMaintenanceMode ? 'مفعل: محجوب بشاشة صيانة' : 'معطل: يعمل بصورة طبيعية',
            icon: Icons.build_circle_outlined, activeColor: const Color(0xFFF59E0B), isActive: _config.isMaintenanceMode, isLoading: _loading,
            onChanged: (val) => val ? showDialog(context: context, builder: (_) => AdminMaintenanceDialog(initialMessage: _config.maintenanceMessage, onConfirm: (m) => _toggleMaintenance(true, m))) : _toggleMaintenance(false, _config.maintenanceMessage),
          ),
          SizedBox(height: 12.h),
          AdminModeSwitchTile(
            title: 'وضع التحديث الإجباري 🚀', subtitle: _config.isUpdateRequired ? 'مفعل: يلزم المستخدمين بالتحديث' : 'معطل: يمكن استخدام الإصدار الحالي',
            icon: Icons.system_update_rounded, activeColor: const Color(0xFF0284C7), isActive: _config.isUpdateRequired, isLoading: _loading,
            onChanged: (val) => val ? showDialog(context: context, builder: (_) => AdminForceUpdateDialog(initialMessage: _config.updateMessage, initialUrl: _config.updateUrl, onConfirm: (m, u) => _toggleUpdate(true, m, u))) : _toggleUpdate(false, _config.updateMessage, _config.updateUrl),
          ),
        ],
      ),
    );
  }
}
