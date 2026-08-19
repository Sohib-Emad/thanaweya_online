import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/features/teacher/logic/teacher_cards_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/widgets/activation_card_item.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/widgets/cards_empty_state.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/widgets/copy_code_snackbar.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/widgets/delete_confirm_dialog.dart';

/// Scrollable list of activation cards with empty state fallback.
class CardsListView extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final TeacherCardsCubit cubit;

  const CardsListView({
    super.key,
    required this.cards,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const CardsEmptyState();

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
      itemCount: cards.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final card = cards[index];
        final code = card['code'] as String? ?? '';
        final isUsed = card['is_used'] as bool? ?? false;
        final courseMap = card['courses'] as Map<String, dynamic>?;
        final courseTitle = courseMap?['title'] ?? 'جميع كورسات المدرس';
        final studentMap = card['students'] as Map<String, dynamic>?;
        final userMap = studentMap?['users'] as Map<String, dynamic>?;
        final studentName = userMap?['full_name'] as String?;

        return ActivationCardItem(
          code: code,
          isUsed: isUsed,
          courseTitle: courseTitle,
          studentName: studentName,
          onCopy: () => copyCodeToClipboard(context, code),
          onDelete: () async {
            final confirmed = await DeleteConfirmDialog.show(
              context,
              code: code,
            );
            if (confirmed) {
              await cubit.deleteCode(card['id'] as String);
            }
          },
        );
      },
    );
  }
}
