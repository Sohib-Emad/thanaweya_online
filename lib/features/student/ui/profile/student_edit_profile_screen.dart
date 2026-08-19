import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import '../../../student/data/repos/student_onboarding_repo.dart';
import 'widgets/widgets.dart';

class StudentEditProfileScreen extends StatefulWidget {
  const StudentEditProfileScreen({super.key});
  @override
  State<StudentEditProfileScreen> createState() => _StudentEditProfileScreenState();
}

class _StudentEditProfileScreenState extends State<StudentEditProfileScreen> {
  final _name = TextEditingController();
  final _nick = TextEditingController(text: 'طالب');
  final _dob = TextEditingController(text: '12/10/2005');
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _gender = 'ذكر (Male)';
  String _uid = '';
  String? _avatarUrl;
  XFile? _picked;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = Supabase.instance.client.auth.currentUser;
    _uid = u?.id ?? '';
    _name.text = u?.userMetadata?['full_name']?.toString() ?? '';
    _phone.text = u?.userMetadata?['phone']?.toString() ?? '';
    _email.text = u?.email ?? '';
    _avatarUrl = u?.userMetadata?['avatar_url']?.toString();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_uid.isEmpty) return;
    try {
      final d = await Supabase.instance.client.from('users').select('full_name, phone, avatar_url').eq('id', _uid).maybeSingle();
      if (d != null && mounted) {
        setState(() {
          if (d['avatar_url'] != null) _avatarUrl = d['avatar_url'] as String;
          if (_name.text.isEmpty && d['full_name'] != null) _name.text = d['full_name'] as String;
          if (_phone.text.isEmpty && d['phone'] != null) _phone.text = d['phone'] as String;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickAvatar() async {
    HapticFeedback.lightImpact();
    final src = await showAvatarSourceSheet(context);
    if (src != null) {
      final f = await ImagePicker().pickImage(source: src, maxWidth: 600, maxHeight: 600, imageQuality: 85);
      if (f != null && mounted) setState(() => _picked = f);
    }
  }

  @override
  void dispose() { _name.dispose(); _nick.dispose(); _dob.dispose(); _email.dispose(); _phone.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.editProfile, subtitle: l10n.editProfileSubtitle),
      body: NotebookPaper(child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EditProfileAvatar(avatarUrl: _avatarUrl, pickedAvatar: _picked != null ? File(_picked!.path) : null, name: _name.text, onTap: _pickAvatar),
          SizedBox(height: 26.h),
          EditProfileBasicDataCard(l10n: l10n, nameController: _name, nickNameController: _nick, dobController: _dob, emailController: _email, phoneController: _phone, onDobTap: _pickDate),
          SizedBox(height: 20.h),
          NotebookSectionHeader(title: l10n.gender),
          SizedBox(height: 12.h),
          NotebookCard(ruled: true, ruledStartY: 24, borderRadius: 12, padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            child: EditProfileGenderDropdown(selectedValue: _gender, onChanged: (v) { if (v != null) setState(() => _gender = v); })),
          SizedBox(height: 28.h),
          if (_saving) const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)))
          else NotebookPrimaryButton(label: l10n.updateData, icon: Icons.arrow_forward_rounded, onPressed: _save),
        ]),
      )),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime(2005, 10, 12), firstDate: DateTime(1990), lastDate: DateTime.now());
    if (d != null) setState(() => _dob.text = '${d.day}/${d.month}/${d.year}');
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    String? av = _avatarUrl;
    if (_picked != null) {
      final u = await StorageHelper.uploadTeacherDocument(userId: _uid, subfolder: 'avatar', file: _picked!);
      if (u != null) av = u;
    }
    final n = _name.text.trim(), p = _phone.text.trim();
    final r = await StudentOnboardingRepo().updateStudentProfile(userId: _uid, fullName: n, phone: p, avatarUrl: av);
    if (av != null) {
      try { await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'avatar_url': av, 'full_name': n, 'phone': p})); } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _saving = false);
    r.when(
      success: (_) => Navigator.pop(context, true),
      failure: (msg, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg.isEmpty ? l10n.updateDataError : msg, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFDC2626), behavior: SnackBarBehavior.floating)),
    );
  }
}
