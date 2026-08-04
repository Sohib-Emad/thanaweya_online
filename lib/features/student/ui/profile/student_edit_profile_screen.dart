import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'تعديل الملف الشخصي (Edit Profile)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Avatar with Edit Badge
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96.r,
                      height: 96.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2E8F0),
                        border: Border.all(
                          color: AppColors.studentPrimary,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFCBD5E1),
                        child: Icon(
                          Icons.person_rounded,
                          size: 50.r,
                          color: Colors.white,
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
                          color: AppColors.studentPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // Full Name
              _buildInputField(
                label: 'الاسم الكامل (Full Name)',
                controller: _nameController,
                icon: Icons.person_outline_rounded,
              ),

              SizedBox(height: 16.h),

              // Nick Name
              _buildInputField(
                label: 'الاسم المستعار (Nick Name)',
                controller: _nickNameController,
                icon: Icons.badge_outlined,
              ),

              SizedBox(height: 16.h),

              // Date of Birth
              _buildInputField(
                label: 'تاريخ الميلاد (Date of Birth)',
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

              SizedBox(height: 16.h),

              // Email
              _buildInputField(
                label: 'البريد الإلكتروني (Email)',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),

              SizedBox(height: 16.h),

              // Phone Number with Country Flag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text('🇪🇬 +20', style: TextStyle(fontSize: 14.sp)),
                    Icon(Icons.arrow_drop_down_rounded, color: const Color(0xFF64748B)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'رقم الهاتف (Phone)',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Gender Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
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

              SizedBox(height: 16.h),

              // Student Role Readonly
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'نوع الحساب: طالب (Student)',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Bottom Update Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 4,
                    shadowColor: const Color(0x332563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تحديث البيانات (Update)',
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 34.r,
                        height: 34.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: const Color(0xFF2563EB),
                          size: 18.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        enabled: enabled,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20.r),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }
}
