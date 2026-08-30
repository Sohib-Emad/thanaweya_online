import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/logic/admin_active_codes_cubit.dart';
import 'admin_code_card_item.dart';
import 'admin_delete_code_dialog.dart';

class AdminCodesListView extends StatelessWidget {
  final AdminActiveCodesState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String codeId) onDeleteCode;

  const AdminCodesListView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onDeleteCode,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminActiveCodesStatus.loading) return const Center(child: CircularProgressIndicator());
    if (state.status == AdminActiveCodesStatus.failure) return Center(child: Text(state.errorMessage ?? 'حدث خطأ', style: AppTextStyles.body2));
    if (state.filteredCodes.isEmpty) return Center(child: Text('لا توجد أكواد نشطة مطابقة للبحث', style: AppTextStyles.h3));

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: state.filteredCodes.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (ctx, i) => AdminCodeCardItem(
          item: state.filteredCodes[i],
          onDelete: () => showConfirmDeleteCodeDialog(
            context: ctx,
            code: state.filteredCodes[i]['code'] as String? ?? '',
            onConfirm: () => onDeleteCode(state.filteredCodes[i]['id'] as String? ?? ''),
          ),
        ),
      ),
    );
  }
}
