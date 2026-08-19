import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Warning banner shown when the exam was auto-submitted.
class AutoSubmitWarningBanner extends StatelessWidget {
  const AutoSubmitWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return _WarningBanner(
      icon: Icons.warning_amber_rounded,
      message: context.l10n.autoSubmitWarning,
    );
  }
}

/// Warning banner shown when the exam timed out.
class TimeoutWarningBanner extends StatelessWidget {
  const TimeoutWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return _WarningBanner(
      icon: Icons.timer_off_rounded,
      message: context.l10n.timeoutSubmitNote,
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final IconData icon;
  final String message;

  const _WarningBanner({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NotebookHighlightNote(
          child: Row(
            children: [
              Icon(icon, color: NotebookColors.marginRed, size: 20.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(message, style: NotebookText.strong(11.sp)),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
