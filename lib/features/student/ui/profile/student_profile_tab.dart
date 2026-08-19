import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/widgets.dart';

/// Student profile tab showing avatar, name, and settings menu.
class StudentProfileTab extends StatefulWidget {
  final bool isTabMode;

  const StudentProfileTab({super.key, this.isTabMode = true});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  String _fullName = 'طالب';
  String _email = '';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
    LocaleController.instance.addListener(_onLocaleChanged);
  }

  void _loadUser() {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name']?.toString().trim() ?? '';
    setState(() {
      _fullName = fullName.isEmpty ? 'طالب' : fullName;
      _email = user?.email ?? '';
      _avatarUrl = user?.userMetadata?['avatar_url']?.toString();
    });
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.profile,
        subtitle: widget.isTabMode ? l10n.profileSubtitle : null,
        automaticallyImplyBack: !widget.isTabMode,
      ),
      body: NotebookPaper(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 120.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ProfileAvatar(
                avatarUrl: _avatarUrl,
                name: _fullName,
                onEditTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, AppRouter.studentEditProfile)
                      .then((_) => _loadUser());
                },
              ),
              SizedBox(height: 2.h),
              Text(_email, style: NotebookText.note(12.sp)),
              SizedBox(height: 6.h),
              Container(width: 56.w, height: 2.h, color: NotebookColors.marginRed.withAlpha(160)),
              SizedBox(height: 26.h),
              ProfileMenuCard(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}
