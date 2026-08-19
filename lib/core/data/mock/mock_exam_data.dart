/// Mock exam, question, submission, and comment data for testing.
class MockExamData {
  MockExamData._();

  /// Sample exams.
  static final mockExams = [
    {
      'id': 'e1',
      'title': 'امتحان الرياضيات - الفصل الأول',
      'duration_minutes': 60,
      'max_score': 20,
      'is_published': true,
      'course_id': 'c1',
    },
    {
      'id': 'e2',
      'title': 'امتحان الفيزياء - التراكمي',
      'duration_minutes': 45,
      'max_score': 20,
      'is_published': false,
      'course_id': 'c2',
    },
  ];

  /// Sample exam questions.
  static final mockQuestions = [
    {
      'id': 'q1',
      'question_type': 'mcq',
      'text': 'ما ناتج 5 + 3 × 2؟',
      'options': ['11', '16', '13', '10'],
      'correct_answer': '11',
      'points': 1,
    },
    {
      'id': 'q2',
      'question_type': 'mcq',
      'text': 'ما هي قيمة √144؟',
      'options': ['11', '12', '13', '14'],
      'correct_answer': '12',
      'points': 1,
    },
    {
      'id': 'q3',
      'question_type': 'tf',
      'text': 'العددين 7 و 11 أوليان',
      'options': ['صح', 'خطأ'],
      'correct_answer': 'صح',
      'points': 1,
    },
    {
      'id': 'q4',
      'question_type': 'mcq',
      'text': 'إذا كان س + 5 = 12 ف قيمة س تساوي',
      'options': ['5', '6', '7', '8'],
      'correct_answer': '7',
      'points': 1,
    },
    {
      'id': 'q5',
      'question_type': 'mcq',
      'text': 'نسبة 25% من 200 تساوي',
      'options': ['25', '40', '50', '75'],
      'correct_answer': '50',
      'points': 1,
    },
  ];

  /// Sample exam submissions (grade history).
  static final mockSubmissions = [
    {
      'id': 'sub1',
      'score': 16,
      'total_points': 20,
      'exams': {'title': 'امتحان الرياضيات - الفصل الأول'},
    },
    {
      'id': 'sub2',
      'score': 18,
      'total_points': 20,
      'exams': {'title': 'امتحان الفيزياء - التراكمي'},
    },
    {
      'id': 'sub3',
      'score': 12,
      'total_points': 20,
      'exams': {'title': 'امتحان العلوم - وحدة الكيمياء'},
    },
  ];

  /// Sample lesson comments.
  static final mockComments = [
    {
      'id': 'cm1',
      'text': 'شرح ممتاز، شكراً يا أستاذ!',
      'users': {'full_name': 'سارة أحمد'},
      'created_at': '2025-01-15',
    },
    {
      'id': 'cm2',
      'text': 'هل يمكن تكرار الجزء الأخير؟',
      'users': {'full_name': 'محمد حسين'},
      'created_at': '2025-01-15',
    },
    {
      'id': 'cm3',
      'text': 'محتوى رائع ومفيد جداً',
      'users': {'full_name': 'نورا خالد'},
      'created_at': '2025-01-16',
    },
  ];
}
