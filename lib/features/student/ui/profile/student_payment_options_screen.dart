import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'خيارات وسائل الدفع (Payment Option)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child:
                      state.methodsStatus == StudentPaymentsStatus.loading &&
                          state.paymentMethods.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.paymentMethods.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card_off_rounded,
                                size: 64,
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'لا توجد بطاقات محفوظة',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'اضغط على زر الإضافة لحفظ بطاقة جديدة',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
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
                              return Container(
                                margin: EdgeInsets.only(bottom: 14.h),
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x060F172A),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44.r,
                                          height: 44.r,
                                          decoration: BoxDecoration(
                                            color: AppColors.studentPrimary
                                                .withAlpha(15),
                                            borderRadius: BorderRadius.circular(
                                              14.r,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.credit_card_rounded,
                                            color: AppColors.studentPrimary,
                                            size: 24.r,
                                          ),
                                        ),
                                        SizedBox(width: 14.w),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cardHolder,
                                              style: GoogleFonts.cairo(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                            Text(
                                              '•••• •••• •••• $cardLast4',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12.sp,
                                                color: const Color(0xFF64748B),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Connected Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: Text(
                                        isDefault
                                            ? 'الافتراضية • Default'
                                            : 'متصل • Connected',
                                        style: GoogleFonts.cairo(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0FA37F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),

                // Bottom Add New Card Button
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await Navigator.pushNamed(
                          context,
                          AppRouter.studentAddCard,
                        );
                        _loadMethods();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        elevation: 4,
                        shadowColor: const Color(0x332563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'إضافة بطاقة جديدة (Add New Card)',
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            width: 34.r,
                            height: 34.r,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: const Color(0xFF2563EB),
                              size: 20.r,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
