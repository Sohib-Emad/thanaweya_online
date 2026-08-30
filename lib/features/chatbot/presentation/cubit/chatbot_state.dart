import 'package:equatable/equatable.dart';
import '../../domain/entities/faq_item_entity.dart';
import '../../domain/entities/chatbot_message_entity.dart';

class ChatbotState extends Equatable {
  final List<ChatbotMessageEntity> messages;
  final List<String> categories;
  final String selectedCategory;
  final List<FaqItemEntity> categoryQuestions;
  final bool isBotTyping;

  const ChatbotState({
    this.messages = const [],
    this.categories = const [],
    this.selectedCategory = '',
    this.categoryQuestions = const [],
    this.isBotTyping = false,
  });

  ChatbotState copyWith({
    List<ChatbotMessageEntity>? messages,
    List<String>? categories,
    String? selectedCategory,
    List<FaqItemEntity>? categoryQuestions,
    bool? isBotTyping,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categoryQuestions: categoryQuestions ?? this.categoryQuestions,
      isBotTyping: isBotTyping ?? this.isBotTyping,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        categories,
        selectedCategory,
        categoryQuestions,
        isBotTyping,
      ];
}
