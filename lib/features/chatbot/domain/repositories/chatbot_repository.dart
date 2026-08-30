import '../entities/faq_item_entity.dart';
import '../entities/chatbot_message_entity.dart';

abstract class ChatbotRepository {
  List<String> getCategories();

  List<FaqItemEntity> getQuestionsByCategory(String category);

  ChatbotMessageEntity answerQuestion(String question);

  ChatbotMessageEntity getWelcomeMessage();
}
