import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'desk_colors.dart';

/// Cairo type helpers written in desk ink.
abstract final class DeskText {
  static TextStyle heading(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? DeskColors.ink,
        height: 1.3,
      );

  static TextStyle strong(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? DeskColors.ink,
      );

  static TextStyle body(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? DeskColors.ink,
      );

  static TextStyle note(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? DeskColors.muted,
      );
}
