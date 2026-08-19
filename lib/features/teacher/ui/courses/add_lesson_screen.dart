import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/widgets.dart';

/// Screen for adding a new lesson — Dailymotion, YouTube, or upload.
class AddLessonScreen extends StatefulWidget {
  final String courseId;
  const AddLessonScreen({super.key, required this.courseId});
  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _urlCtl = TextEditingController();
  final _picker = ImagePicker();
  late final TeacherCoursesCubit _cubit;
  bool _isFreePreview = false;
  bool _isSaving = false;
  int _sourceIndex = 0;
  XFile? _videoFile;

  @override
  void initState() {
    super.initState();
    _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());
  }

  @override
  void dispose() {
    _cubit.close();
    _titleCtl.dispose();
    _descCtl.dispose();
    _urlCtl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DeskColors.primaryDeep,
        content: Text(msg, style: DeskText.strong(12.sp)),
      ),
    );
  }

  Future<void> _pickVideo() async {
    HapticFeedback.lightImpact();
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 60),
      );
      if (file != null) setState(() => _videoFile = file);
    } catch (_) {
      _showSnack('تعذر اختيار الفيديو من جهازك');
    }
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) { setState(() => _isSaving = false); return; }
    final isUpload = _sourceIndex == 2;
    if (isUpload && _videoFile == null) {
      setState(() => _isSaving = false);
      _showSnack('برجاء اختيار ملف الفيديو أولاً');
      return;
    }
    String videoUrl, sourceType;
    if (isUpload) {
      final uploaded = await StorageHelper.uploadLessonVideo(
        teacherId: userId, courseId: widget.courseId, file: _videoFile!,
      );
      if (uploaded == null) {
        setState(() => _isSaving = false);
        _showSnack('فشل رفع الفيديو، برجاء المحاولة مرة أخرى');
        return;
      }
      videoUrl = uploaded;
      sourceType = 'upload';
    } else {
      videoUrl = _urlCtl.text.trim();
      sourceType = _sourceIndex == 0 ? 'dailymotion' : 'youtube';
    }
    final desc = _descCtl.text.trim();
    await _cubit.addLesson(
      courseId: widget.courseId,
      title: _titleCtl.text.trim(),
      description: desc.isNotEmpty ? desc : null,
      videoSourceType: sourceType,
      videoUrlOrId: videoUrl,
      isFreePreview: _isFreePreview,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      _showSnack('تم حفظ وإضافة الدرس بنجاح');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(title: 'إضافة درس جديد', subtitle: 'اكتب الدرس في مكتبك'),
        body: DeskSurface(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: LessonFormBody(
                formKey: _formKey,
                titleController: _titleCtl,
                descriptionController: _descCtl,
                urlController: _urlCtl,
                sourceIndex: _sourceIndex,
                isFreePreview: _isFreePreview,
                isSaving: _isSaving,
                videoFile: _videoFile,
                onSourceChanged: (i) => setState(() => _sourceIndex = i),
                onPreviewToggled: (v) => setState(() => _isFreePreview = v),
                onPickVideo: _pickVideo,
                onClearVideo: () => setState(() => _videoFile = null),
                onSave: _isSaving ? null : _saveLesson,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
