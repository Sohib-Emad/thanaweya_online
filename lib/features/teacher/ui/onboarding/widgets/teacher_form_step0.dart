import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/validators.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/desk_upload_card.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/field_label.dart';

/// Step 0: personal data, identity, and teaching-proof uploads.
class TeacherFormStep0 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController, phoneController;
  final TextEditingController emailController, passwordController;
  final XFile? avatarFile, idFrontFile, idBackFile, teacherProofFile;
  final Future<void> Function({
    required String title,
    required void Function(XFile?) onImageSelected,
  }) onPickImage;
  final ValueChanged<XFile?> onAvatarPicked, onIdFrontPicked;
  final ValueChanged<XFile?> onIdBackPicked, onTeacherProofPicked;

  const TeacherFormStep0({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    this.avatarFile,
    this.idFrontFile,
    this.idBackFile,
    this.teacherProofFile,
    required this.onPickImage,
    required this.onAvatarPicked,
    required this.onIdFrontPicked,
    required this.onIdBackPicked,
    required this.onTeacherProofPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DeskSectionHeader(title: 'بيانات المعلم والإثباتات'),
          SizedBox(height: 20.h),
          Center(
            child: GestureDetector(
              onTap: () => onPickImage(
                title: 'اختيار صورة البروفايل',
                onImageSelected: (f) => onAvatarPicked(f)),
              child: Stack(alignment: Alignment.bottomRight, children: [
                Container(
                  width: 86.r, height: 86.r,
                  decoration: BoxDecoration(
                    color: DeskColors.surfaceAlt, shape: BoxShape.circle,
                    border: Border.all(
                      color: DeskColors.primary.withAlpha(150), width: 1.8),
                    image: avatarFile != null
                        ? DecorationImage(
                            image: FileImage(File(avatarFile!.path)),
                            fit: BoxFit.cover) : null),
                  child: avatarFile == null
                      ? Icon(Icons.person_rounded, size: 44.r, color: DeskColors.muted) : null),
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(color: DeskColors.primary, shape: BoxShape.circle),
                  child: Icon(Icons.camera_alt_rounded, size: 14.r, color: DeskColors.onPrimary)),
              ]),
            ),
          ),
          SizedBox(height: 22.h),
          DeskInputField(label: 'الاسم الكامل*', controller: nameController,
            icon: Icons.person_outline_rounded, hint: 'أدخل الاسم الثلاثي كما في البطاقة...',
            validator: (v) => v!.isEmpty ? AppStrings.fieldRequired : null),
          SizedBox(height: 20.h),
          DeskInputField(label: 'رقم الهاتف*', controller: phoneController,
            icon: Icons.phone_outlined, hint: '010XXXXXXXX',
            keyboardType: TextInputType.phone, validator: Validators.phone),
          SizedBox(height: 20.h),
          DeskInputField(label: 'البريد الإلكتروني*', controller: emailController,
            icon: Icons.mail_outline_rounded, hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress, validator: Validators.email),
          SizedBox(height: 20.h),
          DeskInputField(label: 'كلمة السر*', controller: passwordController,
            icon: Icons.lock_outline_rounded, hint: '••••••••', obscureText: true,
            validator: (v) => v!.isEmpty ? AppStrings.fieldRequired : null),
          SizedBox(height: 24.h),
          const FieldLabel(label: 'إثبات الهوية الشخصية (بطاقة الرقم القومي)*'),
          SizedBox(height: 8.h),
          Row(children: [
            Expanded(child: DeskUploadCard(
              title: 'وجه البطاقة', isAttached: idFrontFile != null,
              fileName: idFrontFile?.name, icon: Icons.credit_card_rounded,
              accent: DeskColors.primary,
              onTap: () => onPickImage(
                title: 'إرفاق صورة وجه البطاقة', onImageSelected: (f) => onIdFrontPicked(f)))),
            SizedBox(width: 10.w),
            Expanded(child: DeskUploadCard(
              title: 'ظهر البطاقة', isAttached: idBackFile != null,
              fileName: idBackFile?.name, icon: Icons.credit_card_outlined,
              accent: DeskColors.info,
              onTap: () => onPickImage(
                title: 'إرفاق صورة ظهر البطاقة', onImageSelected: (f) => onIdBackPicked(f)))),
          ]),
          SizedBox(height: 18.h),
          const FieldLabel(label: 'مستند إثبات ممارسة التدريس (كارنيه المعلم / النقابة)*'),
          SizedBox(height: 8.h),
          DeskUploadCard(
            title: 'إرفاق كارنيه النقابة أو إفادة التدريس الرسمية',
            subtitle: teacherProofFile != null
                ? 'تم إرفاق: ${teacherProofFile!.name} ✓'
                : 'انقر لاختيار صورة كارنيه المعلم أو إفادة المدرسة/السنتر',
            isAttached: teacherProofFile != null, fileName: teacherProofFile?.name,
            icon: Icons.verified_user_rounded, accent: DeskColors.accent,
            onTap: () => onPickImage(
              title: 'إرفاق مستند ممارسة التدريس', onImageSelected: (f) => onTeacherProofPicked(f))),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
