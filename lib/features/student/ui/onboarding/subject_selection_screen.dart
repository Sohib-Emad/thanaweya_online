import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/student/data/repos/student_onboarding_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_onboarding_cubit.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  late final StudentOnboardingCubit _cubit;
  int _selectedSystemIndex = 0; // 0 = عامة (قديم), 1 = نظام البكالوريا (IB)
  final Set<String> _selectedIds = {};

  // مسارات البكالوريا ثابتة (IB tracks)
  final List<Map<String, dynamic>> _baccalaureateTracks = [
    {
      'id': 'track_med',
      'name_ar': 'مسار الطب وعلوم الحياة',
      'icon': Icons.medical_services_rounded,
      'qualifying':
          'يؤهل لكليات: الطب البشري، الصيدلة، الأسنان، العلاج الطبيعي، والتمريض.',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'track_eng',
      'name_ar': 'مسار الهندسة وعلوم الحاسب',
      'icon': Icons.computer_rounded,
      'qualifying':
          'يؤهل لكليات: الهندسة، الحاسبات والمعلومات، والتكنولوجيا الحيوية.',
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 'track_biz',
      'name_ar': 'مسار الأعمال والاقتصاد',
      'icon': Icons.business_center_rounded,
      'qualifying':
          'يؤهل لكليات: التجارة، الاقتصاد والعلوم السياسية، الإعلام، والحقوق.',
      'color': const Color(0xFFD97706),
    },
    {
      'id': 'track_arts',
      'name_ar': 'مسار الآداب والفنون',
      'icon': Icons.palette_rounded,
      'qualifying': 'يؤهل لكليات: الآداب، الألسن، الفنون الجميلة، ودار العلوم.',
      'color': const Color(0xFF9333EA),
    },
  ];

  @override
  void initState() {
    super.initState();
    _cubit = StudentOnboardingCubit(repo: StudentOnboardingRepo());
    _cubit.loadSubjects();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  IconData _getSubjectIcon(String subjectName) {
    if (subjectName.contains('رياضيات')) return Icons.calculate_rounded;
    if (subjectName.contains('فيزياء')) return Icons.electric_bolt_rounded;
    if (subjectName.contains('أحياء') || subjectName.contains('احياء')) {
      return Icons.biotech_rounded;
    }
    if (subjectName.contains('علوم') || subjectName.contains('كيمياء')) {
      return Icons.science_rounded;
    }
    if (subjectName.contains('عربية')) return Icons.auto_stories_rounded;
    if (subjectName.contains('إنجليزية') || subjectName.contains('انجليزية')) {
      return Icons.language_rounded;
    }
    if (subjectName.contains('فرنساوية') ||
        subjectName.contains('ألمانية') ||
        subjectName.contains('إيطالية')) {
      return Icons.translate_rounded;
    }
    if (subjectName.contains('تاريخ') || subjectName.contains('جغرافيا')) {
      return Icons.public_rounded;
    }
    if (subjectName.contains('حاسب') || subjectName.contains('برمجة')) {
      return Icons.computer_rounded;
    }
    if (subjectName.contains('اقتصاد') || subjectName.contains('إحصاء')) {
      return Icons.bar_chart_rounded;
    }
    return Icons.menu_book_rounded;
  }

  Color _getSubjectColor(String subjectName) {
    if (subjectName.contains('رياضيات')) return const Color(0xFF2563EB);
    if (subjectName.contains('فيزياء')) return const Color(0xFFEF4444);
    if (subjectName.contains('أحياء') || subjectName.contains('احياء')) {
      return const Color(0xFF10B981);
    }
    if (subjectName.contains('علوم') || subjectName.contains('كيمياء')) {
      return const Color(0xFFD97706);
    }
    if (subjectName.contains('عربية')) return const Color(0xFF9333EA);
    if (subjectName.contains('إنجليزية') || subjectName.contains('انجليزية')) {
      return const Color(0xFF0284C7);
    }
    return const Color(0xFF0FA37F);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF0F172A),
                size: 28.r,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              AppStrings.selectSubjects,
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 12.h),

                // System Segmented Switcher (عامة قديم vs نظام البكالوريا IB)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedSystemIndex != 0) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedSystemIndex = 0;
                                  _selectedIds.clear();
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _selectedSystemIndex == 0
                                    ? AppColors.studentPrimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Center(
                                child: Text(
                                  'عامة (قديم)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: _selectedSystemIndex == 0
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedSystemIndex != 1) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedSystemIndex = 1;
                                  _selectedIds.clear();
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _selectedSystemIndex == 1
                                    ? AppColors.studentPrimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Center(
                                child: Text(
                                  'نظام البكالوريا (IB)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: _selectedSystemIndex == 1
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // Dynamic View
                Expanded(
                  child: _selectedSystemIndex == 0
                      ? BlocBuilder<StudentOnboardingCubit,
                          StudentOnboardingState>(
                          builder: (context, state) {
                            if (state.status ==
                                StudentOnboardingStatus.loading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state.status ==
                                StudentOnboardingStatus.error) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline_rounded,
                                        size: 48.r, color: AppColors.error),
                                    SizedBox(height: 12.h),
                                    Text(
                                      state.errorMessage ??
                                          'حدث خطأ أثناء تحميل المواد',
                                      style: GoogleFonts.cairo(
                                          fontSize: 14.sp,
                                          color: AppColors.textSecondary),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16.h),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _cubit.loadSubjects(),
                                      child: Text('إعادة المحاولة',
                                          style: GoogleFonts.cairo()),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final subjects = state.subjects;
                            if (subjects.isEmpty) {
                              return Center(
                                child: Text(
                                  'لا توجد مواد متاحة',
                                  style: GoogleFonts.cairo(
                                      fontSize: 15.sp,
                                      color: AppColors.textSecondary),
                                ),
                              );
                            }
                            return _buildGeneralSubjectsGrid(subjects);
                          },
                        )
                      : _buildBaccalaureateTracksList(),
                ),

                // Bottom Action Button
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                  child: BlocBuilder<StudentOnboardingCubit,
                      StudentOnboardingState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: _selectedIds.isEmpty
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  // تمرير الـ IDs المختارة للشاشة التالية
                                  for (final id in _selectedIds) {
                                    _cubit.selectSubject(id);
                                  }
                                  Navigator.pushNamed(
                                      context, AppRouter.studentTeachers);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0FA37F),
                            disabledBackgroundColor:
                                const Color(0xFFCBD5E1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            '${AppStrings.next} (${_selectedIds.length})',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. شبكة المواد العامة من Supabase
  Widget _buildGeneralSubjectsGrid(List<Map<String, dynamic>> subjects) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 1.05,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final subjectId = subject['id'] as String;
        final subjectName = (subject['name_ar'] as String? ?? '');
        final isSelected = _selectedIds.contains(subjectId);
        final iconData = _getSubjectIcon(subjectName);
        final iconColor = _getSubjectColor(subjectName);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedIds.remove(subjectId);
              } else {
                _selectedIds.add(subjectId);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0FA37F)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x200FA37F),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x060F172A),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0FA37F)
                        : iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    iconData,
                    size: 24.r,
                    color: isSelected ? Colors.white : iconColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  subjectName,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF0FA37F)
                        : const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. قائمة مسارات البكالوريا (ثابتة)
  Widget _buildBaccalaureateTracksList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      physics: const BouncingScrollPhysics(),
      itemCount: _baccalaureateTracks.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final track = _baccalaureateTracks[index];
        final trackId = track['id'] as String;
        final trackName = track['name_ar'] as String;
        final qualifying = track['qualifying'] as String;
        final icon = track['icon'] as IconData;
        final color = track['color'] as Color;
        final isSelected = _selectedIds.contains(trackId);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedIds.remove(trackId);
              } else {
                _selectedIds.add(trackId);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(20) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? color : const Color(0xFFE2E8F0),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withAlpha(30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x040F172A),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, color: color, size: 20.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        trackName,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color:
                              isSelected ? color : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? color : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14.r,
                            )
                          : null,
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  qualifying,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
