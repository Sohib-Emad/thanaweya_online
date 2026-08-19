import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';
import '../../../../../l10n/l10n.dart';
import 'edit_profile_input_field.dart';

/// Card containing all basic profile fields and the account type display.
class EditProfileBasicDataCard extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController nameController;
  final TextEditingController nickNameController;
  final TextEditingController dobController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VoidCallback onDobTap;

  const EditProfileBasicDataCard({
    super.key,
    required this.l10n,
    required this.nameController,
    required this.nickNameController,
    required this.dobController,
    required this.emailController,
    required this.phoneController,
    required this.onDobTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotebookSectionHeader(title: l10n.basicData),
        SizedBox(height: 12.h),
        NotebookCard(
          ruled: true,
          ruledStartY: 20,
          borderRadius: 12,
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditProfileInputField(
                label: l10n.fullName,
                controller: nameController,
                icon: Icons.person_outline_rounded,
              ),
              SizedBox(height: 20.h),
              EditProfileInputField(
                label: l10n.nickName,
                controller: nickNameController,
                icon: Icons.badge_outlined,
              ),
              SizedBox(height: 20.h),
              EditProfileInputField(
                label: l10n.dateOfBirth,
                controller: dobController,
                icon: Icons.calendar_today_rounded,
                isReadOnly: true,
                onTap: onDobTap,
              ),
              SizedBox(height: 20.h),
              EditProfileInputField(
                label: l10n.email,
                controller: emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              SizedBox(height: 20.h),
              EditProfileInputField(
                label: l10n.phone,
                controller: phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                prefixText: '+20',
              ),
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.accountType, style: NotebookText.strong(12.sp)),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.school_outlined,
                          color: NotebookColors.pencil, size: 18.r),
                      SizedBox(width: 10.w),
                      Text(l10n.studentLabel, style: NotebookText.body(13.sp)),
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
      ],
    );
  }
}
