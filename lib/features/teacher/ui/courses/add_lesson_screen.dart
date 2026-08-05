// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// NEW LESSON BOARD: writing a new lesson is scribbling a new frame on the
//   board — a chalk mode switch (يوتيوب / رفع مباشر), chalk-underline
//   fields for title, notes and the video link, and a mint chalk save
//   button that hands the lesson to the shared courses cubit.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';

class AddLessonScreen extends StatefulWidget {
  final String courseId;

  const AddLessonScreen({super.key, required this.courseId});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeController = TextEditingController();
  bool _isFreePreview = false;
  bool _isSaving = false;
  int _sourceIndex = 0;
  XFile? _videoFile;
  final ImagePicker _picker = ImagePicker();
  late final TeacherCoursesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());
  }

  void _showChalkSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ChalkboardColors.accentDeep,
        content: Text(message, style: ChalkboardText.strong(12.sp)),
      ),
    );
  }

  Future<void> _pickVideo() async {
    HapticFeedback.lightImpact();
    try {
      final XFile? file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 60),
      );
      if (file != null) {
        setState(() => _videoFile = file);
      }
    } catch (e) {
      _showChalkSnack('تعذر اختيار الفيديو من جهازك');
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final isUpload = _sourceIndex == 1;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      setState(() => _isSaving = false);
      return;
    }

    if (isUpload && _videoFile == null) {
      setState(() => _isSaving = false);
      _showChalkSnack('برجاء اختيار ملف الفيديو أولاً');
      return;
    }

    String videoUrl;
    if (isUpload) {
      final uploaded = await StorageHelper.uploadLessonVideo(
        teacherId: userId,
        courseId: widget.courseId,
        file: _videoFile!,
      );
      if (uploaded == null) {
        setState(() => _isSaving = false);
        _showChalkSnack('فشل رفع الفيديو، برجاء المحاولة مرة أخرى');
        return;
      }
      videoUrl = uploaded;
    } else {
      videoUrl = _youtubeController.text.trim();
    }

    await _cubit.addLesson(
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      videoSourceType: isUpload ? 'upload' : 'youtube',
      videoUrlOrId: videoUrl,
      isFreePreview: _isFreePreview,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ChalkboardColors.accentDeep,
          content: Text(
            'تم حفظ وإضافة الدرس بنجاح',
            style: ChalkboardText.strong(12.sp),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        appBar: ChalkTopBar(
          title: 'إضافة درس جديد',
          subtitle: 'اكتب الدرس على السبورة',
        ),
        body: ChalkboardSurface(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChalkSegmentedControl(
                      options: const ['رابط يوتيوب', 'رفع مباشر'],
                      index: _sourceIndex,
                      onChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _sourceIndex = i);
                      },
                    ),

                    SizedBox(height: 24.h),

                    ChalkInputField(
                      label: 'عنوان الدرس',
                      controller: _titleController,
                      icon: Icons.play_circle_outline_rounded,
                      hint: 'أدخل اسم أو عنوان الدرس...',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
                    ),

                    SizedBox(height: 18.h),

                    ChalkInputField(
                      label: 'وصف الدرس والتفاصيل',
                      controller: _descriptionController,
                      icon: Icons.notes_rounded,
                      hint: 'اكتب الشرح المباشر والنقاط الهامة بالدرس...',
                      maxLines: 3,
                    ),

                    SizedBox(height: 18.h),

                    if (_sourceIndex == 0)
                      ChalkInputField(
                        label: 'رابط الفيديو أو اليوتيوب',
                        controller: _youtubeController,
                        icon: Icons.link_rounded,
                        hint: 'https://youtube.com/watch?v=...',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'الحقل مطلوب'
                            : null,
                      )
                    else ...[
                      Text(
                        'ملف الفيديو',
                        style: ChalkboardText.strong(12.sp),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: _pickVideo,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: _videoFile != null
                                ? ChalkboardColors.accent.withAlpha(22)
                                : ChalkboardColors.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: _videoFile != null
                                  ? ChalkboardColors.accent.withAlpha(190)
                                  : ChalkboardColors.ink.withAlpha(60),
                              width: _videoFile != null ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color: _videoFile != null
                                      ? ChalkboardColors.accent
                                      : ChalkboardColors.accent.withAlpha(22),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _videoFile != null
                                      ? Icons.check_rounded
                                      : Icons.video_file_outlined,
                                  color: _videoFile != null
                                      ? ChalkboardColors.onAccent
                                      : ChalkboardColors.accent,
                                  size: 22.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _videoFile != null
                                          ? _videoFile!.name
                                          : 'اختيار فيديو من جهازك',
                                      style: ChalkboardText.strong(13.sp),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      _videoFile != null
                                          ? 'تم اختيار الملف بنجاح'
                                          : 'MP4 / MOV · يُرفع إلى خوادم المنصة',
                                      style: ChalkboardText.note(11.sp),
                                    ),
                                  ],
                                ),
                              ),
                              if (_videoFile != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _videoFile = null);
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: ChalkboardColors.chalkRed,
                                    size: 20.r,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 20.h),

                    ChalkCard(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: ChalkboardColors.accent.withAlpha(30),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ChalkboardColors.accent.withAlpha(120),
                              ),
                            ),
                            child: Icon(
                              Icons.card_giftcard_rounded,
                              size: 20.r,
                              color: ChalkboardColors.accent,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'معاينة مجانية',
                                  style: ChalkboardText.strong(14.sp),
                                ),
                                Text(
                                  'السماح للطلاب غير المشتركين بمشاهدة هذا الدرس تجريبياً',
                                  style: ChalkboardText.note(11.sp),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isFreePreview,
                            activeThumbColor: ChalkboardColors.accent,
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setState(() => _isFreePreview = v);
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    ChalkPrimaryButton(
                      label: 'حفظ الدرس',
                      icon: Icons.check_rounded,
                      loading: _isSaving,
                      onPressed: _isSaving ? null : _saveLesson,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
