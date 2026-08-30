import 'package:equatable/equatable.dart';

class FaqItemEntity extends Equatable {
  final String id;
  final String category;          // مثال: '💳 المحفظة والشحن'
  final String question;          // نص السؤال
  final String answer;            // نص الإجابة الكاملة
  final String? actionLabel;      // نص الزر (مثال: 'فتح المحفظة')
  final String? actionRoute;      // المسار (مثال: 'wallet' أو 'support' أو 'courses')
  final List<String> followUps;   // أسئلة تتابعية مرتبطة

  const FaqItemEntity({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.actionLabel,
    this.actionRoute,
    this.followUps = const [],
  });

  @override
  List<Object?> get props => [
        id,
        category,
        question,
        answer,
        actionLabel,
        actionRoute,
        followUps,
      ];
}
