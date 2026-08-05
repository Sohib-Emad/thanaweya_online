import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';

class StudentPaymentOptionsScreen extends StatefulWidget {
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
    if (userId != null) {
      _cubit.loadPaymentMethods(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'خيارات وسائل الدفع',
          subtitle: 'بطاقاتك المسجلة في الدفتر',
        ),
        body: NotebookPaper(
          child: BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
            bloc: _cubit,
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child:
                        state.methodsStatus ==
                                StudentPaymentsStatus.loading &&
                            state.paymentMethods.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              color: NotebookColors.green,
                            ),
                          )
                        : state.paymentMethods.isEmpty
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                            child: NotebookEmptyNote(
                              message: 'لا توجد بطاقات محفوظة بعد',
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMethods,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                16.h,
                                20.w,
                                20.h,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.paymentMethods.length,
                              itemBuilder: (context, index) {
                                final method = state.paymentMethods[index];
                                final cardHolder =
                                    method['card_holder'] as String? ??
                                    'بطاقة مصرفية';
                                final cardLast4 =
                                    method['card_last4'] as String? ?? '••••';
                                final isDefault =
                                    method['is_default'] as bool? ?? false;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 14.h),
                                  child: NotebookCard(
                                    ruled: true,
                                    ruledStartY: 40,
                                    marginTab: isDefault,
                                    borderRadius: 12,
                                    padding: EdgeInsets.all(16.r),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44.r,
                                          height: 44.r,
                                          decoration: BoxDecoration(
                                            color: NotebookColors.surfaceBright,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            border: Border.all(
                                              color: NotebookColors.ink
                                                  .withAlpha(28),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.credit_card_rounded,
                                            color: NotebookColors.ink,
                                            size: 24.r,
                                          ),
                                        ),
                                        SizedBox(width: 14.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cardHolder,
                                                style: NotebookText.strong(
                                                  13.sp,
                                                ),
                                              ),
                                              Text(
                                                '•••• •••• •••• $cardLast4',
                                                style: NotebookText.note(
                                                  12.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDefault
                                                ? NotebookColors.green
                                                : NotebookColors.surfaceBright,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            border: Border.all(
                                              color: isDefault
                                                  ? NotebookColors.green
                                                  : NotebookColors.ink
                                                      .withAlpha(40),
                                            ),
                                          ),
                                          child: Text(
                                            isDefault
                                                ? 'الافتراضية'
                                                : 'متصلة',
                                            style: GoogleFonts.cairo(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w800,
                                              color: isDefault
                                                  ? Colors.white
                                                  : NotebookColors.pencil,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
                    child: NotebookPrimaryButton(
                      label: 'إضافة بطاقة جديدة',
                      icon: Icons.add_rounded,
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await Navigator.pushNamed(
                          context,
                          AppRouter.studentAddCard,
                        );
                        _loadMethods();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
