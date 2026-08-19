import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/auth/data/repos/auth_repo.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/widgets.dart';

/// Student registration form screen with avatar, fields, and submit.
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
  File? _avatarFile;
  late final AuthCubit _authCubit;

  @override
  void initState() { super.initState(); _authCubit = AuthCubit(authRepo: AuthRepo()); }

  @override
  void dispose() {
    _authCubit.close();
    _nameController.dispose();
    _parentPhoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      _authCubit.signUp(
        email: _emailController.text.trim(), password: _passwordController.text,
        fullName: _nameController.text.trim(), phone: _parentPhoneController.text.trim(), role: 'student',
      );
    }
  }

  Future<void> _upsertStudentData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('students').upsert(
          {'id': userId, 'grade_level': _selectedGrade, 'parent_phone': _parentPhoneController.text.trim()},
          onConflict: 'id',
        );
      }
    } catch (e) { debugPrint('[StudentForm] upsert failed: $e'); }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider.value(
      value: _authCubit,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(title: l10n.studentRegistration, subtitle: l10n.signUpSubtitle),
        body: SafeArea(
          top: false,
          child: NotebookPaper(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 12.h),
                StudentAvatarPicker(
                  avatarFile: _avatarFile,
                  onTap: () => showImageSourcePicker(
                    context: context, title: l10n.chooseProfilePicture,
                    onImageSelected: (f) => setState(() => _avatarFile = f != null ? File(f.path) : null),
                  ),
                ),
                SizedBox(height: 28.h),
                StudentRegistrationForm(
                  formKey: _formKey, nameController: _nameController,
                  parentPhoneController: _parentPhoneController, emailController: _emailController,
                  passwordController: _passwordController, selectedGrade: _selectedGrade,
                  onGradeChanged: (v) => setState(() => _selectedGrade = v), onSubmit: _onSubmit,
                  onAuthenticated: () { _upsertStudentData(); Navigator.pushNamed(context, AppRouter.studentHome); },
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
