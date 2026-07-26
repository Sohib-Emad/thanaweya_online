import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/supabase/supabase_client.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.createExam),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.h),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.examTitle,
                    ),
                    validator: (v) =>
                        v!.isEmpty ? AppStrings.fieldRequired : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.duration,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    title: Text(
                      _startDate != null
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : AppStrings.startDate,
                      style: AppTextStyles.body2,
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _startDate = date);
                    },
                  ),
                  ListTile(
                    title: Text(
                      _endDate != null
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : AppStrings.endDate,
                      style: AppTextStyles.body2,
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _endDate = date);
                    },
                  ),
                  SizedBox(height: 32.h),
                  AppButton(
                    text: AppStrings.save,
                    onPressed: _onSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      final userId = SupabaseClientHelper.userId;
      if (userId != null) {
        context.read<TeacherExamsCubit>().createExam(
              teacherId: userId,
              title: _titleController.text.trim(),
              durationMinutes: int.tryParse(_durationController.text) ?? 60,
              startAt: _startDate!,
              endAt: _endDate!,
            );
      }
      Navigator.pop(context);
    }
  }
}
