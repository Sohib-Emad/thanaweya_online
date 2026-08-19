import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Returns the Arabic label for a given question type.
String typeLabel(String type) {
  switch (type) {
    case 'mcq':
      return 'اختيار من متعدد';
    case 'tf':
    case 'true_false':
      return 'صح أو خطأ';
    case 'essay':
      return 'سؤال مقالي';
    default:
      return type;
  }
}

/// Returns the accent color for a given question type.
Color typeColor(String type) {
  switch (type) {
    case 'mcq':
      return DeskColors.primary;
    case 'tf':
    case 'true_false':
      return DeskColors.info;
    case 'essay':
      return DeskColors.accent;
    default:
      return DeskColors.primary;
  }
}
