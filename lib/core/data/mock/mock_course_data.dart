/// Mock course and lesson data for testing and development.
class MockCourseData {
  MockCourseData._();

  /// Sample courses.
  static final mockCourses = [
    {
      'id': 'c1',
      'title': 'الرياضيات - الفصل الأول',
      'description': 'شرح شامل لمنهج الرياضيات',
      'teacher_id': 't1',
    },
    {
      'id': 'c2',
      'title': 'الفيزياء - المقدمة',
      'description': 'أساسيات الفيزياء للمرحلة الثانوية',
      'teacher_id': 't2',
    },
    {
      'id': 'c3',
      'title': 'العلوم - وحدة الكيمياء',
      'description': 'شرح وحدة الكيمياء',
      'teacher_id': 't3',
    },
  ];

  /// Sample lessons linked to courses.
  static final mockLessons = [
    {
      'id': 'l1',
      'title': 'الدرس الأول: الأعداد المركبة',
      'description': 'شرح الأعداد المركبة والعمليات عليها',
      'video_url_or_id': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'course_id': 'c1',
      'is_free_preview': true,
      'display_order': 1,
    },
    {
      'id': 'l2',
      'title': 'الدرس الثاني: الدوال',
      'description': 'مقدمة في الدوال الرياضية',
      'video_url_or_id': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'course_id': 'c1',
      'is_free_preview': false,
      'display_order': 2,
    },
    {
      'id': 'l3',
      'title': 'الدرس الثالث: المتتاليات',
      'description': 'المتتاليات الحسابية والهندسية',
      'video_url_or_id': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'course_id': 'c1',
      'is_free_preview': false,
      'display_order': 3,
    },
    {
      'id': 'l4',
      'title': 'الدرس الرابع: الجبر',
      'description': 'المعادلات والمتباينات',
      'video_url_or_id': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'course_id': 'c1',
      'is_free_preview': true,
      'display_order': 4,
    },
  ];
}
