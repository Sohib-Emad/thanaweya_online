// ────────────────────────────────────────────────────────────
// CHALKBOARD THEME — معلم · السبورة الطباشير (the chalkboard)
// The teacher surface is the classroom board: a LIGHT sage-white
// board ground, dark green-chalk ink, mint/red/yellow/blue colored
// chalk accents, and rubber stamps (معتمد / مسودة) instead of
// notebook margins. It stays the deliberate counterpart of the
// student's cream ruled دفتر — same school, different room — but in
// a bright board style rather than a dark one.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens of the سبورة (chalkboard) visual world.
abstract final class ChalkboardColors {
  static const Color ground = Color(0xFFF3F6F2); // light sage-white board
  static const Color groundDeep = Color(0xFFC4D0C8); // board edge/shadow
  static const Color surface = Color(0xFFFFFFFF); // chalked card fill
  static const Color surfaceBright = Color(0xFFE9F0EB); // hover/active fill
  static const Color ink = Color(0xFF1F332B); // dark green-chalk ink
  static const Color chalkSoft = Color(0xFF5F7A6D); // muted sage chalk
  static const Color chalkFaint = Color(0xFF9AAFA4); // dim chalk
  static const Color accent = Color(0xFF0FA37F); // mint chalk (brand pop)
  static const Color accentDeep = Color(0xFF0B7B60);
  static const Color chalkRed = Color(0xFFD95448);
  static const Color chalkYellow = Color(0xFFDFAE2E);
  static const Color chalkBlue = Color(0xFF3F7FBF);
  static const Color line = Color(0x1F1F332B); // faint chalk ruling
  static const Color onAccent = Colors.white; // ink on mint chalk
}

/// Cairo type helpers written in chalk.
abstract final class ChalkboardText {
  /// Big chalk headings, like a title written on the board.
  static TextStyle heading(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? ChalkboardColors.ink,
        height: 1.3,
      );

  /// Emphasised body copy.
  static TextStyle strong(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? ChalkboardColors.ink,
      );

  /// Regular body copy.
  static TextStyle body(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? ChalkboardColors.ink,
      );

  /// Chalk-secondary copy (hints, notes, meta).
  static TextStyle note(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? ChalkboardColors.chalkSoft,
      );
}

/// Paints faint horizontal chalk lines + a chalk dust wash behind a page.
class ChalkboardSurfacePainter extends CustomPainter {
  const ChalkboardSurfacePainter({
    this.lineGap = 44,
    this.lineColor = ChalkboardColors.line,
  });

  final double lineGap;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double y = lineGap; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(ChalkboardSurfacePainter oldDelegate) =>
      oldDelegate.lineGap != lineGap || oldDelegate.lineColor != lineColor;
}

