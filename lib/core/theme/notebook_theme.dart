import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';

/// Tokens of the دفتر (ruled school notebook) visual world.
///
/// The student surface is an Egyptian school exercise book: warm paper
/// ground, faint blue ruling, a classic red margin, pen-ink text, pencil
/// secondary copy, and the brand mint used as highlighter ink.
abstract final class NotebookColors {
  static const Color ground = Color(0xFFF8F4EA); // paper page
  static const Color surface = Color(0xFFFDFBF3); // paper card
  static const Color surfaceBright = Color(0xFFFFFDF5);
  static const Color ink = Color(0xFF1B2530); // pen ink
  static const Color pencil = Color(0xFF7C828C); // pencil secondary
  static const Color marginRed = Color(0xFFE03E3E); // classic red margin
  static const Color ruler = Color(0x2E5C7A99); // page ruling
  static const Color rulerCard = Color(0x175C7A99); // card ruling
  static const Color highlighter = Color(0xFFFFF2B8); // yellow highlighter

  /// Brand mint used as highlighter ink.
  static Color get green => AppColors.studentPrimary;
  static const Color onGreen = Colors.white;
}

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

/// Paints the ruled paper + red margin behind a whole notebook page.
class NotebookPaperPainter extends CustomPainter {
  const NotebookPaperPainter({
    this.lineGap = 30,
    this.marginWidth = 22,
    this.lineColor = NotebookColors.ruler,
    this.marginColor = NotebookColors.marginRed,
  });

  final double lineGap;
  final double marginWidth;
  final Color lineColor;
  final Color marginColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double y = lineGap; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final marginX = size.width - marginWidth;
    canvas.drawRect(
      Rect.fromLTWH(marginX, 0, marginWidth, size.height),
      Paint()..color = marginColor.withAlpha(14),
    );
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      Paint()
        ..color = marginColor
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(NotebookPaperPainter oldDelegate) =>
      oldDelegate.lineGap != lineGap ||
      oldDelegate.marginWidth != marginWidth ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.marginColor != marginColor;
}

/// Paints the faint horizontal ruling inside a card.
class RuledLinesPainter extends CustomPainter {
  const RuledLinesPainter({
    required this.lineGap,
    this.startY = 0,
    this.color = NotebookColors.rulerCard,
  });

  final double lineGap;
  final double startY;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = startY; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(RuledLinesPainter oldDelegate) =>
      oldDelegate.lineGap != lineGap ||
      oldDelegate.startY != startY ||
      oldDelegate.color != color;
}

/// Wraps a child with the notebook's ruled-paper background + red margin.
///
/// Drop it inside a scroll view (or a fixed area) and the painter covers the
/// child's own bounds, so the lines scroll like real paper.
class NotebookPaper extends StatelessWidget {
  const NotebookPaper({
    super.key,
    required this.child,
    this.lineGap = 30,
    this.marginWidth = 22,
  });

  final Widget child;
  final double lineGap;
  final double marginWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NotebookPaperPainter(
        lineGap: lineGap,
        marginWidth: marginWidth,
      ),
      child: child,
    );
  }
}

/// A notebook section heading: red margin tab + title + optional clear action.
class NotebookSectionHeader extends StatelessWidget {
  const NotebookSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Container(
            width: 5.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: NotebookColors.marginRed,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(title, style: NotebookText.heading(16.sp)),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Text(
                    actionLabel ?? 'الكل',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: NotebookColors.green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: NotebookColors.green,
                    size: 16.r,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A subject margin tab (selected shows as an inked index tab).
class NotebookMarginTab extends StatelessWidget {
  const NotebookMarginTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? NotebookColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: selected
                ? NotebookColors.marginRed.withAlpha(180)
                : NotebookColors.ink.withAlpha(50),
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: NotebookColors.ink.withAlpha(12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              color: selected ? NotebookColors.ink : NotebookColors.pencil,
            ),
          ),
        ),
      ),
    );
  }
}

/// A highlighter filter chip (selected fills with brand mint).
class NotebookChip extends StatelessWidget {
  const NotebookChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: selected
              ? NotebookColors.green
              : NotebookColors.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? NotebookColors.green
                : NotebookColors.ink.withAlpha(40),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: selected ? NotebookColors.onGreen : NotebookColors.pencil,
            ),
          ),
        ),
      ),
    );
  }
}

/// A yellow-highlighted study note (for filter banners, tips, alerts).
class NotebookHighlightNote extends StatelessWidget {
  const NotebookHighlightNote({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(24, 8, 24, 0),
  });

