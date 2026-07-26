import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';

class TeacherSelectionScreen extends StatefulWidget {
  const TeacherSelectionScreen({super.key});

  @override
  State<TeacherSelectionScreen> createState() => _TeacherSelectionScreenState();
}

class _TeacherSelectionScreenState extends State<TeacherSelectionScreen> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(AppStrings.selectTeachers)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: MockData.mockTeachers.length,
                  itemBuilder: (context, index) {
                    final teacher = MockData.mockTeachers[index];
                    final user = teacher['users'] as Map<String, dynamic>;
                    final isSelected = _selectedIds.contains(teacher['id']);
                    final name = user['full_name'] as String;
                    final initials = name.isNotEmpty ? name[0] : 'م';

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(teacher['id']);
                          } else {
                            _selectedIds.add(teacher['id'] as String);
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.studentPrimaryLight
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.studentPrimary
                                : AppColors.borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: AppColors.studentPrimaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.studentPrimary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: AppTextStyles.h3),
                                  SizedBox(height: 2.h),
                                  Text(
                                    (teacher['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: AppColors.studentPrimary, size: 22.r)
                            else
                              Icon(Icons.add_circle_outline,
                                  color: AppColors.textTertiary, size: 22.r),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: '${AppStrings.next} (${_selectedIds.length})',
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () => Navigator.pushNamed(context, AppRouter.studentForm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
