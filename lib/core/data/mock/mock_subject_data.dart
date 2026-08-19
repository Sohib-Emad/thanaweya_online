/// Mock subject and teacher selection data for testing and development.
class MockSubjectData {
  MockSubjectData._();

  /// Available academic subjects.
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

  /// Teachers available for student selection.
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
}
