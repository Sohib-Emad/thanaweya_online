import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/auth/data/repos/auth_repo.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';
import 'package:thanaweya_online/features/auth/logic/auth_state.dart' as local;

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
  XFile? _avatarFile;

  final ImagePicker _picker = ImagePicker();
  late final AuthCubit _authCubit;

  final _grades = [
    {'value': 'first', 'name': AppStrings.firstStage},
    {'value': 'second', 'name': AppStrings.secondStage},
    {'value': 'third', 'name': AppStrings.thirdStage},
  ];

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(authRepo: AuthRepo());
  }

  @override
  void dispose() {
    _authCubit.close();
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
      backgroundColor: NotebookColors.surface,
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
                    Text(title, style: NotebookText.heading(17.sp)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: NotebookColors.pencil,
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
                      color: NotebookColors.green.withAlpha(18),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: NotebookColors.green,
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'اختيار من معرض الصور',
                    style: NotebookText.strong(14.sp),
                  ),
                  subtitle: Text(
                    'اختر صورة واضحة محفوظة على جهازك',
                    style: NotebookText.note(11.sp),
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
                Divider(height: 1, color: NotebookColors.ink.withAlpha(25)),
                SizedBox(height: 8.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: NotebookColors.green.withAlpha(18),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: NotebookColors.green,
                      size: 24.r,
                    ),
                  ),
                  title: Text(
                    'التقاط صورة جديدة بالكاميرا',
                    style: NotebookText.strong(14.sp),
                  ),
                  subtitle: Text(
                    'استخدم كاميرا الهاتف لتصوير شخصية فورية',
                    style: NotebookText.note(11.sp),
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
    return BlocProvider.value(
      value: _authCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NotebookColors.ground,
          appBar: NotebookTopBar(
            title: AppStrings.studentRegistration,
            subtitle: 'سجّل بياناتك لبدء دفتر الطالب',
          ),
          body: SafeArea(
            top: false,
            child: NotebookPaper(
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
                                  color: NotebookColors.surfaceBright,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: NotebookColors.green.withAlpha(90),
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
                                        color: NotebookColors.green,
                                      )
                                    : null,
                              ),
                              Container(
                                padding: EdgeInsets.all(7.r),
                                decoration: BoxDecoration(
                                  color: NotebookColors.green,
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
                      NotebookCard(
                        ruled: true,
                        ruledStartY: 24,
                        child: _DesignTextField(
                          controller: _nameController,
                          hintText: 'أدخل الاسم الكامل...',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // Grade Level
                      const _FieldLabel(label: AppStrings.gradeLevel),
                      SizedBox(height: 6.h),
                      NotebookCard(
                        ruled: true,
                        ruledStartY: 24,
                        child: _DesignDropdown(
                          value: _selectedGrade,
                          hintText: 'اختر المستوى الدراسي...',
                          prefixIcon: Icons.school_outlined,
                          items: _grades.map((g) {
                            return DropdownMenuItem(
                              value: g['value'],
                              child: Text(g['name']!),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedGrade = v),
                          validator: (v) =>
                              v == null ? AppStrings.fieldRequired : null,
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // Parent Phone
                      const _FieldLabel(label: AppStrings.parentPhone),
                      SizedBox(height: 6.h),
                      NotebookCard(
                        ruled: true,
                        ruledStartY: 24,
                        child: _DesignTextField(
                          controller: _parentPhoneController,
                          hintText: '010XXXXXXXX',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // Email
                      const _FieldLabel(label: AppStrings.email),
                      SizedBox(height: 6.h),
                      NotebookCard(
                        ruled: true,
                        ruledStartY: 24,
                        child: _DesignTextField(
                          controller: _emailController,
                          hintText: 'example@email.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // Password
                      const _FieldLabel(label: AppStrings.password),
                      SizedBox(height: 6.h),
                      NotebookCard(
                        ruled: true,
                        ruledStartY: 24,
                        child: _DesignTextField(
                          controller: _passwordController,
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textDirection: TextDirection.ltr,
                          validator: (v) =>
                              v!.isEmpty ? AppStrings.fieldRequired : null,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Submit Button
                      BlocConsumer<AuthCubit, local.AuthState>(
                        listener: (context, state) {
                          switch (state.status) {
                            case local.AuthStatus.authenticated:
                              _upsertStudentData();
                              Navigator.pushNamed(
                                context,
                                AppRouter.studentHome,
                              );
                              break;
                            case local.AuthStatus.error:
                              if (state.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.errorMessage!),
                                    backgroundColor: NotebookColors.marginRed,
                                  ),
                                );
                              }
                              break;
                            default:
                              break;
                          }
                        },
                        builder: (context, state) {
                          final isLoading =
                              state.status == local.AuthStatus.loading;
                          return NotebookPrimaryButton(
                            label: isLoading
                                ? 'جاري إنشاء الحساب...'
                                : AppStrings.register,
                            onPressed: isLoading ? null : _onSubmit,
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      _authCubit.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            phone: _parentPhoneController.text.trim(),
            role: 'student',
          );
    }
  }

  Future<void> _upsertStudentData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('students').upsert({
          'id': userId,
          'grade_level': _selectedGrade,
          'parent_phone': _parentPhoneController.text.trim(),
        }, onConflict: 'id');
      }
    } catch (e) {
      debugPrint('[StudentForm] upsert student data failed: $e');
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: NotebookText.strong(12.sp, color: NotebookColors.pencil),
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
      style: NotebookText.body(14.sp),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: NotebookText.note(13.sp),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: NotebookColors.pencil, size: 20.r)
            : null,
        border: InputBorder.none,
        isDense: true,
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
        color: NotebookColors.pencil,
        size: 22.r,
      ),
      style: NotebookText.body(14.sp),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: NotebookText.note(13.sp),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: NotebookColors.pencil, size: 20.r)
            : null,
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }
}
