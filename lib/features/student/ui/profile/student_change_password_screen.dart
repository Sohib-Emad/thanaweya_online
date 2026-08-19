import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/l10n/l10n.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import 'widgets/widgets.dart';

/// Screen for changing the student's account password.
class StudentChangePasswordScreen extends StatefulWidget {
  const StudentChangePasswordScreen({super.key});

  @override
  State<StudentChangePasswordScreen> createState() =>
      _StudentChangePasswordScreenState();
}

class _StudentChangePasswordScreenState
    extends State<StudentChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);
    await context.read<AuthCubit>().changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    final state = context.read<AuthCubit>().state;
    if (state.status == AuthStatus.error) {
      _snack(state.errorMessage ?? context.l10n.changePasswordError,
          const Color(0xFFDC2626));
    } else {
      _snack(context.l10n.passwordChangedSuccess, NotebookColors.green);
      Navigator.pop(context, true);
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.changePassword,
        subtitle: l10n.changePasswordSubtitle,
      ),
      body: NotebookPaper(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            PasswordChangeForm(
              formKey: _formKey,
              currentController: _currentController,
              newController: _newController,
              confirmController: _confirmController,
              obscureCurrent: _obscureCurrent,
              obscureNew: _obscureNew,
              obscureConfirm: _obscureConfirm,
              onToggleCurrent: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              onToggleNew: () =>
                  setState(() => _obscureNew = !_obscureNew),
              onToggleConfirm: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              onSubmit: _submit,
            ),
            SizedBox(height: 28.h),
            NotebookPrimaryButton(
              label:
                  _submitting ? l10n.changingPassword : l10n.changePassword,
              icon: Icons.arrow_forward_rounded,
              onPressed: _submitting ? null : _submit,
            ),
          ]),
        ),
      ),
    );
  }
}
