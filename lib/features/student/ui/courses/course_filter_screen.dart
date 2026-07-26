import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseFilterScreen extends StatefulWidget {
  const CourseFilterScreen({super.key});

  @override
  State<CourseFilterScreen> createState() => _CourseFilterScreenState();
}

class _CourseFilterScreenState extends State<CourseFilterScreen> {
  // Selected options state
  final Set<String> _selectedSubCategories = {
    'تطوير الويب',
    'انيميشن ثلاثي الأبعاد',
  };
  final Set<String> _selectedLevels = {'مبتدئ', 'متوسط'};
  final Set<String> _selectedPrice = {'مدفوع'};
  final Set<String> _selectedFeatures = {};
  final Set<String> _selectedRating = {};
  final Set<String> _selectedDurations = {};

  final List<String> _subCategories = [
    'تصميم ثلاثي الأبعاد',
    'تطوير الويب',
    'انيميشن ثلاثي الأبعاد',
    'التصميم الجرافيكي',
    'تسويق وسيو',
    'الفنون والإنسانيات',
  ];

  final List<String> _levels = [
    'جميع المستويات',
    'مبتدئ',
    'متوسط',
    'متقدم وخبير',
  ];

  final List<String> _priceOptions = ['مدفوع', 'مجاني'];

  final List<String> _features = [
    'ترجمة مصاحبة الشرح',
    'اختبارات تفاعلية',
    'تمارين وتطبيقات عملية',
    'نماذج امتحانات تدريبية',
  ];

  final List<String> _ratings = [
    '4.5 فأعلى',
    '4.0 فأعلى',
    '3.5 فأعلى',
    '3.0 فأعلى',
  ];

  final List<String> _durations = [
    '0 - 2 ساعات',
    '3 - 6 ساعات',
    '7 - 16 ساعة',
    '17+ ساعة',
  ];

  void _clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedSubCategories.clear();
      _selectedLevels.clear();
      _selectedPrice.clear();
      _selectedFeatures.clear();
      _selectedRating.clear();
      _selectedDurations.clear();
    });
  }

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
            'تصفية النتائج (Filter)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _clearAll,
              child: Text(
                'إعادة ضبط',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SubCategories
                  _buildSectionTitle('التخصصات والمواد الفرعية:'),
                  SizedBox(height: 10.h),
                  ..._subCategories.map(
                    (item) => _buildCustomCheckboxTile(
                      label: item,
                      isSelected: _selectedSubCategories.contains(item),
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedSubCategories.add(item);
                          } else {
                            _selectedSubCategories.remove(item);
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 2. Levels
                  _buildSectionTitle('المستوى الدراسية:'),
                  SizedBox(height: 10.h),
                  ..._levels.map(
                    (item) => _buildCustomCheckboxTile(
                      label: item,
                      isSelected: _selectedLevels.contains(item),
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedLevels.add(item);
                          } else {
                            _selectedLevels.remove(item);
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 3. Price
                  _buildSectionTitle('السعر:'),
                  SizedBox(height: 10.h),
                  ..._priceOptions.map(
                    (item) => _buildCustomCheckboxTile(
                      label: item,
                      isSelected: _selectedPrice.contains(item),
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedPrice.add(item);
                          } else {
                            _selectedPrice.remove(item);
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 4. Features
                  _buildSectionTitle('المميزات:'),
                  SizedBox(height: 10.h),
                  ..._features.map(
                    (item) => _buildCustomCheckboxTile(
                      label: item,
                      isSelected: _selectedFeatures.contains(item),
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedFeatures.add(item);
                          } else {
                            _selectedFeatures.remove(item);
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 5. Rating
                  _buildSectionTitle('التقييم:'),
                  SizedBox(height: 10.h),
                  ..._ratings.map(
                    (item) => _buildCustomCheckboxTile(
                      label: item,
                      isSelected: _selectedRating.contains(item),
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedRating.add(item);
                          } else {
                            _selectedRating.remove(item);
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 6. Video Durations
                  _buildSectionTitle('مدة الفيديو:'),
                  SizedBox(height: 10.h),
                  ..._durations.map(
                    (item) => _buildCustomCheckboxTile(
                      label: item,
                      isSelected: _selectedDurations.contains(item),
                      onChanged: (val) {
                        setState(() {
                          if (val) {
                            _selectedDurations.add(item);
                          } else {
                            _selectedDurations.remove(item);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Floating Apply Button at bottom
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      elevation: 4,
                      shadowColor: const Color(0x330FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Text(
                          'تطبيق الفلترة (Apply)',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .arrow_back_rounded, // Arabic RTL direction back/forward arrow
                            color: const Color(0xFF0FA37F),
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 15.sp,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildCustomCheckboxTile({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!isSelected);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0FA37F) : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0FA37F)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
