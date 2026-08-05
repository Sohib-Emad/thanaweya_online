class MockData {
  MockData._();

  // ─── Auth ───
  static const mockEmail = 'teacher@test.com';
  static const mockPassword = '123456';
  static const mockUserName = 'أحمد محمد';
  static const mockStudentName = 'سارة أحمد';

  // ─── Subjects ───
  static final mockSubjects = [
    {'id': 's1', 'name_ar': 'اللغة العربية', 'name_en': 'Arabic'},
    {'id': 's2', 'name_ar': 'اللغة الإنجليزية', 'name_en': 'English'},
    {'id': 's3', 'name_ar': 'اللغة الفرنساوية', 'name_en': 'French'},
    {'id': 's4', 'name_ar': 'اللغة الألمانية', 'name_en': 'German'},
    {'id': 's5', 'name_ar': 'اللغة الإيطالية', 'name_en': 'Italian'},
    {'id': 's6', 'name_ar': 'الرياضيات العامة', 'name_en': 'General Math'},
    {'id': 's7', 'name_ar': 'الرياضيات البحتة', 'name_en': 'Pure Math'},
    {'id': 's8', 'name_ar': 'الرياضيات التطبيقية', 'name_en': 'Applied Math'},
    {'id': 's9', 'name_ar': 'الفيزياء', 'name_en': 'Physics'},
    {'id': 's10', 'name_ar': 'الكيمياء', 'name_en': 'Chemistry'},
    {'id': 's11', 'name_ar': 'الأحياء', 'name_en': 'Biology'},
    {'id': 's12', 'name_ar': 'الجيولوجيا وعلوم البيئة', 'name_en': 'Geology'},
    {'id': 's13', 'name_ar': 'العلوم العامة', 'name_en': 'General Science'},
    {'id': 's14', 'name_ar': 'التاريخ', 'name_en': 'History'},
    {'id': 's15', 'name_ar': 'الجغرافيا', 'name_en': 'Geography'},
    {
      'id': 's16',
      'name_ar': 'الفلسفة والمنطق',
      'name_en': 'Philosophy & Logic',
    },
    {'id': 's17', 'name_ar': 'علم النفس والاجتماع', 'name_en': 'Psychology'},
    {
      'id': 's18',
      'name_ar': 'الاقتصاد والإحصاء',
      'name_en': 'Economics & Statistics',
    },
    {
      'id': 's19',
      'name_ar': 'الحاسب الآلي والبرمجة',
      'name_en': 'Computer Science',
    },
    {
      'id': 's20',
      'name_ar': 'التربية الدينية والوطنية',
      'name_en': 'Civic Education',
    },
  ];

  // ─── Teachers (for student selection) ───
  static final mockTeachers = [
    {
      'id': 't1',
      'users': {'full_name': 'أ. محمد علي', 'email': 'mohamed@test.com'},
      'subjects': {'name_ar': 'الرياضيات'},
      'subject_id': 'الرياضيات',
    },
    {
      'id': 't2',
      'users': {'full_name': 'أ. فاطمة حسن', 'email': 'fatma@test.com'},
      'subjects': {'name_ar': 'الفيزياء'},
      'subject_id': 'الفيزياء',
    },
    {
      'id': 't3',
      'users': {'full_name': 'أ. خالد إبراهيم', 'email': 'khaled@test.com'},
      'subjects': {'name_ar': 'العلوم'},
      'subject_id': 'العلوم',
    },
  ];

  // ─── Courses ───
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

  // ─── Lessons ───
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

  // ─── Exams ───
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

  // ─── Questions ───
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

  // ─── Students (for teacher management) ───
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

  // ─── Comments ───
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

  // ─── Submissions (Grade History) ───
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

  // ─── Admin Stats ───
  static final mockAdminStats = {
    'pending_requests': 5,
    'total_teachers': 12,
    'total_students': 89,
  };

  // ─── Pending Teachers (admin view) ───
  static final mockPendingTeachers = [
    {
      'id': 'pt1',
      'users': {'full_name': 'أ. عادل مصطفى', 'email': 'adel@test.com'},
      'subjects': {'name_ar': 'الرياضيات'},
      'approval_status': 'pending',
    },
    {
      'id': 'pt2',
      'users': {'full_name': 'أ. هبة الله أحمد', 'email': 'heba@test.com'},
      'subjects': {'name_ar': 'اللغة العربية'},
      'approval_status': 'pending',
    },
    {
      'id': 'pt3',
      'users': {'full_name': 'أ. كريم شريف', 'email': 'karim@test.com'},
      'subjects': {'name_ar': 'الفيزياء'},
      'approval_status': 'pending',
    },
  ];

  // ─── All Teachers (admin view with status) ───
  static final mockAllTeachers = [
    ...mockTeachers.map((t) => {...t, 'approval_status': 'approved'}),
    ...mockPendingTeachers,
    {
      'id': 't_rejected',
      'users': {'full_name': 'أ. سيد حسن', 'email': 'sayed@test.com'},
      'subjects': {'name_ar': 'العلوم'},
      'approval_status': 'rejected',
    },
  ];

  // ─── Recent Teachers (dashboard) ───
  static final mockRecentTeachers = [
    {
      'users': {'full_name': 'أ. محمد علي'},
      'subjects': {'name_ar': 'الرياضيات'},
    },
    {
      'users': {'full_name': 'أ. فاطمة حسن'},
      'subjects': {'name_ar': 'الفيزياء'},
    },
    {
      'users': {'full_name': 'أ. خالد إبراهيم'},
      'subjects': {'name_ar': 'العلوم'},
    },
  ];

  // ─── Subscription Plans ───
  static final mockPlans = [
    {
      'id': 'p1',
      'name': 'باقة شهرية',
      'price': 150,
      'billing_period': 'monthly',
      'is_active': true,
    },
    {
      'id': 'p2',
      'name': 'باقة فصل دراسي',
      'price': 400,
      'billing_period': 'term',
      'is_active': true,
    },
    {
      'id': 'p3',
      'name': 'باقة سنوية',
      'price': 1000,
      'billing_period': 'yearly',
      'is_active': false,
    },
  ];
}
