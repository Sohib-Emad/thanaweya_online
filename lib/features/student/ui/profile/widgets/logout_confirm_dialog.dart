import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/notebook_theme.dart';
import '../../../../auth/logic/auth_cubit.dart';
import '../../../../../l10n/l10n.dart';

/// Shows a confirmation dialog and signs the user out on confirm.
Future<void> showLogoutConfirmDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: NotebookColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: NotebookColors.marginRed.withAlpha(80)),
      ),
      title: Text(ctx.l10n.logout, style: NotebookText.strong(16.sp)),
      content: Text(
        ctx.l10n.logoutConfirmMessage,
        style: NotebookText.body(13.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.l10n.cancel, style: NotebookText.strong(13.sp)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            ctx.l10n.logout,
            style: NotebookText.strong(13.sp).copyWith(
              color: NotebookColors.marginRed,
            ),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  HapticFeedback.mediumImpact();
  context.read<AuthCubit>().signOut();
  Navigator.pushReplacementNamed(context, AppRouter.login);
}
