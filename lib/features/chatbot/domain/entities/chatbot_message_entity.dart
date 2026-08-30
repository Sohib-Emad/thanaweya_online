import 'package:equatable/equatable.dart';

class ChatbotMessageEntity extends Equatable {
  final String id;
  final String text;
  final bool isUser;              // هل هي من المستخدم أم من البوت؟
  final DateTime timestamp;
  final String? actionLabel;
  final String? actionRoute;
  final List<String> followUpQuestions;

  const ChatbotMessageEntity({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionLabel,
    this.actionRoute,
    this.followUpQuestions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        text,
        isUser,
        timestamp,
        actionLabel,
        actionRoute,
        followUpQuestions,
      ];
}