  final Widget child;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        color: NotebookColors.highlighter,
        child: child,
      ),
    );
  }
}

/// A red rotated stamp badge (خصم, مميز, جديد).
class NotebookStamp extends StatelessWidget {
  const NotebookStamp({
    super.key,
    required this.label,
    this.angle = -0.06,
    this.color = NotebookColors.marginRed,
  });

  final String label;
  final double angle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// A paper card: faint border, subtle shadow, optional ruled lines and a red
/// margin tab at the top-start edge.
class NotebookCard extends StatelessWidget {
  const NotebookCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.ruled = false,
    this.ruledStartY = 24,
    this.marginTab = false,
    this.borderRadius = 8,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool ruled;
  final double ruledStartY;
  final bool marginTab;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(38)),
        boxShadow: [
          BoxShadow(
            color: NotebookColors.ink.withAlpha(14),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (ruled)
            Positioned.fill(
              child: CustomPaint(
                painter: RuledLinesPainter(
                  lineGap: 28,
                  startY: ruledStartY.h,
                ),
              ),
            ),
          if (marginTab)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 16.w,
                height: 4.h,
                decoration: const BoxDecoration(
                  color: NotebookColors.marginRed,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                  ),
                ),
              ),
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

/// A calm empty-state note written on a notebook page.
class NotebookEmptyNote extends StatelessWidget {
  const NotebookEmptyNote({
    super.key,
    required this.message,
    this.icon = Icons.edit_note_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: NotebookColors.pencil, size: 30.r),
          SizedBox(height: 8.h),
          Text(
            message,
            style: NotebookText.note(12.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// The notebook's top bar: paper strip with a red-margin back tab and an
/// inked page title.
class NotebookTopBar extends StatelessWidget implements PreferredSizeWidget {
  const NotebookTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.automaticallyImplyBack = true,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool automaticallyImplyBack;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      height: preferredSize.height + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      color: NotebookColors.surface,
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
                  color: NotebookColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NotebookColors.marginRed.withAlpha(120),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: NotebookColors.marginRed,
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
                  style: NotebookText.heading(17.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: NotebookText.note(11.sp),
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

/// A ruled search line: pencil icon, invisible-bordered field, and an
/// optional red filter button, all resting on a single ruled underline.
class NotebookSearchField extends StatelessWidget {
  const NotebookSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onFilter,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onFilter;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: NotebookColors.pencil,
                size: 20.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: NotebookText.body(13.sp),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: NotebookText.note(12.sp)
                        .copyWith(color: NotebookColors.pencil.withAlpha(180)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (onFilter != null)
                GestureDetector(
                  onTap: onFilter,
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: NotebookColors.surfaceBright,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: NotebookColors.marginRed.withAlpha(140),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: NotebookColors.marginRed,
                      size: 18.r,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            height: 1.4,
            color: NotebookColors.ink.withAlpha(70),
          ),
        ],
      ),
    );
  }
}

/// A two-state paper segment switcher (e.g. completed / ongoing courses).
/// The selected option fills with mint highlighter ink.
class NotebookSegmentControl extends StatelessWidget {
  const NotebookSegmentControl({
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
        color: NotebookColors.surfaceBright,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(40)),
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
                      ? NotebookColors.green
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
                          ? NotebookColors.onGreen
                          : NotebookColors.pencil,
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

/// A primary green action, written as a filled highlighter button.
class NotebookPrimaryButton extends StatelessWidget {
  const NotebookPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: NotebookColors.green,
        foregroundColor: NotebookColors.onGreen,
        elevation: 0,
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
          Text(label, style: NotebookText.strong(13.sp, color: Colors.white)),
        ],
      ),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// A round paper avatar that shows the teacher's photo when available
/// (via [CachedNetworkImage]) and falls back to the name initial.
class NotebookTeacherAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;

  const NotebookTeacherAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = avatarUrl?.isNotEmpty == true;
    final initial = name.trim().isNotEmpty ? name.trim()[0] : 'م';

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: NotebookColors.green.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(
          color: NotebookColors.green.withAlpha(90),
          width: 1.4,
        ),
      ),
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: avatarUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) => _initial(initial),
              errorWidget: (_, _, _) => _initial(initial),
            )
          : _initial(initial),
    );
  }

  Widget _initial(String initial) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.cairo(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          color: NotebookColors.ink,
        ),
      ),
    );
  }
}
