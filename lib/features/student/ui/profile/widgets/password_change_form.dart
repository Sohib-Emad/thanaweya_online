import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/l10n/l10n.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'notebook_password_field.dart';

/// The form body for changing a password, containing current/new/confirm fields.
class PasswordChangeForm extends StatelessWidget {
  /// Creates a [PasswordChangeForm].
  const PasswordChangeForm({
    super.key,
    required this.formKey,
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.obscureCurrent,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  /// The form key for validation.
  final GlobalKey<FormState> formKey;

  /// Controller for the current password field.
  final TextEditingController currentController;

  /// Controller for the new password field.
  final TextEditingController newController;

  /// Controller for the confirm password field.
  final TextEditingController confirmController;

  /// Whether the current password is obscured.
  final bool obscureCurrent;

  /// Whether the new password is obscured.
  final bool obscureNew;

  /// Whether the confirm password is obscured.
  final bool obscureConfirm;

  /// Callback to toggle current password visibility.
  final VoidCallback onToggleCurrent;

  /// Callback to toggle new password visibility.
  final VoidCallback onToggleNew;

  /// Callback to toggle confirm password visibility.
  final VoidCallback onToggleConfirm;

  /// Called when the form is submitted.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotebookHighlightNote(
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: NotebookColors.green, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(l10n.passwordSecurityNote,
                      style: NotebookText.note(12.sp)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          NotebookSectionHeader(title: l10n.currentPassword),
          SizedBox(height: 12.h),
          _card(NotebookPasswordField(
            label: l10n.currentPassword,
            controller: currentController,
            obscure: obscureCurrent,
            onToggleVisibility: onToggleCurrent,
            validator: (v) =>
                v == null || v.isEmpty ? l10n.enterCurrentPassword : null,
            onFieldSubmitted: (_) => onSubmit(),
          )),
          SizedBox(height: 20.h),
          NotebookSectionHeader(title: l10n.newPassword),
          SizedBox(height: 12.h),
          _card(Column(children: [
            NotebookPasswordField(
              label: l10n.newPassword,
              controller: newController,
              obscure: obscureNew,
              onToggleVisibility: onToggleNew,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.enterNewPassword;
                if (v.length < 6) return l10n.passwordMinLength;
                return null;
              },
              onFieldSubmitted: (_) => onSubmit(),
            ),
            SizedBox(height: 20.h),
            NotebookPasswordField(
              label: l10n.confirmNewPassword,
              controller: confirmController,
              obscure: obscureConfirm,
              onToggleVisibility: onToggleConfirm,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.reenterNewPassword;
                if (v != newController.text) return l10n.passwordMismatch;
                return null;
              },
              onFieldSubmitted: (_) => onSubmit(),
            ),
          ])),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 20,
      borderRadius: 12,
      padding: EdgeInsets.all(20.r),
      child: child,
    );
  }
}
