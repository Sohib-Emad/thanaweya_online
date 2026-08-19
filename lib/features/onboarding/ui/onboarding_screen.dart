import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/router/app_router.dart';
import '../../shared/widgets/app_button.dart';
import 'widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingLottieData> _items = [
    const OnboardingLottieData(
      title: 'شروحات مبسطة وتفاعلية',
      description: 'شرح كامل لجميع مواد الثانوية العامة بأسلوب إلكتروني مبسط يضمن لك التفوق.',
      lottieAsset: 'assets/json/1.json',
      color: Color(0xFF0FA37F),
      scale: 1.2,
      height: 200,
    ),
    const OnboardingLottieData(
      title: 'امتحانات وتقييم فوري',
      description: 'بنك أسئلة وتدريبات شاملة مع تصحيح آلي فوري وتقارير تحدد مستواك المستمر.',
      lottieAsset: 'assets/json/2.json',
      color: Color(0xFF2563EB),
      scale: 1.15,
      height: 235,
    ),
    const OnboardingLottieData(
      title: 'أفضل المعلمين في مصر',
      description: 'تواصل مباشر وحضور دروس مع نخبة من كبار الخبراء والمعلمين المعتمدين.',
      lottieAsset: 'assets/json/3.json',
      color: Color(0xFF7C3AED),
      scale: 1.32,
      height: 245,
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
              OnboardingAppBar(onSkip: _finishOnboarding),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _items.length,
                  itemBuilder: (context, index) => OnboardingPageViewItem(item: _items[index]),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: Column(
                  children: [
                    OnboardingDotIndicator(
                      itemCount: _items.length,
                      currentPage: _currentPage,
                      activeColor: currentItem.color,
                    ),
                    SizedBox(height: 28.h),
                    AppButton(
                      text: _currentPage == _items.length - 1 ? 'ابدأ الآن' : 'التالي',
                      backgroundColor: currentItem.color,
                      icon: _currentPage == _items.length - 1 ? null : Icons.arrow_forward_rounded,
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
