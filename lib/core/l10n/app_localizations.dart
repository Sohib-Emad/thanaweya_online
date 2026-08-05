import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // General
  String get appName => 'ثانوية أونلاين';
  String get loading => 'جاري التحميل...';
  String get error => 'حدث خطأ';
  String get retry => 'إعادة المحاولة';
  String get cancel => 'إلغاء';
  String get save => 'حفظ';
  String get delete => 'حذف';
  String get edit => 'تعديل';
  String get add => 'إضافة';
  String get confirm => 'تأكيد';
  String get back => 'رجوع';
  String get next => 'التالي';
  String get done => 'تم';
  String get search => 'بحث';
  String get noData => 'لا توجد بيانات';
  String get offline => 'لا يوجد اتصال بالإنترنت';
  String get offlineMessage => 'تحقق من اتصالك بالإنترنت وأعد المحاولة';

  // Auth
  String get login => 'تسجيل الدخول';
  String get register => 'إنشاء حساب';
  String get logout => 'تسجيل الخروج';
  String get email => 'البريد الإلكتروني';
  String get password => 'كلمة المرور';
  String get confirmPassword => 'تأكيد كلمة المرور';
  String get fullName => 'الاسم الكامل';
  String get phone => 'رقم الهاتف';
  String get forgotPassword => 'نسيت كلمة المرور؟';
  String get resetPassword => 'إعادة تعيين كلمة المرور';
  String get otpVerification => ' التحقق بالرمز';
  String get enterOtp => 'أدخل الرمز المكون من 6 أرقام';
  String get verify => 'تحقق';
  String get resendCode => 'إعادة إرسال الرمز';

  // Role Selection
  String get selectRole => 'اختر هويةك';
  String get iAmTeacher => 'أنا معلم';
  String get iAmStudent => 'أنا طالب';
  String get teacherDescription => 'أنشئ دورات وامتحانات وادرس طلابك';
  String get studentDescription => 'احصل على دورات وشاهد الدروس وتابع تقدمك';

  // Teacher
  String get teacherRegistration => 'تسجيل المعلم';
  String get selectSubject => 'اختر المادة';
  String get selectStage => 'اختر المرحلة';
  String get bio => 'نبذة عنك';
  String get pendingReview => 'بانتظار المراجعة';
  String get pendingReviewMessage =>
      'تم إرسال طلبك بنجاح. سيتم مراجعته من قبل الإدارة قريباً.';
  String get rejected => 'تم رفض الطلب';
  String get rejectionReason => 'سبب الرفض';

  // Stages
  String get firstStage => 'الصف الأول الثانوي';
  String get secondStage => 'الصف الثاني الثانوي';
  String get thirdStage => 'الصف الثالث الثانوي';

  // Dashboard
  String get teacherDashboard => 'لوحة التحكم';
  String get myCourses => 'دروسي';
  String get myStudents => 'طلابي';
  String get myReports => 'تقاريري';
  String get settings => 'الإعدادات';
  String get totalStudents => 'إجمالي الطلاب';
  String get totalCourses => 'إجمالي الدورات';
  String get totalExams => 'إجمالي الامتحانات';

  // Courses
  String get createCourse => 'إنشاء دورة';
  String get courseName => 'اسم الدورة';
  String get courseDescription => 'وصف الدورة';
  String get coverImage => 'صورة الغلاف';
  String get lessonsCount => 'الدروس';
  String get addLesson => 'إضافة درس';
  String get lessonTitle => 'عنوان الدرس';
  String get lessonDescription => 'وصف الدرس';
  String get youtubeLink => 'رابط يوتيوب';
  String get uploadVideo => 'رفع فيديو';
  String get freePreview => 'معاينة مجانية';
  String get publish => 'نشر';

  // Student
  String get studentRegistration => 'تسجيل الطالب';
  String get selectSubjects => 'اختر المواد';
  String get selectTeachers => 'اختر المعلمين';
  String get gradeLevel => 'المستوى الدراسي';
  String get parentPhone => 'هاتف ولي الأمر';
  String get activate => 'تفعيل';

  // Student Dashboard
  String get studentDashboard => 'لوحة التحكم';
  String get home => 'الرئيسية';
  String get examsTab => 'الامتحانات';
  String get gradesTab => 'الدرجات';

  // Exams
  String get createExam => 'إنشاء امتحان';
  String get examTitle => 'عنوان الامتحان';
  String get duration => 'المدة (دقائق)';
  String get startDate => 'تاريخ البداية';
  String get endDate => 'تاريخ النهاية';
  String get addQuestion => 'إضافة سؤال';
  String get questionType => 'نوع السؤال';
  String get multipleChoice => 'اختيار من متعدد';
  String get trueFalse => 'صح أم خطأ';
  String get essay => 'سؤال مقالي';
  String get correctAnswer => 'الإجابة الصحيحة';
  String get pointsLabel => 'النقاط';
  String get startExam => 'بدء الامتحان';
  String get submitExam => 'تقديم الامتحان';
  String get examResult => 'نتيجة الامتحان';
  String get score => 'الدرجة';
  String get timeRemaining => 'الوقت المتبقي';

  // Students Management
  String get studentsList => 'قائمة الطلاب';
  String get studentDetails => 'تفاصيل الطالب';
  String get generateCodes => 'إنشاء أكواد';
  String get exportCodes => 'تصدير الأكواد';

  // Admin
  String get adminDashboard => 'لوحة تحكم المدير';
  String get pendingRequests => 'الطلبات المعلقة';
  String get approve => 'موافقة';
  String get reject => 'رفض';
  String get manageSubjects => 'إدارة المواد';
  String get subscriptionPlans => 'باقات الاشتراك';
  String get platformReports => 'تقارير المنصة';

  // Validation
  String get fieldRequired => 'هذا الحقل مطلوب';
  String get invalidEmail => 'البريد الإلكتروني غير صحيح';
  String get invalidPhone => 'رقم الهاتف غير صحيح';
  String get passwordTooShort => 'كلمة المرور قصيرة جداً';
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';
  String get invalidOtp => 'الرمز غير صحيح';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
