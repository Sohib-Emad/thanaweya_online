import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Sticky bottom bar with the subscribe / activate button.
class EnrollBar extends StatelessWidget {
  final bool isSubscribed;
  final VoidCallback? onPressed;

  const EnrollBar({super.key, required this.isSubscribed, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: SafeArea(
        child: NotebookPrimaryButton(
          label: isSubscribed
              ? l10n.subscribedLabel
              : 'تفعيل الكورس بكود المدرس',
          icon: isSubscribed ? Icons.check_circle_rounded : Icons.vpn_key_rounded,
          onPressed: isSubscribed
              ? null
              : () {
                  HapticFeedback.heavyImpact();
                  onPressed?.call();
                },
        ),
      ),
    );
  }
}
