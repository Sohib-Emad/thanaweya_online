import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingLottieData> _items = [
    _OnboardingLottieData(
      title: 'شروحات مبسطة وتفاعلية',
      description:
          'شرح كامل لجميع مواد الثانوية العامة بأسلوب إلكتروني مبسط يضمن لك التفوق.',
      lottieAsset: 'assets/json/1.json',
      color: const Color(0xFF0FA37F),
      scale: 1.2,
      height: 200.h,
    ),
    _OnboardingLottieData(
      title: 'امتحانات وتقييم فوري',
      description:
          'بنك أسئلة وتدريبات شاملة مع تصحيح آلي فوري وتقارير تحدد مستواك المستمر.',
      lottieAsset: 'assets/json/2.json',
      color: const Color(0xFF2563EB),
      scale: 1.15,
      height: 235.h,
    ),
    _OnboardingLottieData(
      title: 'أفضل المعلمين في مصر',
      description:
          'تواصل مباشر وحضور دروس مع نخبة من كبار الخبراء والمعلمين المعتمدين.',
      lottieAsset: 'assets/json/3.json',
      color: const Color(0xFF7C3AED),
      scale: 1.32,
      height: 245.h,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    HapticFeedback.lightImpact();
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, AppRouter.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _items[_currentPage];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Minimal Header (Logo + Skip Button)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppAssets.icon, width: 36.r, height: 36.r),
                        SizedBox(width: 8.w),
                        Text(
                          'Thanaweya Online',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'تخطي',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lottie Animation PageView Section
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Prominent Scaled Lottie Animation Container
                          SizedBox(
                            height: item.height,
                            width: double.infinity,
                            child: OverflowBox(
                              maxHeight: item.height * item.scale,
                              maxWidth: 360.w * item.scale,
                              child: Transform.scale(
                                scale: item.scale,
                                child: Lottie.asset(
                                  item.lottieAsset,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 28.h),

                          // Slide Title
                          Text(
                            item.title,
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 12.h),

                          // Slide Description
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              item.description,
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Control Section (Dots + Next Button)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: Column(
                  children: [
                    // Active Pill Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: _currentPage == index ? 28.w : 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? currentItem.color
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Primary Action Button
                    AppButton(
                      text: _currentPage == _items.length - 1
                          ? 'ابدأ الآن'
                          : 'التالي',
                      backgroundColor: currentItem.color,
                      icon: _currentPage == _items.length - 1
                          ? null
                          : Icons.arrow_forward_rounded,
                      onPressed: _onNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingLottieData {
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;
  final double scale;
  final double height;

  const _OnboardingLottieData({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
    required this.scale,
    required this.height,
  });
}
