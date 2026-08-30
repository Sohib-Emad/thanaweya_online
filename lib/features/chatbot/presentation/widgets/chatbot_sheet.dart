import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_colors.dart';
import 'package:thanaweya_online/core/theme/notebook_text.dart';
import 'package:thanaweya_online/features/wallet/presentation/pages/mobile_wallet_page.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import 'chatbot_message_bubble.dart';
import 'chatbot_typing_indicator.dart';

class ChatbotSheet extends StatefulWidget {
  const ChatbotSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider(
        create: (_) => ChatbotCubit(),
        child: const ChatbotSheet(),
      ),
    );
  }

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<ChatbotSheet> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleActionRoute(BuildContext context, String route) async {
    Navigator.of(context).pop(); // إغلاق شيت الشات بوت أولاً

    switch (route) {
      case 'wallet':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MobileWalletPage()),
        );
        break;

      case 'courses':
        try {
          Navigator.of(context).pushNamed(AppRouter.studentMyCourses);
        } catch (_) {}
        break;

      case 'support':
        const phone = '201096462825';
        final msg = Uri.encodeComponent('السلام عليكم، أحتاج مساعدة في منصة ثانوية أونلاين');
        final url = Uri.parse('https://wa.me/$phone?text=$msg');
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('[ChatbotSheet] Failed to launch WhatsApp: $e');
        }
        break;
    }
  }

  void _sendCustomQuestion(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<ChatbotCubit>().askQuestion(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: NotebookColors.ground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle & Top Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border(
                bottom: BorderSide(color: NotebookColors.rulerCard),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    // Bot Avatar with Online dot
                    Stack(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF334155)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('🤖', style: TextStyle(fontSize: 20.sp)),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 11.r,
                            height: 11.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المساعد الذكي للطلاب',
                            style: NotebookText.strong(14.sp, color: NotebookColors.ink),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Text(
                                'متصل الآن (إجابة فورية 24/7)',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: NotebookColors.pencil,
                        size: 20.r,
                      ),
                      tooltip: 'إعادة ضبط المحادثة',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.read<ChatbotCubit>().resetChat();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: NotebookColors.ink,
                        size: 22.r,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category Filter Chips
          BlocBuilder<ChatbotCubit, ChatbotState>(
            builder: (context, state) {
              if (state.categories.isEmpty) return const SizedBox.shrink();

              return Container(
                height: 46.h,
                color: Colors.white,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, idx) {
                    final cat = state.categories[idx];
                    final isSelected = cat == state.selectedCategory;

                    return ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : NotebookColors.ink,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: NotebookColors.green,
                      backgroundColor: NotebookColors.surface,
                      side: BorderSide(
                        color: isSelected ? NotebookColors.green : NotebookColors.rulerCard,
                      ),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        context.read<ChatbotCubit>().selectCategory(cat);
                      },
                    );
                  },
                ),
              );
            },
          ),

          // Suggested Questions for Selected Category
          BlocBuilder<ChatbotCubit, ChatbotState>(
            builder: (context, state) {
              if (state.categoryQuestions.isEmpty) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: NotebookColors.surfaceBright,
                  border: Border(
                    bottom: BorderSide(color: NotebookColors.rulerCard),
                  ),
                ),
                child: SizedBox(
                  height: 32.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categoryQuestions.length,
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
                    itemBuilder: (context, idx) {
                      final item = state.categoryQuestions[idx];
                      return ActionChip(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        label: Text(
                          item.question,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: NotebookColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: NotebookColors.rulerCard),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.read<ChatbotCubit>().askQuestion(item.question);
                          _scrollToBottom();
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Message Bubbles List
          Expanded(
            child: BlocConsumer<ChatbotCubit, ChatbotState>(
              listener: (context, state) {
                _scrollToBottom();
              },
              builder: (context, state) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  itemCount: state.messages.length + (state.isBotTyping ? 1 : 0),
                  itemBuilder: (context, idx) {
                    if (idx < state.messages.length) {
                      final msg = state.messages[idx];
                      return ChatbotMessageBubble(
                        message: msg,
                        onFollowUpTap: (q) {
                          context.read<ChatbotCubit>().askQuestion(q);
                          _scrollToBottom();
                        },
                        onActionTap: (route) => _handleActionRoute(context, route),
                      );
                    } else {
                      return const ChatbotTypingIndicator();
                    }
                  },
                );
              },
            ),
          ),

          // Bottom Input Field
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h + bottomInset),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: NotebookColors.rulerCard),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: NotebookColors.ink,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendCustomQuestion(context),
                      decoration: InputDecoration(
                        hintText: 'اكتب استفسارك هنا...',
                        hintStyle: TextStyle(
                          fontSize: 11.5.sp,
                          color: NotebookColors.pencil,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: NotebookColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18.r,
                    ),
                    tooltip: 'إرسال',
                    onPressed: () => _sendCustomQuestion(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
