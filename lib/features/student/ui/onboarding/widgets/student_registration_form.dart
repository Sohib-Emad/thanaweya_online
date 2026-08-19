import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';
import '../../../../auth/logic/auth_cubit.dart';
import '../../../../auth/logic/auth_state.dart' as local;
import '../../../../../l10n/l10n.dart';
import 'design_dropdown.dart';
import 'design_text_field.dart';
import 'field_label.dart';

/// Full registration form with fields, grade selector, and submit.
class StudentRegistrationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController parentPhoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? selectedGrade;
  final ValueChanged<String?> onGradeChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onAuthenticated;

  const StudentRegistrationForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.parentPhoneController,
    required this.emailController,
    required this.passwordController,
    required this.selectedGrade,
    required this.onGradeChanged,
    required this.onSubmit,
    this.onAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final grades = [
      {'value': 'first', 'name': l10n.firstStage},
      {'value': 'second', 'name': l10n.secondStage},
      {'value': 'third', 'name': l10n.thirdStage},
    ];
    return Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(label: l10n.fullName), SizedBox(height: 6.h),
      NotebookCard(ruled: true, ruledStartY: 24, child: DesignTextField(controller: nameController, hintText: l10n.fullNameHint, prefixIcon: Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? l10n.fieldRequired : null)),
      SizedBox(height: 18.h),
      FieldLabel(label: l10n.gradeLevel), SizedBox(height: 6.h),
      NotebookCard(ruled: true, ruledStartY: 24, child: DesignDropdown(
        value: selectedGrade, hintText: l10n.gradeLevelHint, prefixIcon: Icons.school_outlined,
        items: grades.map((g) => DropdownMenuItem(value: g['value'], child: Text(g['name']!))).toList(),
        onChanged: onGradeChanged, validator: (v) => v == null ? l10n.fieldRequired : null,
      )),
      SizedBox(height: 18.h),
      FieldLabel(label: l10n.parentPhone), SizedBox(height: 6.h),
      NotebookCard(ruled: true, ruledStartY: 24, child: DesignTextField(controller: parentPhoneController, hintText: '010XXXXXXXX', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, validator: (v) => v!.isEmpty ? l10n.fieldRequired : null)),
      SizedBox(height: 18.h),
      FieldLabel(label: l10n.email), SizedBox(height: 6.h),
      NotebookCard(ruled: true, ruledStartY: 24, child: DesignTextField(controller: emailController, hintText: 'example@email.com', prefixIcon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, validator: (v) => v!.isEmpty ? l10n.fieldRequired : null)),
      SizedBox(height: 18.h),
      FieldLabel(label: l10n.password), SizedBox(height: 6.h),
      NotebookCard(ruled: true, ruledStartY: 24, child: DesignTextField(controller: passwordController, hintText: '••••••••', prefixIcon: Icons.lock_outline_rounded, obscureText: true, textDirection: TextDirection.ltr, validator: (v) => v!.isEmpty ? l10n.fieldRequired : null)),
      SizedBox(height: 32.h),
      BlocConsumer<AuthCubit, local.AuthState>(
        listener: (ctx, state) {
          if (state.status == local.AuthStatus.authenticated) {
            onAuthenticated?.call();
          } else if (state.status == local.AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: NotebookColors.marginRed));
          }
        },
        builder: (ctx, state) {
          final loading = state.status == local.AuthStatus.loading;
          return NotebookPrimaryButton(label: loading ? l10n.creatingAccount : l10n.register, onPressed: loading ? null : onSubmit);
        },
      ),
      SizedBox(height: 24.h),
    ]));
  }
}
