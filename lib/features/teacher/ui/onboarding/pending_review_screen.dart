import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/widgets.dart';

/// Screen that polls teacher approval status and transitions
/// between pending, rejected, and approved states.
class PendingReviewScreen extends StatefulWidget {
  const PendingReviewScreen({super.key});

  @override
  State<PendingReviewScreen> createState() => _PendingReviewScreenState();
}

class _PendingReviewScreenState extends State<PendingReviewScreen> {
  Timer? _pollTimer;
  Timer? _navigationTimer;
  bool _isApproved = false;
  bool _isRejected = false;
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      await _checkApprovalStatus();
    });
    _checkApprovalStatus();
  }

  Future<void> _checkApprovalStatus() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null || session == null) {
        _pollTimer?.cancel();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRouter.login, (route) => false);
        }
        return;
      }
      final data = await Supabase.instance.client
          .from('teachers')
          .select('approval_status, rejection_reason')
          .eq('id', userId)
          .maybeSingle();
      if (data == null || !mounted) return;

      final status = data['approval_status'] as String?;
      if (status == 'approved') {
        _pollTimer?.cancel();
        HapticFeedback.heavyImpact();
        setState(() => _isApproved = true);
        _navigationTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, AppRouter.teacherHome, (route) => false);
        });
      } else if (status == 'rejected') {
        _pollTimer?.cancel();
        setState(() {
          _isRejected = true;
          _rejectionReason = data['rejection_reason'] as String?;
        });
      }
    } on PostgrestException catch (e) {
      _pollTimer?.cancel();
      debugPrint('[PendingReview] PostgrestException: ${e.code} ${e.message}');
      if (e.code == '401' ||
          e.message.contains('PGRST301') ||
          e.message.contains('JWT')) {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRouter.login, (route) => false);
        }
      }
    } catch (e) {
      debugPrint('[PendingReview] poll error: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isApproved
                ? const ApprovedSuccessView()
                : _isRejected
                    ? RejectedReviewView(rejectionReason: _rejectionReason)
                    : PendingReviewView(
                        onHomePressed: () {
                          HapticFeedback.lightImpact();
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRouter.roleSelection,
                              (route) => false,
                            );
                          }
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
