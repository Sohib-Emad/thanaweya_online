import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/correct_answer_selector.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/image_attachment_field.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/question_type_selector.dart';

/// Bottom sheet for creating a new exam question.
class AddQuestionSheet extends StatefulWidget {
  const AddQuestionSheet({super.key, required this.onAdded});
  final ValueChanged<Map<String, dynamic>> onAdded;

  static void show(BuildContext context, {required ValueChanged<Map<String, dynamic>> onAdded}) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => AddQuestionSheet(onAdded: onAdded),
    );
  }

  @override
  State<AddQuestionSheet> createState() => _AddQuestionSheetState();
}

class _AddQuestionSheetState extends State<AddQuestionSheet> {
  String _type = 'mcq';
  int _correctIndex = 0;
  File? _pickedImage;
  final _questionCtrl = TextEditingController();
  final _opt1 = TextEditingController();
  final _opt2 = TextEditingController();
  final _opt3 = TextEditingController();
  final _opt4 = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '5');

  @override
  void dispose() {
    for (final c in [_questionCtrl, _opt1, _opt2, _opt3, _opt4, _pointsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _setType(String value) {
    _type = value;
    if (value == 'true_false') {
      _opt1.text = 'صواب (صح)';
      _opt2.text = 'خطأ (غير صحيح)';
    }
  }

  void _save() {
    if (_questionCtrl.text.trim().isEmpty) return;
    final options = _type == 'true_false'
        ? ['صواب (صح)', 'خطأ (غير صحيح)']
        : [_opt1.text, _opt2.text, _opt3.text, _opt4.text].where((t) => t.isNotEmpty).toList();
    widget.onAdded({
      'type': _type, 'question': _questionCtrl.text.trim(),
      'options': options, 'correct_answers': [_correctIndex.toString()],
      'points': int.tryParse(_pointsCtrl.text.trim()) ?? 5, 'image_file': _pickedImage,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(
                      width: 40.w, height: 4.h,
                      decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)))),
                  SizedBox(height: 12.h),
                  Text('إضافة سؤال جديد', style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 12.h),
                  QuestionTypeSelector(currentType: _type, onTypeChanged: (v) => setSheetState(() => _setType(v))),
                  SizedBox(height: 14.h),
                  DeskInputField(label: 'نص السؤال', controller: _questionCtrl, hint: 'اكتب نص السؤال هنا...', maxLines: 2),
                  SizedBox(height: 10.h),
                  ImageAttachmentField(
                    pickedImage: _pickedImage,
                    onPick: () async {
                      final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (f != null) {
                        setSheetState(() => _pickedImage = File(f.path));
                      }
                    },
                    onClear: () => setSheetState(() => _pickedImage = null),
                  ),
                  SizedBox(height: 14.h),
                  if (_type != 'true_false') ...[
                    DeskInputField(label: 'الخيار الأول (أ)', controller: _opt1, hint: 'نص الخيار الأول'),
                    SizedBox(height: 8.h),
                    DeskInputField(label: 'الخيار الثاني (ب)', controller: _opt2, hint: 'نص الخيار الثاني'),
                    SizedBox(height: 8.h),
                    DeskInputField(label: 'الخيار الثالث (ج)', controller: _opt3, hint: 'نص الخيار الثالث'),
                    SizedBox(height: 8.h),
                    DeskInputField(label: 'الخيار الرابع (د)', controller: _opt4, hint: 'نص الخيار الرابع'),
                    SizedBox(height: 12.h),
                  ],
                  CorrectAnswerSelector(type: _type, currentIndex: _correctIndex,
                      onChanged: (idx) => setSheetState(() => _correctIndex = idx)),
                  SizedBox(height: 14.h),
                  DeskInputField(label: 'درجة السؤال', controller: _pointsCtrl, hint: '5', keyboardType: TextInputType.number),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity, height: 44.h,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DeskColors.primary, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('حفظ وإضافة السؤال', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
