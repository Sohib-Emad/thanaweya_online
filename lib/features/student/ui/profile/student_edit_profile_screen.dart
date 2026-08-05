import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/notebook_theme.dart';
import '../../../student/data/repos/student_onboarding_repo.dart';

class StudentEditProfileScreen extends StatefulWidget {
  const StudentEditProfileScreen({super.key});

  @override
  State<StudentEditProfileScreen> createState() =>
      _StudentEditProfileScreenState();
}

class _StudentEditProfileScreenState extends State<StudentEditProfileScreen> {
  final _nameController = TextEditingController();
  final _nickNameController = TextEditingController(text: 'صهيب');
  final _dobController = TextEditingController(text: '12/10/2005');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'ذكر (Male)';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;
    _userId = user?.id ?? '';
    _nameController.text = user?.userMetadata?['full_name']?.toString() ?? '';
    _phoneController.text = user?.userMetadata?['phone']?.toString() ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nickNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'تعديل الملف الشخصي',
          subtitle: 'بياناتك على صفحات الدفتر',
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with edit badge
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96.r,
                        height: 96.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: NotebookColors.surfaceBright,
                          border: Border.all(
                            color: NotebookColors.green,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: NotebookColors.surfaceBright,
                          child: Text(
                            _nameController.text.isEmpty
                                ? 'ط'
                                : _nameController.text.substring(0, 1),
                            style: GoogleFonts.cairo(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w900,
                              color: NotebookColors.ink,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: NotebookColors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NotebookColors.surfaceBright,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.photo_camera_rounded,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 26.h),

                NotebookSectionHeader(title: 'البيانات الأساسية'),
                SizedBox(height: 12.h),

                NotebookCard(
                  ruled: true,
                  ruledStartY: 20,
                  borderRadius: 12,
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'الاسم الكامل',
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                      ),
                      SizedBox(height: 20.h),

                      _buildInputField(
                        label: 'الاسم المستعار',
                        controller: _nickNameController,
                        icon: Icons.badge_outlined,
                      ),
                      SizedBox(height: 20.h),

                      _buildInputField(
                        label: 'تاريخ الميلاد',
                        controller: _dobController,
                        icon: Icons.calendar_today_rounded,
                        isReadOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2005, 10, 12),
                            firstDate: DateTime(1990),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _dobController.text =
                                  '${date.day}/${date.month}/${date.year}';
                            });
                          }
                        },
                      ),
                      SizedBox(height: 20.h),

                      _buildInputField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false,
                      ),
                      SizedBox(height: 20.h),

                      _buildInputField(
                        label: 'رقم الهاتف',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        prefixText: '+20',
                      ),
                      SizedBox(height: 20.h),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('نوع الحساب', style: NotebookText.strong(12.sp)),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                color: NotebookColors.pencil,
                                size: 18.r,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'طالب',
                                style: NotebookText.body(13.sp),
                              ),
                            ],
                          ),
                          Container(
                            height: 1.4,
                            color: NotebookColors.ink.withAlpha(70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                NotebookSectionHeader(title: 'الجنس'),
                SizedBox(height: 12.h),

                NotebookCard(
                  ruled: true,
                  ruledStartY: 24,
                  borderRadius: 12,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      style: NotebookText.body(13.sp),
                      dropdownColor: NotebookColors.surface,
                      items: const [
                        DropdownMenuItem(
                          value: 'ذكر (Male)',
                          child: Text('ذكر (Male)'),
                        ),
                        DropdownMenuItem(
                          value: 'أنثى (Female)',
                          child: Text('أنثى (Female)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedGender = val);
                        }
                      },
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                NotebookPrimaryButton(
                  label: 'تحديث البيانات',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final result = await StudentOnboardingRepo()
                        .updateStudentProfile(
                      userId: _userId,
                      fullName: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                    );
                    if (!mounted) return;
                    result.when(
                      success: (_) => Navigator.pop(context, true),
                      failure: (message, statusCode) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              message.isEmpty
                                  ? 'حدث خطأ أثناء تحديث البيانات'
                                  : message,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NotebookText.strong(12.sp)),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(icon, color: NotebookColors.pencil, size: 18.r),
            SizedBox(width: 10.w),
            if (prefixText != null) ...[
              Text(prefixText, style: NotebookText.strong(12.sp)),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: isReadOnly,
                enabled: enabled,
                onTap: onTap,
                keyboardType: keyboardType,
                style: NotebookText.body(13.sp),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 1.4,
          color: NotebookColors.ink.withAlpha(70),
        ),
      ],
    );
  }
}
