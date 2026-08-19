import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import '../../../../core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'widgets/widgets.dart';

/// Screen for viewing and managing saved payment cards.
class StudentPaymentOptionsScreen extends StatefulWidget {
  /// Creates a [StudentPaymentOptionsScreen].
  const StudentPaymentOptionsScreen({super.key});

  @override
  State<StudentPaymentOptionsScreen> createState() =>
      _StudentPaymentOptionsScreenState();
}

class _StudentPaymentOptionsScreenState
    extends State<StudentPaymentOptionsScreen> {
  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadMethods() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) _cubit.loadPaymentMethods(userId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: l10n.paymentOptionsTitle,
          subtitle: l10n.paymentOptionsSubtitle,
        ),
        body: NotebookPaper(
          child: BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
            bloc: _cubit,
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(child: _buildBody(context, state)),
                  _buildAddButton(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, StudentPaymentsState state) {
    final l10n = context.l10n;
    if (state.methodsStatus == StudentPaymentsStatus.loading &&
        state.paymentMethods.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: NotebookColors.green),
      );
    }
    if (state.paymentMethods.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
        child: NotebookEmptyNote(message: l10n.noSavedCards),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMethods,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        physics: const BouncingScrollPhysics(),
        itemCount: state.paymentMethods.length,
        itemBuilder: (context, index) {
          final m = state.paymentMethods[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: PaymentCardTile(
              cardHolder: (m['card_holder'] as String?) ?? l10n.defaultCardFallback,
              cardLast4: (m['card_last4'] as String?) ?? '••••',
              isDefault: (m['is_default'] as bool?) ?? false,
              defaultLabel: l10n.defaultCardLabel,
              connectedLabel: l10n.connectedCardLabel,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
      child: NotebookPrimaryButton(
        label: context.l10n.addNewCardButton,
        icon: Icons.add_rounded,
        onPressed: () async {
          HapticFeedback.mediumImpact();
          await Navigator.pushNamed(context, AppRouter.studentAddCard);
          _loadMethods();
        },
      ),
    );
  }
}
