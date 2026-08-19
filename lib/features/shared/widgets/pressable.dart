import 'package:flutter/material.dart';

/// Wraps a child with press-and-scale gesture handling.
///
/// Used by [AppButton] to provide tap feedback animation.
class Pressable extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback? onPressed;
  final Widget child;

  const Pressable({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onPressed != null ? (_) => controller.forward() : null,
      onTapUp: onPressed != null
          ? (_) {
              controller.reverse();
              onPressed?.call();
            }
          : null,
      onTapCancel: onPressed != null ? () => controller.reverse() : null,
      child: child,
    );
  }
}
