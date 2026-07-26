import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGrade;
  bool _isLoading = false;
  XFile? _avatarFile;

  final ImagePicker _picker = ImagePicker();

  final _grades = [
    {'value': 'first', 'name': AppStrings.firstStage},
    {'value': 'second', 'name': AppStrings.secondStage},
    {'value': 'third', 'name': AppStrings.thirdStage},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _parentPhoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourcePicker({
    required String title,
    required Function(XFile?) onImageSelected,
  }) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 22.r,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.studentPrimary,
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'اختيار من معرض الصور (Gallery)',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'اختر صورة واضحة محفوظة على جهازك',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (file != null) {
                        onImageSelected(file);
                      }
                    } catch (_) {
                      onImageSelected(XFile('gallery_image.jpg'));
                    }
                  },
                ),
                SizedBox(height: 8.h),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                SizedBox(height: 8.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: const Color(0xFF0FA37F),
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'التقاط صورة جديدة بالكاميرا (Camera)',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'استخدم كاميرا الهاتف لتصوير شخصية فورية',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (file != null) {
                        onImageSelected(file);
                      }
                    } catch (_) {
                      onImageSelected(XFile('camera_image.jpg'));
                    }
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      AppStrings.studentRegistration,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF0F172A),
                          size: 30.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        // Avatar Header
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _showImageSourcePicker(
                                title: 'اختيار صورة البروفايل',
                                onImageSelected: (file) {
                                  setState(() => _avatarFile = file);
                                },
                              );
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 96.r,
                                  height: 96.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.studentPrimaryLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.studentPrimary
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                    image: _avatarFile != null
                                        ? DecorationImage(
                                            image: FileImage(
                                              File(_avatarFile!.path),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _avatarFile == null
                                      ? Icon(
                                          Icons.person_outlined,
                                          size: 46.r,
                                          color: AppColors.studentPrimary,
                                        )
                                      : null,
                                ),
                                Container(
                                  padding: EdgeInsets.all(7.r),
                                  decoration: const BoxDecoration(
                                    color: AppColors.studentPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 15.r,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),

                        // Full Name
                        const _FieldLabel(label: AppStrings.fullName),
                        SizedBox(height: 6.h),
                        _DesignTextField(
                          controller: _nameController,
                          hintText: 'أدخل الاسم الكامل...',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                        SizedBox(height: 18.h),

                        // Grade Level
                        const _FieldLabel(label: AppStrings.gradeLevel),
                        SizedBox(height: 6.h),
                        _DesignDropdown(
                          value: _selectedGrade,
                          hintText: 'اختر المستوى الدراسي...',
                          prefixIcon: Icons.school_outlined,
                          items: _grades.map((g) {
                            return DropdownMenuItem(
                              value: g['value'],
                              child: Text(g['name']!),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedGrade = v),
                          validator: (v) =>
                              v == null ? AppStrings.fieldRequired : null,
                        ),
                        SizedBox(height: 18.h),

                        // Parent Phone
                        const _FieldLabel(label: AppStrings.parentPhone),
                        SizedBox(height: 6.h),
                        _DesignTextField(
                          controller: _parentPhoneController,
                          hintText: '010XXXXXXXX',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                        SizedBox(height: 18.h),

                        // Email
                        const _FieldLabel(label: AppStrings.email),
                        SizedBox(height: 6.h),
                        _DesignTextField(
                          controller: _emailController,
                          hintText: 'example@email.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                        SizedBox(height: 18.h),

                        // Password
                        const _FieldLabel(label: AppStrings.password),
                        SizedBox(height: 6.h),
                        _DesignTextField(
                          controller: _passwordController,
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textDirection: TextDirection.ltr,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                        SizedBox(height: 32.h),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 54.h,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                HapticFeedback.lightImpact();
                                setState(() => _isLoading = true);
                                Future.delayed(
                                  const Duration(milliseconds: 800),
                                  () {
                                    if (!mounted) return;
                                    setState(() => _isLoading = false);
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.studentActivation,
                                    );
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.studentPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24.r,
                                    height: 24.r,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    AppStrings.register,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF64748B),
      ),
    );
  }
}

class _DesignTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final int maxLines;
  final String? Function(String?)? validator;

  const _DesignTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textDirection,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textDirection: textDirection,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(
          fontSize: 13.sp,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20.r)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(
            color: AppColors.studentPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

class _DesignDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _DesignDropdown({
    required this.value,
    required this.hintText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: const Color(0xFF94A3B8),
        size: 24.r,
      ),
      style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(
          fontSize: 13.sp,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20.r)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(
            color: AppColors.studentPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
