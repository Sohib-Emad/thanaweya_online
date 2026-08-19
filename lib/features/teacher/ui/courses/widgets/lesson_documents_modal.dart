import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';

/// Bottom sheet modal for managing lesson documents and attachments.
class LessonDocumentsModal extends StatefulWidget {
  final LessonModel lesson;
  final TeacherCoursesRepo coursesRepo;

  const LessonDocumentsModal({super.key, required this.lesson, required this.coursesRepo});

  @override
  State<LessonDocumentsModal> createState() => _LessonDocumentsModalState();
}

class _LessonDocumentsModalState extends State<LessonDocumentsModal> {
  bool _loading = true;
  bool _uploading = false;
  List<Map<String, dynamic>> _docs = [];

  @override
  void initState() { super.initState(); _loadDocs(); }

  Future<void> _loadDocs() async {
    setState(() => _loading = true);
    final res = await widget.coursesRepo.lessonsRepo.documents.getLessonDocuments(widget.lesson.id);
    if (!mounted) return;
    res.when(
      success: (docs) => setState(() { _docs = docs; _loading = false; }),
      failure: (_, _) => setState(() => _loading = false),
    );
  }

  Future<void> _pickAndUpload() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg']);
    if (res == null || res.files.single.path == null) return;
    final file = XFile(res.files.single.path!);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => _uploading = true);
    final url = await StorageHelper.uploadLessonDocument(teacherId: userId, lessonId: widget.lesson.id, file: file);
    if (url != null) {
      await widget.coursesRepo.lessonsRepo.documents.addLessonDocument(lessonId: widget.lesson.id, title: res.files.single.name, fileUrl: url, fileType: res.files.single.name.split('.').last.toLowerCase());
      _loadDocs();
    }
    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ملازم ومرفقات المحاضرة', style: DeskText.heading(15.sp)),
                ElevatedButton.icon(
                  onPressed: _uploading ? null : _pickAndUpload,
                  style: ElevatedButton.styleFrom(backgroundColor: DeskColors.primary, foregroundColor: Colors.white, minimumSize: Size.zero, padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                  icon: _uploading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.8)) : const Icon(Icons.upload_file_rounded, size: 16),
                  label: Text('رفع ملزمة (PDF)', style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_loading)
              const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: DeskColors.primary))
            else if (_docs.isEmpty)
              Center(child: Padding(padding: EdgeInsets.all(24.r), child: Text('لا توجد ملازم أو ملفات مرفقة مع هذه المحاضرة بعد.', style: DeskText.note(12.sp))))
            else
              ..._docs.map((doc) => Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(color: DeskColors.surfaceAlt, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: DeskColors.line)),
                child: Row(children: [
                  Icon(Icons.picture_as_pdf_rounded, color: DeskColors.danger, size: 22.r),
                  SizedBox(width: 10.w),
                  Expanded(child: Text(doc['title'] as String? ?? 'ملف ملزمة', style: DeskText.strong(12.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: DeskColors.danger, size: 18.r),
                    onPressed: () async {
                      final docId = doc['id'] as String?;
                      if (docId != null) { await widget.coursesRepo.lessonsRepo.documents.deleteLessonDocument(docId); _loadDocs(); }
                    },
                  ),
                ]),
              )),
          ],
        ),
      ),
    );
  }
}