/// Paints a rounded dashed border, like a frame drawn with chalk.
class ChalkBorderPainter extends CustomPainter {
  const ChalkBorderPainter({
    this.color = ChalkboardColors.ink,
    this.strokeWidth = 1.4,
    this.radius = 14,
    this.dashLength = 6,
    this.gapLength = 5,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final drawTo = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, drawTo),
          paint,
        );
        distance = drawTo + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(ChalkBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}

/// Wraps a child with the chalkboard ground + faint horizontal chalk lines.
class ChalkboardSurface extends StatelessWidget {
  const ChalkboardSurface({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const ChalkboardSurfacePainter(),
      child: child,
    );
  }
}

/// A chalk section heading: a colored chalk bar + title + optional action.
class ChalkSectionHeader extends StatelessWidget {
  const ChalkSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.accent = ChalkboardColors.accent,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 5.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(title, style: ChalkboardText.heading(16.sp)),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: accent,
              ),
              child: Row(
                children: [
                  Text(
                    actionLabel ?? 'الكل',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded, color: accent, size: 16.r),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A selectable chalk chip (selected fills with mint chalk).
class ChalkChip extends StatelessWidget {
  const ChalkChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent = ChalkboardColors.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected
              ? accent
              : ChalkboardColors.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? accent : ChalkboardColors.ink.withAlpha(60),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              color: selected ? ChalkboardColors.onAccent : ChalkboardColors.chalkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// A colored chalk status dot + label (نشط، منشور، مسودة...).
class ChalkStatusChip extends StatelessWidget {
  const ChalkStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withAlpha(110), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13.r, color: color),
            SizedBox(width: 4.w),
          ] else ...[
            Container(
              width: 7.r,
              height: 7.r,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 5.w),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A rubber chalk stamp (معتمد، مسودة، معلق).
class ChalkStamp extends StatelessWidget {
  const ChalkStamp({
    super.key,
    required this.label,
    this.color = ChalkboardColors.accent,
    this.angle = -0.05,
  });

  final String label;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.6),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

/// A chalk-framed card: board fill, dashed chalk border, optional accent
/// top edge (like a strip of colored chalk under the frame).
class ChalkCard extends StatelessWidget {
  const ChalkCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 16,
    this.accent,
    this.accentLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? accent;
  final String? accentLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: ChalkboardColors.surface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: ChalkboardColors.groundDeep.withAlpha(120),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ChalkBorderPainter(
                color: ChalkboardColors.ink.withAlpha(64),
                radius: borderRadius,
              ),
            ),
          ),
          if (accent != null)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius.r),
                  ),
                ),
              ),
            ),
          if (accentLabel != null)
            Positioned(
              top: 10.h,
              left: 12.w,
              child: ChalkStamp(label: accentLabel!, color: accent!),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

/// A calm chalk empty-state note.
class ChalkEmptyNote extends StatelessWidget {
  const ChalkEmptyNote({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.auto_stories_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? subMessage;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: ChalkboardColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ChalkboardColors.ink.withAlpha(50)),
      ),
      child: Column(
        children: [
          Container(
            width: 54.r,
            height: 54.r,
            decoration: BoxDecoration(
              color: ChalkboardColors.groundDeep.withAlpha(80),
              shape: BoxShape.circle,
              border: Border.all(color: ChalkboardColors.ink.withAlpha(40)),
            ),
            child: Icon(
              icon,
              color: ChalkboardColors.chalkSoft,
              size: 26.r,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: ChalkboardText.body(13.sp),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            SizedBox(height: 4.h),
            Text(
              subMessage!,
              style: ChalkboardText.note(11.sp),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 14.h),
            ChalkPrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
              expanded: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// The chalkboard top bar: dark board strip, chalk title, colored-chalk
/// back tab and actions.
class ChalkTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ChalkTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.automaticallyImplyBack = true,
    this.onBack,
    this.accent = ChalkboardColors.accent,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool automaticallyImplyBack;
  final VoidCallback? onBack;
  final Color accent;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      height: preferredSize.height + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      color: ChalkboardColors.ground,
      child: Row(
        children: [
          SizedBox(width: 12.w),
          if (automaticallyImplyBack && canPop)
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: ChalkboardColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withAlpha(160),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: accent,
                  size: 20.r,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ChalkboardText.heading(17.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: ChalkboardText.note(11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          ...?actions,
          SizedBox(width: 12.w),
        ],
      ),
    );
  }
}

/// A chalk search line: search glyph + invisible field on a chalk underline.
class ChalkSearchField extends StatelessWidget {
  const ChalkSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: ChalkboardColors.chalkSoft,
                size: 20.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: ChalkboardText.body(13.sp),
                  cursorColor: ChalkboardColors.accent,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: ChalkboardText.note(12.sp)
                        .copyWith(color: ChalkboardColors.chalkFaint),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            height: 1.4,
            color: ChalkboardColors.ink.withAlpha(90),
          ),
        ],
      ),
    );
  }
}

/// A chalk segment switcher (two or more options).
class ChalkSegmentedControl extends StatelessWidget {
  const ChalkSegmentedControl({
    super.key,
    required this.options,
    required this.index,
    required this.onChanged,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: ChalkboardColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ChalkboardColors.ink.withAlpha(50)),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: selected
                      ? ChalkboardColors.accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    options[i],
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected
                          ? ChalkboardColors.onAccent
                          : ChalkboardColors.chalkSoft,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A chalk-underline input field with a label.
class ChalkInputField extends StatelessWidget {
  const ChalkInputField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ChalkboardText.strong(12.sp)),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: maxLines > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: ChalkboardColors.chalkSoft, size: 18.r),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: TextFormField(
                controller: controller,
                style: ChalkboardText.body(13.sp),
                cursorColor: ChalkboardColors.accent,
                obscureText: obscureText,
                keyboardType: keyboardType,
                maxLines: maxLines,
                readOnly: readOnly,
                onChanged: onChanged,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: ChalkboardText.note(12.sp)
                      .copyWith(color: ChalkboardColors.chalkFaint),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 1.4,
          color: ChalkboardColors.ink.withAlpha(90),
        ),
      ],
    );
  }
}

/// A primary mint-chalk action button.
class ChalkPrimaryButton extends StatelessWidget {
  const ChalkPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.color = ChalkboardColors.accent,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: ChalkboardColors.onAccent,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: loading
          ? SizedBox(
              width: 20.r,
              height: 20.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: ChalkboardColors.onAccent,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18.r),
                  SizedBox(width: 8.w),
                ],
                Text(label, style: ChalkboardText.strong(13.sp)),
              ],
            ),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// A chalk-outlined secondary button.
class ChalkOutlineButton extends StatelessWidget {
  const ChalkOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.color = ChalkboardColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(120), width: 1.4),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.r),
            SizedBox(width: 8.w),
          ],
          Text(label, style: ChalkboardText.strong(13.sp, color: color)),
        ],
      ),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// A chalk-ringed avatar showing an initial.
class ChalkAvatar extends StatelessWidget {
  const ChalkAvatar({
    super.key,
    required this.initial,
    this.radius = 24,
    this.color = ChalkboardColors.accent,
  });

  final String initial;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final name = initial.trim();
    final letter = name.isEmpty ? 'م' : name[0];
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color.withAlpha(34),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(150), width: 1.6),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.cairo(
            fontSize: radius * 0.9,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}
