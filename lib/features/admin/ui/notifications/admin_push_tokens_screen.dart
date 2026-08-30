import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/logic/admin_push_tokens_cubit.dart';
import 'widgets/copy_tokens_options_dialog.dart';
import 'widgets/send_admin_notification_dialog.dart';
import 'widgets/push_tokens_action_buttons.dart';
import 'widgets/push_tokens_stats_row.dart';
import 'widgets/push_tokens_filter_chips.dart';
import 'widgets/push_token_card_item.dart';

class AdminPushTokensScreen extends StatefulWidget {
  const AdminPushTokensScreen({super.key});

  @override
  State<AdminPushTokensScreen> createState() => _AdminPushTokensScreenState();
}

class _AdminPushTokensScreenState extends State<AdminPushTokensScreen> {
  late final AdminPushTokensCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = AdminPushTokensCubit()..loadTokens();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openSendDialog({String? specificUserId, String? specificUserName}) {
    showDialog(
      context: context,
      builder: (_) => SendAdminNotificationDialog(cubit: _cubit, specificUserId: specificUserId, specificUserName: specificUserName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0.5,
          title: Text('أجهزة وتوكنز الإشعارات (FCM)', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded), color: AppColors.textPrimary, tooltip: 'تحديث', onPressed: () => _cubit.loadTokens())],
        ),
        body: BlocBuilder<AdminPushTokensCubit, AdminPushTokensState>(
          builder: (context, state) {
            if (state.status == AdminPushTokensStatus.loading && state.allTokens.isEmpty) return Center(child: CircularProgressIndicator(color: AppColors.adminPrimary));
            if (state.status == AdminPushTokensStatus.error && state.allTokens.isEmpty) return Center(child: Text('تعذر تحميل توكنز الإشعارات', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w700)));

            return RefreshIndicator(
              onRefresh: () => _cubit.loadTokens(),
              color: AppColors.adminPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PushTokensActionButtons(onSendInstant: () => _openSendDialog(), onCopyAll: () => showDialog(context: context, builder: (_) => CopyTokensOptionsDialog(tokens: state.filteredTokens))),
                    SizedBox(height: 16.h),
                    PushTokensStatsRow(totalCount: state.totalCount, studentsCount: state.studentsCount, teachersCount: state.teachersCount),
                    SizedBox(height: 16.h),
                    TextField(controller: _searchController, onChanged: (v) => _cubit.search(v), decoration: InputDecoration(hintText: 'ابحث بالاسم، الإيميل، أو التوكن...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))))),
                    SizedBox(height: 12.h),
                    PushTokensFilterChips(roleFilter: state.roleFilter, platformFilter: state.platformFilter, totalCount: state.totalCount, studentsCount: state.studentsCount, teachersCount: state.teachersCount, androidCount: state.androidCount, iosCount: state.iosCount, onSelectRole: (r) => _cubit.filterByRole(r), onSelectPlatform: (p) => _cubit.filterByPlatform(p)),
                    SizedBox(height: 16.h),
                    Text('التوكنز المسجلة (${state.filteredTokens.length})', style: GoogleFonts.cairo(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    SizedBox(height: 10.h),
                    if (state.filteredTokens.isEmpty) Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 30.h), child: Text('لا توجد توكنز مطابقة', style: GoogleFonts.cairo(fontSize: 13.5.sp, color: AppColors.textSecondary))))
                    else ListView.separated(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: state.filteredTokens.length, separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (ctx, i) => PushTokenCardItem(item: state.filteredTokens[i], onSendDirect: () => _openSendDialog(specificUserId: state.filteredTokens[i]['user_id'] as String?, specificUserName: state.filteredTokens[i]['full_name'] as String?)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
