import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGradeFilter = 'الكل';

  final List<String> _gradeFilters = [
    'الكل',
    'الصف الأول الثانوي',
    'الصف الثاني الثانوي',
    'الصف الثالث الثانوي',
    'مسار البكالوريا (IB)',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = MockData.mockStudents.where((student) {
      final user = student['users'] as Map<String, dynamic>;
      final name = (user['full_name'] as String).toLowerCase();
      final email = (user['email'] as String).toLowerCase();
      final phone = ((user['phone'] ?? '') as String).toLowerCase();
      final grade = (student['grade'] ?? '') as String;

      final matchesQuery =
          name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery.toLowerCase());

      final matchesGrade =
          _selectedGradeFilter == 'الكل' || grade == _selectedGradeFilter;

      return matchesQuery && matchesGrade;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF0F172A),
                    size: 28.r,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                )
              : null,
          centerTitle: true,
          title: Text(
            AppStrings.studentsList,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم الطالب، رقم التليفون، أو الإيميل...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 20.r,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(
                      color: AppColors.teacherPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Grade Filter Chips Row (فلتر الصف)
            SizedBox(
              height: 44.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _gradeFilters.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final gradeFilter = _gradeFilters[index];
                  final isSelected = _selectedGradeFilter == gradeFilter;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedGradeFilter = gradeFilter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.teacherPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teacherPrimary
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x200FA37F),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        gradeFilter,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),

            // Students Count Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'عرض ${filteredStudents.length} طالب',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Students List
            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        'لا يوجد طلاب مطابقين للبحث أو الفلتر المحدد',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredStudents.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final user = student['users'] as Map<String, dynamic>;
                        final name = user['full_name'] as String;
                        final email = user['email'] as String;
                        final phone =
                            (user['phone'] ?? '01000000000') as String;
                        final grade =
                            (student['grade'] ?? 'غير محدد') as String;
                        final system = (student['system'] ?? 'عامة') as String;
                        final courses =
                            (student['courses'] as List<dynamic>?) ?? [];
                        final initials = name.isNotEmpty ? name[0] : 'ط';

                        return _StudentCard(
                          name: name,
                          email: email,
                          phone: phone,
                          grade: grade,
                          system: system,
                          coursesCount: courses.length,
                          initials: initials,
                          onTap: () =>
                              _showStudentDetailsModal(context, student),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Student Full Details Bottom Sheet
  void _showStudentDetailsModal(
    BuildContext context,
    Map<String, dynamic> student,
  ) {
    final user = student['users'] as Map<String, dynamic>;
    final name = user['full_name'] as String;
    final email = user['email'] as String;
    final phone = (user['phone'] ?? '01000000000') as String;
    final governorate = (user['governorate'] ?? 'القاهرة') as String;
    final grade = (student['grade'] ?? 'الصف الثالث الثانوي') as String;
    final system = (student['system'] ?? 'عامة (قديم)') as String;
    final courses = (student['courses'] as List<dynamic>?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                children: [
                  // Handle indicator bar
                  SizedBox(height: 12.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Header (Name + Avatar + System Badge)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: const Color(0xFFECFDF5),
                          child: Icon(
                            Icons.person_rounded,
                            size: 32.r,
                            color: const Color(0xFF0FA37F),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.cairo(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: system.contains('IB')
                                          ? const Color(0xFFEFF6FF)
                                          : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      system,
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: system.contains('IB')
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFF0FA37F),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    grade,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  Divider(color: const Color(0xFFF1F5F9), height: 1),

                  // Student Contact & Info List
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.r),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact Details Box
                          Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  icon: Icons.phone_rounded,
                                  title: 'رقم التليفون',
                                  value: phone,
                                ),
                                Divider(
                                  color: const Color(0xFFE2E8F0),
                                  height: 16.h,
                                ),
                                _buildInfoRow(
                                  icon: Icons.email_rounded,
                                  title: 'البريد الإلكتروني',
                                  value: email,
                                ),
                                Divider(
                                  color: const Color(0xFFE2E8F0),
                                  height: 16.h,
                                ),
                                _buildInfoRow(
                                  icon: Icons.location_on_rounded,
                                  title: 'المحافظة',
                                  value: governorate,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Courses & Activation Codes Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'الكورسات وأكواد التفعيل 🔑',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${courses.length} كورس',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Enrolled Courses with Live Activation Switch & WhatsApp Button
                          ...courses.map((course) {
                            final cMap = course as Map<String, dynamic>;
                            final title = cMap['course_title'] as String;
                            final price = cMap['price'] as String;
                            final isActivated = cMap['is_activated'] as bool;
                            final code = cMap['code'] as String;
                            final paymentStatus =
                                cMap['payment_status'] as String;

                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: isActivated
                                      ? const Color(0xFF0FA37F)
                                      : const Color(0xFFE2E8F0),
                                  width: isActivated ? 1.5 : 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x050F172A),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActivated
                                              ? const Color(0xFFECFDF5)
                                              : const Color(0xFFFFFBEB),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Text(
                                          isActivated ? 'مفعل 🔓' : 'مغلق 🔒',
                                          style: GoogleFonts.cairo(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w800,
                                            color: isActivated
                                                ? const Color(0xFF0FA37F)
                                                : const Color(0xFFD97706),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'سعر الكورس: $price | الحالة: $paymentStatus',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),

                                  // Code & Actions Box
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.vpn_key_rounded,
                                          color: const Color(0xFF0FA37F),
                                          size: 18.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            'كود التفعيل: $code',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF0F172A),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.copy_rounded,
                                            color: const Color(0xFF64748B),
                                            size: 18.r,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(text: code),
                                            );
                                            HapticFeedback.lightImpact();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'تم نسخ كود التفعيل: $code',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.h),

                                  // Live Toggle Activation Switch for Teacher
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'حالة تفعيل الكورس للطالب:',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: isActivated,
                                        activeTrackColor: const Color(
                                          0xFF0FA37F,
                                        ),
                                        activeThumbColor: Colors.white,
                                        onChanged: (val) {
                                          HapticFeedback.selectionClick();
                                          setModalState(() {
                                            cMap['is_activated'] = val;
                                            cMap['payment_status'] = val
                                                ? 'تم الدفع 💳'
                                                : 'في انتظار التفعيل ⏳';
                                          });
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 18.r),
        SizedBox(width: 10.w),
        Text(
          '$title: ',
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String grade;
  final String system;
  final int coursesCount;
  final String initials;
  final VoidCallback onTap;

  const _StudentCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.grade,
    required this.system,
    required this.coursesCount,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x050F172A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: const Color(0xFFECFDF5),
              child: Text(
                initials,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF0FA37F),
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: system.contains('IB')
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          system,
                          style: GoogleFonts.cairo(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: system.contains('IB')
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF0FA37F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '$grade • $phone',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$coursesCount كورس مشترك • اضغط لعرض التفاصيل والأكواد 🔑',
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      color: const Color(0xFF0FA37F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF0FA37F)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: const Color(0xFF0FA37F),
                      size: 16.r,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'تفعيل ⚡',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0FA37F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
