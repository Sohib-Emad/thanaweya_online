import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentTermsScreen extends StatelessWidget {
  const StudentTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'الشروط والأحكام (Terms & Conditions)',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1
              Text(
                'شروط الحضور والالتحاق (Condition & Attending)',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'تلتزم منصة الثانوية أونلاين بتقديم أفضل المحتويات المعتمدة والدروس التعليمية عالية الجودة. يتعهد الطالب بالحضور والمتابعة المستمرة للحصص والامتحانات المقررة. يمنع منعا باتا مشاركة الحسابات الشخصية أو إعادة بيع المحتوى التعليمي بدون إذن كتابي مسبق.',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                'At enim hic etiam dolore. Dulce amarum, leve asperum, prope longe, stare movere, quadratum rotundum. At certe gravius. Nullus est igitur cuiusquam dies natalis. Paulum, cum regem Persem captum adduceret, eodem flumine invectio?',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),
              const Divider(color: Color(0xFFE2E8F0)),
              SizedBox(height: 20.h),

              // Section 2
              Text(
                'شروط الاستخدام والخدمة (Terms & Use)',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'جميع حقوق الملكية الفكرية والعلامات التجارية والمواد التوضيحية محفوظة لمنصة الثانوية أونلاين والمعلمين المعتمدين. يتم تشفير وسائط الفيديو وحمايتها، وأي محاولة لتسجيل الشاشة أو قرصنة المحتوى تعرض الحساب للحظر النهائي والملاحقة القانونية.',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                'Ut proverbia non nulla veriora sint quam vestra dogmata. Tamen aberramus a proposito, et, ne longius, prorsus, inquam, Piso, si ista mala sunt, placet. Omnes enim iucundum motum, quo sensus hilaretur. Cum id fugiunt, re eadem defendunt, quae Peripatetici, verba. Quibusnam praeteritis?',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
