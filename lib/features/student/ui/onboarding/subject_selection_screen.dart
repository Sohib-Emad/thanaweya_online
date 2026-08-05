import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
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

  void _goNext() {
    HapticFeedback.lightImpact();
    // تمرير الـ IDs المختارة للشاشة التالية
    for (final id in _selectedIds) {
      _cubit.selectSubject(id);
    }
    Navigator.pushNamed(context, AppRouter.studentTeachers);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NotebookColors.ground,
          appBar: NotebookTopBar(
            title: AppStrings.selectSubjects,
            subtitle: 'اختر المواد التي ستدرسها هذا العام',
          ),
          body: SafeArea(
            top: false,
            child: NotebookPaper(
              child: Column(
                children: [
                  SizedBox(height: 12.h),

                  // System Segmented Switcher (عامة قديم vs نظام البكالوريا IB)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: NotebookSegmentControl(
                      options: ['عامة', 'نظام البكالوريا'],
                      index: _selectedSystemIndex,
                      onChanged: (i) {
                        if (i != _selectedSystemIndex) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedSystemIndex = i;
                            _selectedIds.clear();
                          });
                        }
                      },
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
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: NotebookColors.green,
                                  ),
                                );
                              }
                              if (state.status ==
                                  StudentOnboardingStatus.error) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.w),
                                        child: NotebookEmptyNote(
                                          message: state.errorMessage ??
                                              'حدث خطأ أثناء تحميل المواد',
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      NotebookPrimaryButton(
                                        label: 'إعادة المحاولة',
                                        onPressed: () => _cubit.loadSubjects(),
                                        expanded: false,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final subjects = state.subjects;
                              if (subjects.isEmpty) {
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  child: NotebookEmptyNote(
                                    message: 'لا توجد مواد متاحة',
                                  ),
                                );
                              }
                              return _buildGeneralSubjectsList(subjects);
                            },
                          )
                        : _buildBaccalaureateTracksList(),
                  ),

                  // Bottom Action Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
                    child: NotebookPrimaryButton(
                      label: '${AppStrings.next} (${_selectedIds.length})',
                      onPressed: _selectedIds.isEmpty ? null : _goNext,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 1. قائمة المواد العامة من Supabase (صفوف محدّدة كصفحات الدفتر)
  Widget _buildGeneralSubjectsList(List<Map<String, dynamic>> subjects) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final subjectId = subject['id'] as String;
        final subjectName = (subject['name_ar'] as String? ?? '');
        final isSelected = _selectedIds.contains(subjectId);
        return NotebookCard(
          ruled: true,
          ruledStartY: 30,
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
          child: _buildSelectionRow(
            label: subjectName,
            isSelected: isSelected,
          ),
        );
      },
    );
  }

  // 2. قائمة مسارات البكالوريا (ثابتة)
  Widget _buildBaccalaureateTracksList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: _baccalaureateTracks.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final track = _baccalaureateTracks[index];
        final trackId = track['id'] as String;
        final trackName = track['name_ar'] as String;
        final qualifying = track['qualifying'] as String;
        final icon = track['icon'] as IconData;
        final color = track['color'] as Color;
        final isSelected = _selectedIds.contains(trackId);

        return NotebookCard(
          ruled: true,
          ruledStartY: 56,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: color.withAlpha(28),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: color, size: 18.r),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      trackName,
                      style: NotebookText.strong(14.sp),
                    ),
                  ),
                  _buildCheckbox(isSelected),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                qualifying,
                style: NotebookText.note(11.sp).copyWith(height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  // صف تحديد على ورقة الدفتر: مربع اختيار + اسم + دبوس عند الاختيار
  Widget _buildSelectionRow({
    required String label,
    required bool isSelected,
  }) {
    return Row(
      children: [
        _buildCheckbox(isSelected),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            label,
            style: NotebookText.body(13.5.sp, color: isSelected
                ? NotebookColors.ink
                : NotebookColors.pencil),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.push_pin_rounded,
            color: NotebookColors.marginRed.withAlpha(160),
            size: 15.r,
          ),
      ],
    );
  }

  Widget _buildCheckbox(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24.r,
      height: 24.r,
      decoration: BoxDecoration(
        color: isSelected
            ? NotebookColors.green
            : NotebookColors.surfaceBright,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isSelected
              ? NotebookColors.green
              : NotebookColors.ink.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
          : null,
    );
  }
}
