class AppStrings {
  AppStrings._();

  // General
  static const String appName = 'ثانوية أونلاين';
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String retry = 'إعادة المحاولة';
  static const String cancel = 'إلغاء';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String confirm = 'تأكيد';
  static const String back = 'رجوع';
  static const String next = 'التالي';
  static const String done = 'تم';
  static const String search = 'بحث';
  static const String noData = 'لا توجد بيانات';
  static const String offline = 'لا يوجد اتصال بالإنترنت';
  static const String offlineMessage = 'تحقق من اتصالك بالإنترنت وأعد المحاولة';

  // Auth
  static const String login = 'تسجيل الدخول';
  static const String register = 'إنشاء حساب';
  static const String logout = 'تسجيل الخروج';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String fullName = 'الاسم الكامل';
  static const String phone = 'رقم الهاتف';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String resetPassword = 'إعادة تعيين كلمة المرور';
  static const String otpVerification = ' التحقق بالرمز';
  static const String enterOtp = 'أدخل الرمز المكون من 6 أرقام';
  static const String verify = 'تحقق';
  static const String resendCode = 'إعادة إرسال الرمز';

  // Role Selection
  static const String selectRole = 'اختر هويةك';
  static const String iAmTeacher = 'أنا معلم';
  static const String iAmStudent = 'أنا طالب';
  static const String teacherDescription = 'أنشئ دورات وامتحانات وادرس طلابك';
  static const String studentDescription = 'احصل على دورات وشاهد الدروس وتابع تقدمك';

  // Teacher Onboarding
  static const String teacherRegistration = 'تسجيل المعلم';
  static const String selectSubject = 'اختر المادة';
  static const String selectStage = 'اختر المرحلة';
  static const String bio = 'نبذة عنك';
  static const String pendingReview = 'بانتظار المراجعة';
  static const String pendingReviewMessage =
      'تم إرسال طلبك بنجاح. سيتم مراجعته من قبل الإدارة قريباً.';
  static const String rejected = 'تم رفض الطلب';
  static const String rejectionReason = 'سبب الرفض';

  // Stages
  static const String firstStage = 'الصف الأول الثانوي';
  static const String secondStage = 'الصف الثاني الثانوي';
  static const String thirdStage = 'الصف الثالث الثانوي';

  // Teacher Dashboard
  static const String teacherDashboard = 'لوحة التحكم';
  static const String myCourses = 'دروسي';
  static const String myStudents = 'طلابي';
  static const String myReports = 'تقاريري';
  static const String settings = 'الإعدادات';
  static const String totalStudents = 'إجمالي الطلاب';
  static const String totalCourses = 'إجمالي الدورات';
  static const String totalExams = 'إجمالي الامتحانات';

  // Courses
  static const String createCourse = 'إنشاء دورة';
  static const String courseName = 'اسم الدورة';
  static const String courseDescription = 'وصف الدورة';
  static const String coverImage = 'صورة الغلاف';
  static const String lessons = 'الدروس';
  static const String lessonsCount = 'الدروس';
  static const String addLesson = 'إضافة درس';
  static const String lessonTitle = 'عنوان الدرس';
  static const String lessonDescription = 'وصف الدرس';
  static const String youtubeLink = 'رابط يوتيوب';
  static const String uploadVideo = 'رفع فيديو';
  static const String freePreview = 'معاينة مجانية';
  static const String publish = 'نشر';

  // Student Onboarding
  static const String studentRegistration = 'تسجيل الطالب';
  static const String selectSubjects = 'اختر المواد';
  static const String selectTeachers = 'اختر المعلمين';
  static const String gradeLevel = 'المستوى الدراسي';
  static const String parentPhone = 'هاتف ولي الأمر';
  static const String activationCode = 'كود التفعيل';
  static const String enterActivationCode = 'أدخل كود التفعيل';
  static const String activate = 'تفعيل';

  // Student Dashboard
  static const String studentDashboard = 'لوحة التحكم';
  static const String home = 'الرئيسية';
  static const String examsTab = 'الامتحانات';
  static const String gradesTab = 'الدرجات';

  // Exams
  static const String createExam = 'إنشاء امتحان';
  static const String examTitle = 'عنوان الامتحان';
  static const String duration = 'المدة (دقائق)';
  static const String startDate = 'تاريخ البداية';
  static const String endDate = 'تاريخ النهاية';
  static const String addQuestion = 'إضافة سؤال';
  static const String questionType = 'نوع السؤال';
  static const String multipleChoice = 'اختيار من متعدد';
  static const String trueFalse = 'صح أم خطأ';
  static const String essay = 'سؤال مقالي';
  static const String correctAnswer = 'الإجابة الصحيحة';
  static const String points = 'النقاط';
  static const String startExam = 'بدء الامتحان';
  static const String submitExam = 'تقديم الامتحان';
  static const String examResult = 'نتيجة الامتحان';
  static const String score = 'الدرجة';
  static const String timeRemaining = 'الوقت المتبقي';

  // Students Management
  static const String studentsList = 'قائمة الطلاب';
  static const String studentDetails = 'تفاصيل الطالب';
  static const String generateCodes = 'إنشاء أكواد';
  static const String exportCodes = 'تصدير الأكواد';

  // Admin
  static const String adminDashboard = 'لوحة تحكم المدير';
  static const String pendingRequests = 'الطلبات المعلقة';
  static const String approve = 'موافقة';
  static const String reject = 'رفض';
  static const String manageSubjects = 'إدارة المواد';
  static const String subscriptionPlans = 'باقات الاشتراك';
  static const String platformReports = 'تقارير المنصة';

  // Subjects
  static const String mathematics = 'رياضيات';
  static const String physics = 'فيزياء';
  static const String chemistry = 'كيمياء';
  static const String biology = 'أحياء';
  static const String arabic = 'لغة عربية';
  static const String english = 'لغة إنجليزية';
  static const String french = 'لغة فرنسية';
  static const String history = 'تاريخ';
  static const String geography = 'جغرافيا';
  static const String philosophy = 'فلسفة';
  static const String psychology = 'علم نفس';

  // Validation
  static const String fieldRequired = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';
  static const String passwordMismatch = 'كلمتا المرور غير متطابقتين';
  static const String invalidOtp = 'الرمز غير صحيح';
}
