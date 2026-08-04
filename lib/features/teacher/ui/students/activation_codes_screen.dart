import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_students_cubit.dart';

class ActivationCodesScreen extends StatefulWidget {
  const ActivationCodesScreen({super.key});

  @override
  State<ActivationCodesScreen> createState() => _ActivationCodesScreenState();
}

class _ActivationCodesScreenState extends State<ActivationCodesScreen> {
  final _cubit = TeacherStudentsCubit(repo: TeacherStudentsRepo());

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadCodes() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadActivationCodes(userId);
    }
  }

  void _generateCode() {
    HapticFeedback.heavyImpact();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.generateCodes(teacherId: userId, count: 1);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم توليد كود تفعيل جديد بنجاح 🎉')),
    );
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
            icon: Icon(Icons.chevron_right_rounded, color: const Color(0xFF0F172A), size: 28.r),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            AppStrings.generateCodes,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: BlocBuilder<TeacherStudentsCubit, TeacherStudentsState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                // Top Action Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: state.codesStatus == TeacherStudentsStatus.loading ? null : _generateCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teacherPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      ),
                      icon: Icon(Icons.key_rounded, color: Colors.white, size: 20.r),
                      label: Text(
                        'توليد كود تفعيل جديد 🔑',
                        style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                if (state.codesStatus == TeacherStudentsStatus.loading && state.activationCodes.isEmpty)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (state.activationCodes.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('لا توجد أكواد تفعيل بعد', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadCodes,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                        itemCount: state.activationCodes.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final code = state.activationCodes[index];
                          return _CodeCard(
                            codeStr: code.code,
                            isUsed: code.isUsed,
                          );
                        },
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

class _CodeCard extends StatelessWidget {
  final String codeStr;
  final bool isUsed;

  const _CodeCard({required this.codeStr, required this.isUsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isUsed ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUsed ? Icons.lock_clock_rounded : Icons.key_rounded,
              color: isUsed ? const Color(0xFFD97706) : const Color(0xFF0FA37F),
              size: 20.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  codeStr,
                  style: GoogleFonts.robotoMono(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), letterSpacing: 1.2),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isUsed ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    isUsed ? 'مستخدم بالفعل' : 'متاح للتفعيل ✓',
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: isUsed ? const Color(0xFFD97706) : const Color(0xFF0FA37F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Clipboard.setData(ClipboardData(text: codeStr));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم نسخ الكود ($codeStr) إلى الحافظة 📋')),
              );
            },
            icon: Icon(Icons.content_copy_rounded, color: const Color(0xFF2563EB), size: 20.r),
          ),
        ],
      ),
    );
  }
}
