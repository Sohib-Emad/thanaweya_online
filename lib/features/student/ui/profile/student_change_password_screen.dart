import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/notebook_theme.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ?? 'حدث خطأ أثناء تغيير كلمة المرور',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تغيير كلمة المرور بنجاح',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: NotebookColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'تغيير كلمة المرور',
          subtitle: 'أدخل كلمة المرور الحالية أولاً',
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotebookHighlightNote(
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: NotebookColors.green,
                          size: 20.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'للحفاظ على أمان حسابك، يجب إدخال كلمة المرور الحالية ثم اختيار كلمة مرور جديدة قوية.',
                            style: NotebookText.note(12.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  NotebookSectionHeader(title: 'كلمة المرور الحالية'),
                  SizedBox(height: 12.h),
                  NotebookCard(
                    ruled: true,
                    ruledStartY: 20,
                    borderRadius: 12,
                    padding: EdgeInsets.all(20.r),
                    child: _buildPasswordField(
                      label: 'كلمة المرور الحالية',
                      controller: _currentController,
                      obscure: _obscureCurrent,
                      onToggleVisibility: () => setState(
                        () => _obscureCurrent = !_obscureCurrent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'أدخل كلمة المرور الحالية';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  NotebookSectionHeader(title: 'كلمة المرور الجديدة'),
                  SizedBox(height: 12.h),
                  NotebookCard(
                    ruled: true,
                    ruledStartY: 20,
                    borderRadius: 12,
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      children: [
                        _buildPasswordField(
                          label: 'كلمة المرور الجديدة',
                          controller: _newController,
                          obscure: _obscureNew,
                          onToggleVisibility: () => setState(
                            () => _obscureNew = !_obscureNew,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'أدخل كلمة المرور الجديدة';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        _buildPasswordField(
                          label: 'تأكيد كلمة المرور الجديدة',
                          controller: _confirmController,
                          obscure: _obscureConfirm,
                          onToggleVisibility: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'أعد إدخال كلمة المرور الجديدة';
                            }
                            if (value != _newController.text) {
                              return 'كلمتا المرور غير متطابقتين';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28.h),

                  NotebookPrimaryButton(
                    label: _submitting ? 'جارٍ التغيير...' : 'تغيير كلمة المرور',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _submitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NotebookText.strong(12.sp)),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.password_rounded, color: NotebookColors.pencil, size: 18.r),
            SizedBox(width: 10.w),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: obscure,
                validator: validator,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                style: NotebookText.body(13.sp),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggleVisibility,
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: NotebookColors.pencil,
                size: 18.r,
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
