import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Bottom navigation bar for the exam builder wizard.
///
/// Shows previous/next or publish buttons depending on the current step
/// and whether a save operation is in progress.
class WizardBottomNav extends StatelessWidget {
  const WizardBottomNav({
    super.key,
    required this.currentStep,
    required this.isSaving,
    required this.onPrev,
    required this.onNext,
    required this.onPublish,
  });

  final int currentStep;
  final bool isSaving;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPublish;

  bool get _isFirstStep => currentStep == 0;
  bool get _isLastStep => currentStep == 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: DeskColors.line)),
      ),
      child: Row(
        children: [
          if (!_isFirstStep) ...[
            _PrevButton(onPressed: onPrev),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: _ActionOrPublishButton(
              isSaving: isSaving,
              isLastStep: _isLastStep,
              onPressed: _isLastStep ? onPublish : onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrevButton extends StatelessWidget {
  const _PrevButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: DeskColors.line),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          padding: EdgeInsets.symmetric(horizontal: 18.w),
        ),
        child: Text('السابق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ActionOrPublishButton extends StatelessWidget {
  const _ActionOrPublishButton({
    required this.isSaving,
    required this.isLastStep,
    required this.onPressed,
  });

  final bool isSaving;
  final bool isLastStep;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DeskColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                isLastStep ? 'نشر الامتحان الآن' : 'التالي',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
      ),
    );
  }
}
