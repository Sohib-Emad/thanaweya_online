import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  late List<Map<String, String>> _subjects;

  @override
  void initState() {
    super.initState();
    _subjects = List<Map<String, String>>.from(MockData.mockSubjects);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.manageSubjects),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddDialog,
            ),
          ],
        ),
        body: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: _subjects.length,
          itemBuilder: (context, index) {
            final subject = _subjects[index];
            return AppCard(
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.studentPrimaryLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.studentPrimary,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      subject['name_ar'] ?? '',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20.r,
                      color: AppColors.error,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _subjects.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog() {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مادة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameArController,
              labelText: 'الاسم بالعربي',
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: nameEnController,
              labelText: 'الاسم بالإنجليزي',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              if (nameArController.text.isNotEmpty &&
                  nameEnController.text.isNotEmpty) {
                HapticFeedback.lightImpact();
                setState(() {
                  _subjects.add({
                    'id': 's${_subjects.length + 1}',
                    'name_ar': nameArController.text.trim(),
                    'name_en': nameEnController.text.trim(),
                  });
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}
