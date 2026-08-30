import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/services/app_system_config_repo.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';

class AdminStudentVersionsScreen extends StatefulWidget {
  const AdminStudentVersionsScreen({super.key});

  @override
  State<AdminStudentVersionsScreen> createState() => _AdminStudentVersionsScreenState();
}

class _AdminStudentVersionsScreenState extends State<AdminStudentVersionsScreen> {
  final _configRepo = AppSystemConfigRepo();
  final _studentsRepo = AdminStudentsRepo();

  bool _loading = true;
  bool _savingConfig = false;
  late AppSystemConfig _config;
  List<Map<String, dynamic>> _students = [];

  String _searchQuery = '';
  int _filterIndex = 0; // 0: All, 1: Not Updated, 2: Updated

  final _minVerCtrl = TextEditingController();
  final _latestVerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _config = _configRepo.cachedConfig;
    _minVerCtrl.text = _config.minVersion;
    _latestVerCtrl.text = _config.latestVersion;
    _loadData();
  }

  @override
  void dispose() {
    _minVerCtrl.dispose();
    _latestVerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final freshConfig = await _configRepo.fetchConfig();
    final res = await _studentsRepo.getAllStudents();

    if (!mounted) return;
    setState(() {
      _config = freshConfig;
      _minVerCtrl.text = _config.minVersion;
      _latestVerCtrl.text = _config.latestVersion;
      _students = res.when(
        success: (list) => list,
        failure: (_, _) => [],
      );
      _loading = false;
    });
  }

  bool _isStudentUpdated(Map<String, dynamic> student) {
    final v = student['app_version']?.toString() ?? '1.0.0';
    return !AppSystemConfigRepo.isVersionOlder(v, _config.minVersion);
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((s) {
      final user = s['users'] as Map<String, dynamic>? ?? {};
      final name = (user['full_name'] as String? ?? '').toLowerCase();
      final phone = (user['phone'] as String? ?? '');
      final pPhone = (s['parent_phone'] as String? ?? '');

      final matchesSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery) ||
          pPhone.contains(_searchQuery);

      if (!matchesSearch) return false;

      final isUp = _isStudentUpdated(s);
      if (_filterIndex == 1) return !isUp;
      if (_filterIndex == 2) return isUp;
      return true;
    }).toList();
  }

  Future<void> _saveVersionSettings() async {
    HapticFeedback.mediumImpact();
    setState(() => _savingConfig = true);
    await _configRepo.setUpdateMode(
      enabled: _config.isUpdateRequired,
      minVersion: _minVerCtrl.text.trim().isNotEmpty ? _minVerCtrl.text.trim() : '1.0.0',
      latestVersion: _latestVerCtrl.text.trim().isNotEmpty ? _latestVerCtrl.text.trim() : '1.0.0',
    );
    if (!mounted) return;
    setState(() {
      _config = _configRepo.cachedConfig;
      _savingConfig = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ متطلبات الإصدار بنجاح ✅'), backgroundColor: AppColors.success),
    );
  }

  Future<void> _toggleForceLock(bool val) async {
    HapticFeedback.mediumImpact();
    setState(() => _savingConfig = true);
    await _configRepo.setUpdateMode(
      enabled: val,
      minVersion: _minVerCtrl.text.trim(),
      latestVersion: _latestVerCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _config = _configRepo.cachedConfig;
      _savingConfig = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(val ? 'تم قفل النسخ القديمة إجبارياً 🔒' : 'تم إيقاف القفل الإجباري ✅'),
        backgroundColor: val ? const Color(0xFFE11D48) : AppColors.success,
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String phone, String name) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = 'مرحباً $name، نود تذكيرك بتحديث تطبيق الثانوية أونلاين لمتابعة دروسك وامتحاناتك.';
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final total = _students.length;
    final updatedCount = _students.where(_isStudentUpdated).length;
    final notUpdatedCount = total - updatedCount;
    final updatedPercent = total > 0 ? ((updatedCount / total) * 100).toInt() : 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'متابعة إصدارات وتحديثات الطلاب',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.sp, color: AppColors.textPrimary),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0284C7)),
              onPressed: _loadData,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  children: [
                    // 1. بطاقة إحصائيات التحديثات
                    _buildStatsRow(total, updatedCount, notUpdatedCount, updatedPercent),

                    SizedBox(height: 14.h),

                    // 2. بطاقة إعدادات قفل النسخة
                    _buildVersionControlCard(),

                    SizedBox(height: 16.h),

                    // 3. شريط البحث والفلاتر
                    _buildSearchAndFilters(total, notUpdatedCount, updatedCount),

                    SizedBox(height: 12.h),

                    // 4. قائمة الطلاب
                    if (_filteredStudents.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(
                          child: Text(
                            'لا يوجد طلاب مطابقين للفلتر المختار',
                            style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFF64748B)),
                          ),
                        ),
                      )
                    else
                      ..._filteredStudents.map((s) => _buildStudentVersionTile(s)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow(int total, int updated, int notUpdated, int percent) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem('إجمالي الطلاب', '$total', const Color(0xFF0F172A), Icons.groups_rounded, const Color(0xFFF1F5F9)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatItem('حدّثوا التطبيق', '$updated ($percent%)', const Color(0xFF16A34A), Icons.check_circle_rounded, const Color(0xFFDCFCE7)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatItem('لم يحدّثوا', '$notUpdated', const Color(0xFFE11D48), Icons.warning_amber_rounded, const Color(0xFFFFE4E6)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: total > 0 ? (updated / total) : 0,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFFFE4E6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(height: 4.h),
          Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 13.sp, color: color)),
          Text(title, style: GoogleFonts.cairo(fontSize: 10.sp, color: const Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildVersionControlCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_update_rounded, color: Color(0xFF0284C7), size: 20),
                  SizedBox(width: 6.w),
                  Text('التحكم في قفل النسخ القديمة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13.5.sp)),
                ],
              ),
              Switch(
                value: _config.isUpdateRequired,
                activeThumbColor: const Color(0xFF0284C7),
                onChanged: _savingConfig ? null : (v) => _toggleForceLock(v),
              ),
            ],
          ),
          Text(
            _config.isUpdateRequired
                ? 'القفل الإجباري مفعل 🔒: لن يتمكن أي طالب من استخدام التطبيق إلا بعد التحديث.'
                : 'القفل التلقائي حسب رقم الإصدار ⚙️: سيتم قفل التطبيق فقط لمن نسخته أقدم من الإصدار المطلوب.',
            style: GoogleFonts.cairo(fontSize: 11.sp, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minVerCtrl,
                  style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'الحد الأدنى المطلوب',
                    hintText: '1.0.0',
                    labelStyle: GoogleFonts.cairo(fontSize: 11.sp),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: _latestVerCtrl,
                  style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'أحدث إصدار في المتجر',
                    hintText: '1.0.1',
                    labelStyle: GoogleFonts.cairo(fontSize: 11.sp),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _savingConfig ? null : _saveVersionSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(int total, int notUpdated, int updated) {
    return Column(
      children: [
        TextField(
          style: GoogleFonts.cairo(fontSize: 12.5.sp),
          decoration: InputDecoration(
            hintText: 'ابحث باسم الطالب أو رقم الهاتف...',
            hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.cardBorder)),
          ),
          onChanged: (v) => setState(() => _searchQuery = v.trim()),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildFilterChip(0, 'الكل ($total)'),
            SizedBox(width: 6.w),
            _buildFilterChip(1, 'لم يحدّثوا ($notUpdated) ⚠️', isAlert: true),
            SizedBox(width: 6.w),
            _buildFilterChip(2, 'محدّثون ($updated) ✅'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label, {bool isAlert = false}) {
    final selected = _filterIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filterIndex = index),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          decoration: BoxDecoration(
            color: selected
                ? (isAlert ? const Color(0xFFE11D48) : const Color(0xFF0F172A))
                : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: selected ? Colors.transparent : const Color(0xFFCBD5E1)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentVersionTile(Map<String, dynamic> s) {
    final user = s['users'] as Map<String, dynamic>? ?? {};
    final name = user['full_name'] as String? ?? 'طالب';
    final phone = user['phone'] as String? ?? '';
    final pPhone = s['parent_phone'] as String? ?? '';
    final appVer = s['app_version'] as String? ?? '1.0.0';
    final isUpdated = _isStudentUpdated(s);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isUpdated ? AppColors.cardBorder : const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isUpdated ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
            radius: 18.r,
            child: Icon(
              isUpdated ? Icons.check_circle_outline_rounded : Icons.system_update_alt_rounded,
              color: isUpdated ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
              size: 20,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13.sp, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isUpdated ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        isUpdated ? 'مُحدّث v$appVer' : 'قديم v$appVer',
                        style: GoogleFonts.cairo(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isUpdated ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'الهاتف: ${phone.isNotEmpty ? phone : "غير مسجل"} | ولي الأمر: ${pPhone.isNotEmpty ? pPhone : "-"}',
                  style: GoogleFonts.cairo(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (phone.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF0284C7)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _callPhone(phone),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF16A34A)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _openWhatsApp(phone, name),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
