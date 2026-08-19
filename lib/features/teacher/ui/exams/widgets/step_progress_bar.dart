import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Three-step progress indicator used by [ExamBuilderWizard].
///
/// Shows circles connected by lines, highlighting the active step and
/// marking completed steps with a check icon.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
  });

  /// Zero-indexed active step (0, 1, or 2).
  final int currentStep;

  static const _titles = ['البيانات', 'الأسئلة', 'المعاينة'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: DeskColors.line)),
      ),
      child: Row(
        children: List.generate(3, _buildStep),
      ),
    );
  }

  Widget _buildStep(int index) {
    final isDone = index < currentStep;
    final isCurrent = index == currentStep;

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepCircle(index: index, isDone: isDone, isCurrent: isCurrent),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    _titles[index],
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                      color: isCurrent ? DeskColors.primary : DeskColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (index < 2)
            Container(
              width: 14.w,
              height: 1.5,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              color: const Color(0xFFE2E8F0),
            ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.isDone,
    required this.isCurrent,
  });

  final int index;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26.r,
      height: 26.r,
      decoration: BoxDecoration(
        color: isCurrent
            ? DeskColors.primary
            : (isDone ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9)),
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isCurrent || isDone ? DeskColors.primary : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.check_rounded, size: 14.r, color: DeskColors.primary)
            : Text(
                '${index + 1}',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: isCurrent ? Colors.white : DeskColors.muted,
                ),
              ),
      ),
    );
  }
}
