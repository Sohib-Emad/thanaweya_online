import 'package:flutter/material.dart';

/// Data model for a single onboarding page.
class OnboardingLottieData {
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;
  final double scale;
  final double height;

  const OnboardingLottieData({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
    required this.scale,
    required this.height,
  });
}
