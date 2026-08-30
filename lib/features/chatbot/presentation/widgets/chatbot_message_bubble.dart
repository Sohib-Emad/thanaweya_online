import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_colors.dart';
import '../../domain/entities/chatbot_message_entity.dart';

class ChatbotMessageBubble extends StatelessWidget {
  final ChatbotMessageEntity message;
  final ValueChanged<String> onFollowUpTap;
  final ValueChanged<String> onActionTap;

  const ChatbotMessageBubble({
    super.key,
    required this.message,
    required this.onFollowUpTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: NotebookColors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('🤖', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isUser ? NotebookColors.green : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: isUser ? Radius.circular(16.r) : Radius.circular(4.r),
                      bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(16.r),
                    ),
                    border: Border.all(
                      color: isUser
                          ? NotebookColors.green
                          : NotebookColors.rulerCard,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          height: 1.5,
                          color: isUser ? Colors.white : NotebookColors.ink,
                          fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),

                      // Direct Action Button (e.g. 'فتح الخزنة', 'تواصل عبر واتساب')
                      if (!isUser &&
                          message.actionRoute != null &&
                          message.actionLabel != null) ...[
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onActionTap(message.actionRoute!);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NotebookColors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              message.actionLabel!,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                SizedBox(width: 8.w),
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 18.r,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Follow-up question chips
          if (!isUser && message.followUpQuestions.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(right: 40.w),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: message.followUpQuestions.map((q) {
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onFollowUpTap(q);
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: NotebookColors.surfaceBright,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: NotebookColors.green.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            size: 13.r,
                            color: NotebookColors.green,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            q,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: NotebookColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
