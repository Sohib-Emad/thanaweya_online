import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/features/chatbot/domain/entities/faq_item_entity.dart';
import '../../domain/entities/chatbot_message_entity.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../data/repositories/chatbot_repository_impl.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatbotRepository _repository;

  ChatbotCubit({ChatbotRepository? repository})
      : _repository = repository ?? ChatbotRepositoryImpl(),
        super(const ChatbotState()) {
    init();
  }

  void init() {
    final categories = _repository.getCategories();
    final firstCategory = categories.isNotEmpty ? categories.first : '';
    final initialQuestions = firstCategory.isNotEmpty
        ? _repository.getQuestionsByCategory(firstCategory)
        : const <FaqItemEntity>[];

    final welcomeMessage = _repository.getWelcomeMessage();

    emit(state.copyWith(
      categories: categories,
      selectedCategory: firstCategory,
      categoryQuestions: initialQuestions,
      messages: [welcomeMessage],
      isBotTyping: false,
    ));
  }

  void selectCategory(String category) {
    if (category == state.selectedCategory) return;
    final questions = _repository.getQuestionsByCategory(category);
    emit(state.copyWith(
      selectedCategory: category,
      categoryQuestions: questions,
    ));
  }

  Future<void> askQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state.isBotTyping) return;

    // 1. إضافة رسالة المستخدم
    final userMsg = ChatbotMessageEntity(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatbotMessageEntity>.from(state.messages)..add(userMsg);

    emit(state.copyWith(
      messages: updatedMessages,
      isBotTyping: true,
    ));

    // 2. محاكاة وقت الكتابة الواقعي (750ms)
    await Future.delayed(const Duration(milliseconds: 750));

    // 3. استخراج الرد المناسب
    final botResponse = _repository.answerQuestion(trimmed);

    final finalMessages = List<ChatbotMessageEntity>.from(state.messages)..add(botResponse);

    emit(state.copyWith(
      messages: finalMessages,
      isBotTyping: false,
    ));
  }

  void resetChat() {
    init();
  }
}
