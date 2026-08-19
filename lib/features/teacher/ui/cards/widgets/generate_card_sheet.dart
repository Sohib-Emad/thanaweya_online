import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_cards_cubit.dart';

/// Bottom sheet for generating new activation cards.
class GenerateCardSheet extends StatefulWidget {
  final String teacherId;
  final List<CourseModel> teacherCourses;
  final TeacherCardsCubit cardsCubit;

  const GenerateCardSheet({super.key, required this.teacherId, required this.teacherCourses, required this.cardsCubit});

  static Future<void> show(BuildContext context, {required String teacherId, required List<CourseModel> teacherCourses, required TeacherCardsCubit cardsCubit}) {
    return showModalBottomSheet(
      context: context, backgroundColor: DeskColors.surface, isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => GenerateCardSheet(teacherId: teacherId, teacherCourses: teacherCourses, cardsCubit: cardsCubit),
    );
  }

  @override
  State<GenerateCardSheet> createState() => _GenerateCardSheetState();
}

class _GenerateCardSheetState extends State<GenerateCardSheet> {
  String? _selectedCourseId;
  int _selectedCount = 5;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setModalState) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: DeskColors.line, borderRadius: BorderRadius.circular(10.r)),
            )),
            SizedBox(height: 16.h),
            Text('توليد كروت تفعيل جديدة', style: DeskText.heading(17.sp)),
            SizedBox(height: 4.h),
            Text('قم باختيار العدد والكورس لإنشاء كروت اشتراك جاهزة للطباعة والتوزيع', style: DeskText.note(11.sp)),
            SizedBox(height: 18.h),
            Text('الكورس المستهدف:', style: DeskText.strong(13.sp)),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String?>(
              initialValue: _selectedCourseId, dropdownColor: DeskColors.surface, style: DeskText.body(13.sp),
              decoration: InputDecoration(
                filled: true, fillColor: DeskColors.surfaceAlt,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: DeskColors.line)),
              ),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text('جميع كورسات المدرس', style: DeskText.body(13.sp))),
                ...widget.teacherCourses.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.title, style: DeskText.body(13.sp)))),
              ],
              onChanged: (val) => setModalState(() => _selectedCourseId = val),
            ),
            SizedBox(height: 18.h),
            Text('عدد الكروت:', style: DeskText.strong(13.sp)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w, runSpacing: 8.h,
              children: [1, 5, 10, 20, 50].map((cnt) {
                final sel = _selectedCount == cnt;
                return ChoiceChip(
                  label: Text('$cnt كرت', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: sel ? DeskColors.onPrimary : DeskColors.muted)),
                  selected: sel, selectedColor: DeskColors.primary, backgroundColor: DeskColors.surfaceAlt,
                  onSelected: (_) => setModalState(() => _selectedCount = cnt),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            BlocBuilder<TeacherCardsCubit, TeacherCardsState>(
              bloc: widget.cardsCubit,
              builder: (context, state) {
                return DeskPrimaryButton(
                  label: 'إنشاء $_selectedCount كرت تفعيل الآن', icon: Icons.add_card_rounded,
                  loading: state.isGenerating,
                  onPressed: () async {
                    final ok = await widget.cardsCubit.generateCodes(teacherId: widget.teacherId, courseId: _selectedCourseId, count: _selectedCount);
                    if (ok && context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ]),
        ),
      );
    });
  }
}
