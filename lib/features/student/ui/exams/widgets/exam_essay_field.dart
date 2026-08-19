import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Text area for answering essay-type exam questions.
class ExamEssayField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const ExamEssayField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
            child: Text(
              context.l10n.writeAnswerHere,
              style: NotebookText.strong(12.sp, color: NotebookColors.pencil),
            ),
          ),
          TextField(
            minLines: 4,
            maxLines: 8,
            textDirection: TextDirection.rtl,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: context.l10n.writeAnswerHint,
              hintStyle: NotebookText.note(12.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
            ),
            style: NotebookText.body(13.sp).copyWith(height: 1.5),
          ),
          if (value.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
              child: Text(
                context.l10n.savedChars(value.length),
                style:
                    NotebookText.strong(11.sp, color: NotebookColors.green),
              ),
            ),
        ],
      ),
    );
  }
}
