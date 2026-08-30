import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/app_system_config_repo.dart';
import '../../shared/models/user_model.dart';
import '../../teacher/data/repos/teacher_profile_repo.dart';
import 'widgets/widgets.dart';

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
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _startTypewriter();
    });
    Future.delayed(const Duration(milliseconds: 4600), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _goToNextScreen();
    });
  }

  Future<void> _goToNextScreen() async {
    final config = await AppSystemConfigRepo().fetchConfig();
    final user = Supabase.instance.client.auth.currentUser;
    final role = (user != null && Supabase.instance.client.auth.currentSession != null)
        ? (UserRole.values.asNameMap()[user.userMetadata?['role']] ?? UserRole.student)
        : null;

    // 1. If Maintenance Mode is active and user is not Super Admin -> Maintenance Screen
    if (config.isMaintenanceMode && role != UserRole.superAdmin) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRouter.maintenance,
        arguments: config.maintenanceMessage,
      );
      return;
    }

    // 2. If Force Update is active or version older than required and user is not Super Admin -> Force Update Screen
    final isEnforced = config.isUpdateEnforced(AppSystemConfigRepo.currentAppVersion);
    if (isEnforced && role != UserRole.superAdmin) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRouter.forceUpdate,
        arguments: config.updateMessage,
      );
      return;
    }

    // 3. Authenticated User Flow
    if (user != null && Supabase.instance.client.auth.currentSession != null) {
      // Verify user actually exists in the database
      Map<String, dynamic>? userRow;
      try {
        userRow = await Supabase.instance.client
            .from('users')
            .select('id, role')
            .eq('id', user.id)
            .maybeSingle();
      } catch (_) {}

      // Fallback: lookup by email and sync ID
      if (userRow == null && user.email != null) {
        try {
          userRow = await Supabase.instance.client
              .from('users')
              .select('id, role')
              .eq('email', user.email!)
              .maybeSingle();
          if (userRow != null && userRow['id'] != user.id) {
            final oldId = userRow['id'];
            try {
              await Supabase.instance.client.from('users').update({'id': user.id}).eq('id', oldId);
              await Supabase.instance.client.from('teachers').update({'id': user.id}).eq('id', oldId);
            } catch (_) {}
          }
        } catch (_) {}
      }

      // Auto-provision if missing completely
      if (userRow == null) {
        final metaRole = user.userMetadata?['role'] as String? ?? (role?.name ?? 'teacher');
        final metaName = (user.userMetadata?['full_name'] as String?) ?? (user.email?.split('@').first ?? 'معلم');
        try {
          await Supabase.instance.client.from('users').upsert({
            'id': user.id,
            'email': user.email ?? '',
            'full_name': metaName,
            'role': metaRole,
          }, onConflict: 'id');
          if (metaRole == 'teacher') {
            await Supabase.instance.client.from('teachers').upsert({
              'id': user.id,
              'approval_status': 'approved',
            }, onConflict: 'id');
          }
          userRow = {'id': user.id, 'role': metaRole};
        } catch (e) {
          debugPrint('[SplashScreen] Auto-provision error: $e');
        }
      }

      final resolvedRole = userRow != null && userRow['role'] != null
          ? UserRole.fromString(userRow['role'])
          : (role ?? UserRole.teacher);

      if (resolvedRole == UserRole.teacher) {
        final result = await TeacherProfileRepo().getApprovalStatus(user.id);
        if (!mounted) return;

        String status = 'approved';
        result.when(
          success: (s) => status = s,
          failure: (_, _) {},
        );

        if (status == 'banned') {
          Navigator.pushReplacementNamed(context, AppRouter.teacherBanned);
          return;
        }

        Navigator.pushReplacementNamed(
          context,
          status == 'approved' ? AppRouter.teacherHome : AppRouter.teacherPending,
        );
      } else {
        if (resolvedRole == UserRole.student) {
          try {
            await Supabase.instance.client.from('students').update({
              'app_version': AppSystemConfigRepo.currentAppVersion,
              'last_active_at': DateTime.now().toIso8601String(),
            }).eq('id', user.id);
          } catch (_) {}
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.homeForRole(resolvedRole));
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
    }
  }

  void _startTypewriter() {
    int totalSteps = _line1Full.length + _line2Full.length;
    int step = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) { timer.cancel(); return; }
      step++;
      _playTypewriterAudio();
      HapticFeedback.lightImpact();
      if (step <= _line1Full.length) {
        setState(() => _line1Displayed = _line1Full.substring(0, step));
      } else if (step <= totalSteps) {
        int line2Index = step - _line1Full.length;
        setState(() => _line2Displayed = _line2Full.substring(0, line2Index));
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
          await _player1?.play(AssetSource('sounds/pop.wav'), mode: PlayerMode.lowLatency);
        } else {
          _player2 ??= AudioPlayer();
          await _player2?.setVolume(0.35);
          await _player2?.stop();
          await _player2?.play(AssetSource('sounds/pop.wav'), mode: PlayerMode.lowLatency);
        }
        _usePlayer1 = !_usePlayer1;
      } catch (_) {}
    }, (_, error) {});
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _logoController.dispose();
    try { _player1?.dispose(); _player2?.dispose(); } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              SplashLogo(scaleAnimation: _logoScaleAnimation, fadeAnimation: _logoFadeAnimation),
              SizedBox(height: 32.h),
              SplashTypewriterText(line1: _line1Displayed, line2: _line2Displayed),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
