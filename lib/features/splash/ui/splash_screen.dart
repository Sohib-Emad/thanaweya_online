import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../shared/models/user_model.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  // Dual audio players to guarantee sound plays on EVERY letter without skipping
  AudioPlayer? _player1;
  AudioPlayer? _player2;
  bool _usePlayer1 = true;

  final String _line1Full = 'Thanaweya';
  final String _line2Full = 'Online';

  String _line1Displayed = '';
  String _line2Displayed = '';
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();

    // 1. Raw Logo Image Animation (Top Element)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    _logoController.forward();

    // 2. Start Typewriter for "Thanaweya Online" text (Slower 200ms per letter)
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _startTypewriter();
    });

    // 3. Auto navigate after full typewriter animation completes
    Future.delayed(const Duration(milliseconds: 4600), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _goToNextScreen();
    });
  }

  void _goToNextScreen() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null &&
        Supabase.instance.client.auth.currentSession != null) {
      final role = UserRole.values.asNameMap()[user.userMetadata?['role']] ??
          UserRole.student;
      Navigator.pushReplacementNamed(context, AppRouter.homeForRole(role));
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
    }
  }

  void _startTypewriter() {
    int totalSteps = _line1Full.length + _line2Full.length;
    int step = 0;

    // Slower pace: 200ms per character
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      step++;

      // Play audio sound on EVERY letter + light haptic tick
      _playTypewriterAudio();
      HapticFeedback.lightImpact();

      if (step <= _line1Full.length) {
        setState(() {
          _line1Displayed = _line1Full.substring(0, step);
        });
      } else if (step <= totalSteps) {
        int line2Index = step - _line1Full.length;
        setState(() {
          _line2Displayed = _line2Full.substring(0, line2Index);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _playTypewriterAudio() {
    runZonedGuarded(() async {
      try {
        if (_usePlayer1) {
          _player1 ??= AudioPlayer();
          await _player1?.setVolume(0.35);
          await _player1?.stop();
          await _player1?.play(
            AssetSource('sounds/pop.wav'),
            mode: PlayerMode.lowLatency,
          );
        } else {
          _player2 ??= AudioPlayer();
          await _player2?.setVolume(0.35);
          await _player2?.stop();
          await _player2?.play(
            AssetSource('sounds/pop.wav'),
            mode: PlayerMode.lowLatency,
          );
        }
        _usePlayer1 = !_usePlayer1;
      } catch (_) {
        // Safe catch for hot reload
      }
    }, (_, error) {});
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _logoController.dispose();
    try {
      _player1?.dispose();
      _player2?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // 1. TOP: Direct Raw Logo Image (No container / background box)
              ScaleTransition(
                scale: _logoScaleAnimation,
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: SizedBox(
                    width: 140.r,
                    height: 140.r,
                    child: Image.asset(
                      AppAssets.icon,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // 2. BOTTOM: Exact Logo Text (Typed character by character slowly)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Line 1: "Thanaweya"
                  SizedBox(
                    height: 42.h,
                    child: Text(
                      _line1Displayed,
                      style: GoogleFonts.outfit(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Line 2: "Online"
                  SizedBox(
                    height: 38.h,
                    child: Text(
                      _line2Displayed,
                      style: GoogleFonts.outfit(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.studentPrimary,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
