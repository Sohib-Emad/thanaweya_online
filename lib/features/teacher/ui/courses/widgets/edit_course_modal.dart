import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/services/teacher_realtime_service.dart';
import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';

/// Bottom sheet modal for editing course details.
class EditCourseModal extends StatefulWidget {
  final CourseModel course;
  final TeacherCoursesRepo coursesRepo;
  final void Function(String) onShowSnack;
  final void Function(CourseModel) onCourseUpdated;

  const EditCourseModal({
    super.key,
    required this.course,
    required this.coursesRepo,
    required this.onShowSnack,
    required this.onCourseUpdated,
  });

  @override
  State<EditCourseModal> createState() => _EditCourseModalState();
}

class _EditCourseModalState extends State<EditCourseModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  bool _isPublished = false;
  XFile? _newCover;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _titleCtrl = TextEditingController(text: c.title);
    _descCtrl = TextEditingController(text: c.description ?? '');
    _priceCtrl = TextEditingController(text: c.price != null && c.price! > 0 ? '${c.price}' : '');
    _isPublished = c.isPublished;
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  Future<void> _pickCover() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (f != null) setState(() => _newCover = f);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    String? coverUrl;
    if (_newCover != null) {
      coverUrl = await StorageHelper.uploadCourseCover(teacherId: userId, courseId: widget.course.id, file: _newCover!);
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    final res = await widget.coursesRepo.updateCourse(
      courseId: widget.course.id, title: title,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      coverImageUrl: coverUrl, price: price, clearPrice: price == null, isPublished: _isPublished,
    );
    res.when(
      success: (_) {
        TeacherRealtimeService.instance.notifyCoursesChanged();
        widget.onCourseUpdated(widget.course.copyWith(title: title, description: _descCtrl.text.trim(), coverImageUrl: coverUrl ?? widget.course.coverImageUrl, price: price, isPublished: _isPublished));
        Navigator.pop(context);
        widget.onShowSnack('تم تحديث بيانات الكورس بنجاح');
      },
      failure: (msg, _) { setState(() => _saving = false); widget.onShowSnack('فشل التحديث: $msg'); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)))),
              SizedBox(height: 14.h),
              Text('تعديل بيانات الكورس', style: DeskText.heading(15.sp)),
              SizedBox(height: 14.h),
              DeskInputField(label: 'عنوان الكورس', controller: _titleCtrl, hint: 'أدخل عنوان الكورس'),
              SizedBox(height: 12.h),
              DeskInputField(label: 'الوصف', controller: _descCtrl, hint: 'اكتب وصفاً مختصراً للكورس...', maxLines: 3),
              SizedBox(height: 12.h),
              DeskInputField(label: 'سعر الكورس (ج.م)', controller: _priceCtrl, hint: 'اتركه فارغاً إذا كان مجانياً', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              SizedBox(height: 14.h),
              Text('صورة الغلاف:', style: DeskText.strong(12.sp)),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: _pickCover,
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(color: DeskColors.surfaceAlt, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: DeskColors.line)),
                  child: Center(child: Text(_newCover != null ? 'تم اختيار صورة جديدة ✓' : 'اضغط لاختيار غلاف جديد من جهازك', style: GoogleFonts.cairo(fontSize: 11.5.sp, color: DeskColors.primary, fontWeight: FontWeight.w700))),
                ),
              ),
              SizedBox(height: 14.h),
              Row(children: [
                Switch(value: _isPublished, activeTrackColor: DeskColors.primary, onChanged: (v) => setState(() => _isPublished = v)),
                Text(_isPublished ? 'الكورس منشور ومتاح للطلاب' : 'الكورس كمسودة غير منشورة', style: DeskText.strong(12.sp)),
              ]),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity, height: 48.h,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: DeskColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('حفظ التعديلات', style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
