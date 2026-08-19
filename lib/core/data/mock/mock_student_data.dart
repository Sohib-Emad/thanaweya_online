/// Mock student data for teacher management views and testing.
class MockStudentData {
  MockStudentData._();

  /// Sample students with enrolled courses.
  static final mockStudents = [
    {
      'id': 'st1',
      'users': {
        'full_name': 'سارة أحمد محمود',
        'email': 'sara@test.com',
        'phone': '01012345678',
        'governorate': 'القاهرة',
      },
      'grade': 'الصف الثالث الثانوي',
      'system': 'عامة (قديم)',
      'courses': [
        {
          'course_id': 'c1',
          'course_title': 'مراجعة الفيزياء الكهربية',
          'price': '350 ج.م',
          'is_activated': true,
          'code': 'TH-8921-X90',
          'payment_status': 'تم الدفع 💳',
        },
        {
          'course_id': 'c2',
          'course_title': 'الفيزياء الحديثة والتطبيقية',
          'price': '300 ج.م',
          'is_activated': false,
          'code': 'TH-4410-K22',
          'payment_status': 'في انتظار التفعيل ⏳',
        },
      ],
    },
    {
      'id': 'st2',
      'users': {
        'full_name': 'محمد حسين علي',
        'email': 'mohamed@test.com',
        'phone': '01123456789',
        'governorate': 'الجيزة',
      },
      'grade': 'مسار البكالوريا (IB)',
      'system': 'البكالوريا (IB)',
      'courses': [
        {
          'course_id': 'c3',
          'course_title': 'مسار الطب وعلوم الحياة',
          'price': '450 ج.م',
          'is_activated': true,
          'code': 'IB-9920-MED',
          'payment_status': 'تم الدفع 💳',
        },
      ],
    },
    {
      'id': 'st3',
      'users': {
        'full_name': 'نورا خالد الشريف',
        'email': 'nora@test.com',
        'phone': '01234567890',
        'governorate': 'الإسكندرية',
      },
      'grade': 'الصف الثاني الثانوي',
      'system': 'عامة (قديم)',
      'courses': [
        {
          'course_id': 'c1',
          'course_title': 'الرياضيات العامة والبحثة',
          'price': '300 ج.م',
          'is_activated': false,
          'code': 'TH-1102-MTH',
          'payment_status': 'في انتظار التفعيل ⏳',
        },
      ],
    },
    {
      'id': 'st4',
      'users': {
        'full_name': 'عمر سعيد حسن',
        'email': 'omar@test.com',
        'phone': '01055544332',
        'governorate': 'المنصورة',
      },
      'grade': 'الصف الأول الثانوي',
      'system': 'عامة (قديم)',
      'courses': [
        {
          'course_id': 'c2',
          'course_title': 'مبادئ العلوم والفيزياء',
          'price': '250 ج.م',
          'is_activated': true,
          'code': 'TH-7731-PHY',
          'payment_status': 'تم الدفع 💳',
        },
      ],
    },
    {
      'id': 'st5',
      'users': {
        'full_name': 'ريم عبدالله مصطفى',
        'email': 'reem@test.com',
        'phone': '01188776655',
        'governorate': 'أسيوط',
      },
      'grade': 'مسار البكالوريا (IB)',
      'system': 'البكالوريا (IB)',
      'courses': [
        {
          'course_id': 'c4',
          'course_title': 'مسار الهندسة وعلوم الحاسب',
          'price': '500 ج.م',
          'is_activated': false,
          'code': 'IB-3301-ENG',
          'payment_status': 'في انتظار التفعيل ⏳',
        },
      ],
    },
  ];
}
