import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/notebook_theme.dart';

class StudentTermsScreen extends StatelessWidget {
  const StudentTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'الشروط والأحكام',
          subtitle: 'قواعد الدفتر والمنصة',
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotebookSectionHeader(title: 'شروط الحضور والالتحاق'),
                SizedBox(height: 12.h),
                NotebookCard(
                  ruled: true,
                  ruledStartY: 20,
                  borderRadius: 12,
                  child: Text(
                    'تلتزم منصة الثانوية أونلاين بتقديم أفضل المحتويات المعتمدة والدروس التعليمية عالية الجودة. يتعهد الطالب بالحضور والمتابعة المستمرة للحصص والامتحانات المقررة. يمنع منعا باتا مشاركة الحسابات الشخصية أو إعادة بيع المحتوى التعليمي بدون إذن كتابي مسبق.',
                    style: NotebookText.body(13.sp).copyWith(height: 1.6),
                  ),
                ),

                SizedBox(height: 24.h),

                NotebookSectionHeader(title: 'شروط الاستخدام والخدمة'),
                SizedBox(height: 12.h),
                NotebookCard(
                  ruled: true,
                  ruledStartY: 20,
                  borderRadius: 12,
                  child: Text(
                    'جميع حقوق الملكية الفكرية والعلامات التجارية والمواد التوضيحية محفوظة لمنصة الثانوية أونلاين والمعلمين المعتمدين. يتم تشفير وسائط الفيديو وحمايتها، وأي محاولة لتسجيل الشاشة أو قرصنة المحتوى تعرض الحساب للحظر النهائي والملاحقة القانونية.',
                    style: NotebookText.body(13.sp).copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
