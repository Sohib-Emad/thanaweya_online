import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.questionType),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: 0,
          itemBuilder: (context, index) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
