import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

class StudentNotificationSettingsScreen extends StatefulWidget {
  const StudentNotificationSettingsScreen({super.key});

  @override
  State<StudentNotificationSettingsScreen> createState() =>
      _StudentNotificationSettingsScreenState();
}

class _StudentNotificationSettingsScreenState
    extends State<StudentNotificationSettingsScreen> {
  final Map<String, bool> _settings = {
    'special_offers': true,
    'sounds': true,
    'vibration': false,
    'general': true,
    'promotions': false,
    'payment': true,
    'app_updates': true,
    'new_services': false,
    'tips': false,
  };

  String _label(AppLocalizations l10n, String key) {
    switch (key) {
      case 'special_offers':
        return l10n.notifSpecialOffers;
      case 'sounds':
        return l10n.notifSounds;
      case 'vibration':
        return l10n.notifVibration;
      case 'general':
        return l10n.notifGeneral;
      case 'promotions':
        return l10n.notifPromotions;
      case 'payment':
        return l10n.notifPayment;
      case 'app_updates':
        return l10n.notifAppUpdates;
      case 'new_services':
        return l10n.notifNewServices;
      case 'tips':
        return l10n.notifTips;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.notificationsTitle,
        subtitle: l10n.notificationsSubtitle,
      ),
        body: NotebookPaper(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            children: [
              NotebookCard(
                ruled: true,
                ruledStartY: 24,
                borderRadius: 12,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Column(
                  children: _settings.keys.map((key) {
                    final isVal = _settings[key]!;
                    return SwitchListTile(
                      value: isVal,
                      activeTrackColor: NotebookColors.green,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      title: Text(
                        _label(l10n, key),
                        style: NotebookText.body(13.sp),
                      ),
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _settings[key] = val);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
