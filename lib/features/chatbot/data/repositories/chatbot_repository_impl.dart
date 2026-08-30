import '../../domain/entities/faq_item_entity.dart';
import '../../domain/entities/chatbot_message_entity.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_local_datasource.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotLocalDataSource _dataSource;

  ChatbotRepositoryImpl([ChatbotLocalDataSource? dataSource])
      : _dataSource = dataSource ?? ChatbotLocalDataSourceImpl();

  @override
  List<String> getCategories() {
    return _dataSource.getCategories();
  }

  @override
  List<FaqItemEntity> getQuestionsByCategory(String category) {
    return _dataSource.getQuestionsByCategory(category);
  }

  @override
  ChatbotMessageEntity answerQuestion(String question) {
    return _dataSource.answerQuestion(question);
  }

  @override
  ChatbotMessageEntity getWelcomeMessage() {
    return _dataSource.getWelcomeMessage();
  }
}
