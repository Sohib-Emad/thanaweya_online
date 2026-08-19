import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/onboarding/widgets/selection_widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Static track data for the baccalaureate system.
const List<Map<String, dynamic>> baccalaureateTracks = [
  {
    'id': 'track_med',
    'icon': Icons.medical_services_rounded,
    'color': Color(0xFF10B981),
  },
  {
    'id': 'track_eng',
    'icon': Icons.computer_rounded,
    'color': Color(0xFF2563EB),
  },
  {
    'id': 'track_biz',
    'icon': Icons.business_center_rounded,
    'color': Color(0xFFD97706),
  },
  {
    'id': 'track_arts',
    'icon': Icons.palette_rounded,
    'color': Color(0xFF9333EA),
  },
];

/// Returns the localized track name for the given [id].
String trackName(AppLocalizations l10n, String id) {
  switch (id) {
    case 'track_med':
      return l10n.trackMedicine;
    case 'track_eng':
      return l10n.trackEngineering;
    case 'track_biz':
      return l10n.trackBusiness;
    case 'track_arts':
      return l10n.trackArts;
    default:
      return '';
  }
}

/// Returns the localized track description for the given [id].
String trackDescription(AppLocalizations l10n, String id) {
  switch (id) {
    case 'track_med':
      return l10n.trackMedicineDesc;
    case 'track_eng':
      return l10n.trackEngineeringDesc;
    case 'track_biz':
      return l10n.trackBusinessDesc;
    case 'track_arts':
      return l10n.trackArtsDesc;
    default:
      return '';
  }
}

/// Scrollable list of baccalaureate track cards with multi-select.
class BaccalaureateTracksList extends StatelessWidget {
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const BaccalaureateTracksList({
    super.key,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: baccalaureateTracks.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final track = baccalaureateTracks[index];
        final id = track['id'] as String;
        final icon = track['icon'] as IconData;
        final color = track['color'] as Color;
        final isSelected = selectedIds.contains(id);

        return NotebookCard(
          ruled: true,
          ruledStartY: 56,
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(id);
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
                      trackName(l10n, id),
                      style: NotebookText.strong(14.sp),
                    ),
                  ),
                  NotebookCheckbox(isSelected: isSelected),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                trackDescription(l10n, id),
                style: NotebookText.note(11.sp).copyWith(height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }
}
