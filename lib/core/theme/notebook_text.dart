import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notebook_colors.dart';

/// Cairo type helpers written in the notebook's voice.
abstract final class NotebookText {
  /// Big ink headings, like a title written with a marker.
  static TextStyle heading(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? NotebookColors.ink,
        height: 1.3,
      );

  /// Emphasised body copy.
  static TextStyle strong(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? NotebookColors.ink,
      );

  /// Regular body copy.
  static TextStyle body(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? NotebookColors.ink,
      );

  /// Pencil-secondary copy (notes, hints, meta).
  static TextStyle note(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? NotebookColors.pencil,
      );
}
