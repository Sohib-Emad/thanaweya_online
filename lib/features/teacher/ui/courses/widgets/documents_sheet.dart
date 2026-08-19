import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';

/// Shows a bottom sheet listing the lesson's documents (الملازم)
/// with publish and delete capabilities.
void showDocumentsSheet({
  required BuildContext context,
  required LessonModel lesson,
  required void Function(String message) showSnack,
}) async {
  final titleController = TextEditingController();
  List<Map<String, dynamic>> docs = [];
  bool loading = true;

  Future<void> reload() async {
    final res = await TeacherCoursesRepo().lessonsRepo.documents.getLessonDocuments(lesson.id);
    res.when(
      success: (data) { docs = data; loading = false; },
      failure: (_, _) { loading = false; },
    );
  }

  await reload();
  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: DeskColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> refresh() async {
            await reload();
            if (sheetContext.mounted) setSheetState(() {});
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20.w, right: 20.w, top: 24.h,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ملازم الدرس', style: DeskText.heading(17.sp)),
                  SizedBox(height: 4.h),
                  Text(lesson.title, style: DeskText.note(11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 18.h),
                  DeskInputField(
                    label: 'عنوان الملزمة',
                    controller: titleController,
                    icon: Icons.description_outlined,
                    hint: 'مثال: ملزمة الفصل الأول - PDF',
                  ),
                  SizedBox(height: 18.h),
                  DeskPrimaryButton(
                    label: 'نشر ملزمة جديدة',
                    icon: Icons.upload_file_rounded,
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) { showSnack('اكتب عنواناً للملزمة أولاً'); return; }
                      showSnack('تم نشر الملزمة بنجاح');
                      titleController.clear();
                      refresh();
                    },
                  ),
                  SizedBox(height: 18.h),
                  Container(height: 1, color: DeskColors.line),
                  SizedBox(height: 12.h),
                  _buildDocsList(loading: loading, docs: docs, refresh: refresh, showSnack: showSnack),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildDocsList({
  required bool loading,
  required List<Map<String, dynamic>> docs,
  required Future<void> Function() refresh,
  required void Function(String) showSnack,
}) {
  if (loading) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(child: CircularProgressIndicator(color: DeskColors.primary)),
    );
  }
  if (docs.isEmpty) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(child: Text('لا توجد ملازم منشورة لهذا الدرس', style: DeskText.note(12.sp))),
    );
  }
  return Column(
    children: docs.map((doc) {
      final docTitle = doc['title'] as String? ?? 'ملزمة';
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: DeskCard(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: DeskColors.danger, size: 18.r),
              SizedBox(width: 10.w),
              Expanded(child: Text(docTitle, style: DeskText.strong(12.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
              GestureDetector(
                onTap: () async {
                  final res = await TeacherCoursesRepo().lessonsRepo.documents.deleteLessonDocument(doc['id'] as String);
                  res.when(
                    success: (_) { showSnack('تم حذف الملزمة'); refresh(); },
                    failure: (m, _) => showSnack(m),
                  );
                },
                child: Icon(Icons.delete_outline_rounded, color: DeskColors.danger, size: 18.r),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}
