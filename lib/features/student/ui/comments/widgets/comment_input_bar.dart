import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// An input bar for typing and sending comments at the bottom of the screen.
class CommentInputBar extends StatelessWidget {
  /// Creates a [CommentInputBar].
  const CommentInputBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSend,
  });

  /// The text editing controller for the input field.
  final TextEditingController controller;

  /// The placeholder hint text.
  final String hint;

  /// Called when the send button is tapped.
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: NotebookColors.surfaceBright,
        border: Border(
          top: BorderSide(color: NotebookColors.ink.withAlpha(50)),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTextField()),
          SizedBox(width: 8.w),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      style: NotebookText.body(13.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: NotebookText.note(12.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: NotebookColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: onSend,
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: NotebookColors.green,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.send_rounded, color: Colors.white, size: 20.r),
      ),
    );
  }
}
