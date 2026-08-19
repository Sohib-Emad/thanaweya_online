import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_assets.dart';

 
/// Animated logo displayed at the center of the splash screen.
class SplashLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  const SplashLogo({
    super.key,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SizedBox(
          width: 140.r,
          height: 140.r,
          child: Image.asset(AppAssets.icon, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
