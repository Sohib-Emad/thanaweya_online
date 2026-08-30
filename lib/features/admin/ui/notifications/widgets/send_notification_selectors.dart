import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class SendNotificationSelectors extends StatelessWidget {
  final bool isSpecificUser;
  final String targetType;
  final String category;
  final ValueChanged<String> onSelectTargetType;
  final ValueChanged<String> onSelectCategory;

  const SendNotificationSelectors({
    super.key,
    required this.isSpecificUser,
    required this.targetType,
    required this.category,
    required this.onSelectTargetType,
    required this.onSelectCategory,
  });

  Widget _buildChip(String value, String label, bool isSelected, ValueChanged<String> onSelect, {Color selectedColor = AppColors.adminPrimary}) {
    return ChoiceChip(
      label: Text(label), selected: isSelected, onSelected: (_) => onSelect(value),
      selectedColor: selectedColor, backgroundColor: const Color(0xFFF1F5F9), showCheckmark: false,
      labelStyle: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r), side: BorderSide(color: isSelected ? selectedColor : Colors.transparent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSpecificUser) ...[
          Text('الجمهور المستهدف:', style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w, runSpacing: 8.h,
            children: [
              _buildChip('all', '📢 جميع المستخدمين', targetType == 'all', onSelectTargetType),
              _buildChip('students', '🎓 الطلاب فقط', targetType == 'students', onSelectTargetType),
              _buildChip('teachers', '👨‍🏫 المعلمين فقط', targetType == 'teachers', onSelectTargetType),
            ],
          ),
          SizedBox(height: 16.h),
        ],
        Text('نوع الإشعار:', style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w, runSpacing: 8.h,
          children: [
            _buildChip('admin_broadcast', 'إعلان عام', category == 'admin_broadcast', onSelectCategory, selectedColor: const Color(0xFF334155)),
            _buildChip('system', 'تنبيه نظام', category == 'system', onSelectCategory, selectedColor: const Color(0xFF334155)),
            _buildChip('offer', 'عرض خاص', category == 'offer', onSelectCategory, selectedColor: const Color(0xFF334155)),
            _buildChip('important', 'هام وعاجل', category == 'important', onSelectCategory, selectedColor: const Color(0xFF334155)),
          ],
        ),
      ],
    );
  }
}
