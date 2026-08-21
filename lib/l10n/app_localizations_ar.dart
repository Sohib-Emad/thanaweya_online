// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ثانوية أونلاين';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'حدث خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get search => 'بحث';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get offline => 'لا يوجد اتصال بالإنترنت';

  @override
  String get offlineMessage => 'تحقق من اتصالك بالإنترنت وأعد المحاولة';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'البريد الإلكتروني غير صحيح';

  @override
  String get invalidPhone => 'رقم الهاتف غير صحيح';

  @override
  String get passwordTooShort => 'كلمة المرور قصيرة جداً';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get invalidOtp => 'الرمز غير صحيح';

  @override
  String get home => 'الرئيسية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get parentPhone => 'هاتف ولي الأمر';

  @override
  String get gradeLevel => 'المستوى الدراسي';

  @override
  String get firstStage => 'الصف الأول الثانوي';

  @override
  String get secondStage => 'الصف الثاني الثانوي';

  @override
  String get thirdStage => 'الصف الثالث الثانوي';

  @override
  String get studentRegistration => 'تسجيل الطالب';

  @override
  String get signUpSubtitle => 'سجّل بياناتك لبدء دفتر الطالب';

  @override
  String get fullNameHint => 'أدخل الاسم الكامل...';

  @override
  String get gradeLevelHint => 'اختر المستوى الدراسي...';

  @override
  String get creatingAccount => 'جاري إنشاء الحساب...';

  @override
  String get chooseFromGallery => 'اختيار من معرض الصور';

  @override
  String get chooseFromGallerySubtitle => 'اختر صورة واضحة محفوظة على جهازك';

  @override
  String get takePhoto => 'التقاط صورة جديدة بالكاميرا';

  @override
  String get takePhotoSubtitle => 'استخدم كاميرا الهاتف لتصوير شخصية فورية';

  @override
  String get chooseProfilePicture => 'اختيار صورة البروفايل';

  @override
  String get selectSubjects => 'اختر المواد';

  @override
  String get selectSubjectsSubtitle => 'اختر المواد التي ستدرسها هذا العام';

  @override
  String get generalSystem => 'عامة';

  @override
  String get baccalaureateSystem => 'نظام البكالوريا';

  @override
  String get loadSubjectsError => 'حدث خطأ أثناء تحميل المواد';

  @override
  String get noSubjectsAvailable => 'لا توجد مواد متاحة';

  @override
  String nextWithCount(int count) {
    return 'التالي ($count)';
  }

  @override
  String get trackMedicine => 'مسار الطب وعلوم الحياة';

  @override
  String get trackMedicineDesc =>
      'يؤهل لكليات: الطب البشري، الصيدلة، الأسنان، العلاج الطبيعي، والتمريض.';

  @override
  String get trackEngineering => 'مسار الهندسة وعلوم الحاسب';

  @override
  String get trackEngineeringDesc =>
      'يؤهل لكليات: الهندسة، الحاسبات والمعلومات، والتكنولوجيا الحيوية.';

  @override
  String get trackBusiness => 'مسار الأعمال والاقتصاد';

  @override
  String get trackBusinessDesc =>
      'يؤهل لكليات: التجارة، الاقتصاد والعلوم السياسية، الإعلام، والحقوق.';

  @override
  String get trackArts => 'مسار الآداب والفنون';

  @override
  String get trackArtsDesc =>
      'يؤهل لكليات: الآداب، الألسن، الفنون الجميلة، ودار العلوم.';

  @override
  String get selectTeachers => 'اختر المعلمين';

  @override
  String get selectTeachersSubtitle => 'اختر المدرسين الذين تريد متابعتهم';

  @override
  String get noTeachersAvailable => 'لا يوجد معلمون متاحون';

  @override
  String get settingsSubtitle => 'إعدادات التطبيق والملف الشخصي';

  @override
  String get studentNotebook => 'دفتر الطالب';

  @override
  String welcomeBack(String name) {
    return 'مرحباً بك، $name 👋';
  }

  @override
  String get whatToLearnToday => 'ما الذي تريد تعلمه اليوم؟';

  @override
  String get searchPlaceholder => 'ابحث عن مادة أو دورة أو مدرس...';

  @override
  String get discountStamp => 'خصم 25%';

  @override
  String get todaysOffer => 'عرض اليوم الخاص!';

  @override
  String get todaysOfferMessage =>
      'اشترك الآن واحصل على خصم على أي كورس لمدة محدودة';

  @override
  String get popularCourses => 'الكورسات الشائعة';

  @override
  String get all => 'الكل';

  @override
  String filteredCourses(int count) {
    return 'تم التصفية: $count دورة';
  }

  @override
  String get clear => 'مسح';

  @override
  String get noCoursesMatch => 'لا توجد كورسات مطابقة للتصفية — جرّب مادة أخرى';

  @override
  String get topTeachers => 'أفضل المدرسين';

  @override
  String get continueCourse => 'متابعة الكورس';

  @override
  String get myCoursesTab => 'كورساتي';

  @override
  String get transactionsTab => 'المعاملات';

  @override
  String get examsTab => 'الامتحانات';

  @override
  String get profileTab => 'الملف';

  @override
  String get myCoursesTitle => 'دوراتي التعليمية';

  @override
  String get myCoursesSubtitle => 'كورساتك على صفحات الدفتر';

  @override
  String get searchInCoursesHint => 'ابحث في دوراتك...';

  @override
  String get completedTab => 'المكتملة';

  @override
  String get ongoingTab => 'مستمر';

  @override
  String get noCoursesMatching => 'لا توجد دورات مطابقة — جرّب تعديل الفلاتر';

  @override
  String get noCompletedCourses => 'لا توجد دورات مكتملة بعد';

  @override
  String get videoLesson => 'فيديو الدرس';

  @override
  String videoOfSubject(String subject) {
    return 'فيديو $subject';
  }

  @override
  String lessonCount(int count) {
    return '$count درس';
  }

  @override
  String get aboutTab => 'عن الكورس';

  @override
  String get curriculumTab => 'المنهج';

  @override
  String get subscribedLabel => 'أنت مشترك في هذا الكورس ✓';

  @override
  String subscribeWithPrice(String price) {
    return 'اشترك وتفعيل الكود — $price';
  }

  @override
  String get activateCode => 'تفعيل كود الاشتراك';

  @override
  String get teacherNotFound => 'تعذر تحديد المدرس، حاول مرة أخرى';

  @override
  String get courseIntroFallback =>
      'يشرح هذا الكورس منهج المادة خطوة بخطوة مع حلول المسائل ومراجعات شاملة تساعدك على الاستعداد للامتحان.';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get readMore => 'اقرأ المزيد...';

  @override
  String get instructor => 'المحاضر';

  @override
  String get teacherRole => 'مدرس';

  @override
  String get whatYouGetTitle => 'ماذا ستتعلم وتأخذ في الكورس؟';

  @override
  String get whatYouGet1 => 'الوصول لدروس الكورس كاملة';

  @override
  String get whatYouGet2 => 'مشاهدة على الموبايل والتابلت والكمبيوتر';

  @override
  String get whatYouGet3 => 'ملخصات ومذكرات للمراجعة';

  @override
  String get whatYouGet4 => 'كويزات وامتحانات تجريبية';

  @override
  String get whatYouGet5 => 'متابعة تقدمك درساً بدرس';

  @override
  String get studentReviewsTitle => 'آراء الطلاب';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get reviewsAvailableNote => 'تقييمات الطلاب متاحة في صفحة الكورس';

  @override
  String get lockedLessonTitle => 'الدرس مغلق';

  @override
  String lockedLessonMessage(String title) {
    return 'عفواً، المنهج متاح للاطلاع فقط. لمشاهدة فيديو \"$title\" يجب الدفع والاشتراك وتفعيل الكود أولاً.';
  }

  @override
  String get payAndActivate => 'الدفع وتفعيل الكود';

  @override
  String get lessonAvailable => 'درس متاح';

  @override
  String get requiresSubscription => 'يتطلب الاشتراك والدفع 🔒';

  @override
  String lessonDurationLocked(String duration) {
    return '$duration · يتطلب الاشتراك والدفع 🔒';
  }

  @override
  String get noIntroVideo => 'لا يوجد فيديو تعريفي';

  @override
  String get courseSectionTitle => 'دروس الكورس';

  @override
  String sectionLabel(String number) {
    return 'القسم $number';
  }

  @override
  String get curriculumTitle => 'منهج الكورس';

  @override
  String get curriculumSubtitle => 'دروسك على صفحات الدفتر';

  @override
  String get searchLessonHint => 'ابحث عن درس أو محتوى...';

  @override
  String get noLessonsYet => 'لا توجد دروس في هذا الكورس بعد';

  @override
  String get restartCourse => 'إعادة بدء الكورس';

  @override
  String get continueLearning => 'متابعة التعلم';

  @override
  String get lessonGeneric => 'درس';

  @override
  String get filterResults => 'تصفية النتائج';

  @override
  String get filterSubtitle => 'حدد مادة أو مرحلة من صفحات الدفتر';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get studySubjects => 'المواد الدراسية';

  @override
  String get noSubjectsNow => 'لا توجد مواد متاحة حالياً';

  @override
  String get studyStage => 'المرحلة الدراسية';

  @override
  String get showAllCourses => 'عرض كل الدورات';

  @override
  String applyFilter(int count) {
    return 'تطبيق الفلترة ($count)';
  }

  @override
  String get watchingLesson => 'مشاهدة الدرس';

  @override
  String get lessonHandout => 'ملزمة الدرس';

  @override
  String get noHandoutYet => 'لا توجد ملزمة مرفقة بهذا الدرس بعد';

  @override
  String get tapToOpen => 'اضغط لفتح الملف';

  @override
  String get lessonExam => 'امتحان الدرس';

  @override
  String get noLessonExam => 'لا يوجد امتحان مخصص لهذا الدرس';

  @override
  String get attemptsExhausted => 'انتهت المحاولات';

  @override
  String examMeta(int duration, int used, int max) {
    return '$duration دقيقة · المحاولات $used/$max';
  }

  @override
  String get contentLockedTitle => 'المحتوى مغلق';

  @override
  String get lockedContentMessage =>
      'هذه الحصة متاحة فقط للطلاب المشتركين. يرجى تفعيل كود الاشتراك أو الاشتراك للوصول الكامل للفيديوهات.';

  @override
  String get videoViewsExhaustedTitle => 'انتهت مشاهدات الفيديو';

  @override
  String get videoViewsExhaustedMessage =>
      'استنفدت عدد مرات مشاهدة هذا الفيديو المسموح بها. تواصل مع المدرس لإعادة فتح الفيديو لك.';

  @override
  String get ok => 'حسناً';

  @override
  String get couldNotOpenFile => 'تعذر فتح الملف';

  @override
  String get videoLockedForSubscribers => 'هذا الفيديو مغلق للمشتركين فقط';

  @override
  String get videoLockedSubMessage =>
      'اشترك في الكورس وفعل كود الاشتراك لمشاهدة جميع الفيديوهات';

  @override
  String get viewsExhaustedOverlay => 'انتهت مشاهدات هذا الفيديو';

  @override
  String viewsCountMessage(int viewCount, int maxViews) {
    return 'تم استهلاك $viewCount من $maxViews مشاهدات · تواصل مع المدرس لإعادة فتحه';
  }

  @override
  String get teacherPageFallback => 'صفحة المدرس';

  @override
  String get teacherPageSubtitle => 'ملف المدرس وبيانات التواصل والسناتر';

  @override
  String get verifiedTeacher => 'مدرس معتمد على ثانوية أونلاين';

  @override
  String whatsappMessage(String teacherName) {
    return 'السلام عليكم أ. $teacherName، أريد الاستفسار عن حصصك وسناترك التعليمية من تطبيق ثانوية أونلاين.';
  }

  @override
  String get whatsappOpenFailed =>
      'تعذر فتح الواتساب، يرجى التحقق من تثبيت التطبيق';

  @override
  String get quickContact => 'التواصل السريع';

  @override
  String get quickContactMessage =>
      'يمكنك التواصل مباشرة مع المعلم للاستفسار عن السناتر، المواعيد، أو أي تفاصيل دراسية أخرى.';

  @override
  String get contactOnWhatsapp => 'تواصل عبر الواتساب';

  @override
  String get bioLabel => 'النبذة التعريفية';

  @override
  String get noBio => 'لا توجد نبذة تعريفية متوفرة حالياً لهذا المعلم.';

  @override
  String get teachingPlaceTitle => 'مكان وطريقة التدريس';

  @override
  String get teachingMethod => 'طريقة التدريس';

  @override
  String get centerLocation => 'مكان السنتر والتدريس';

  @override
  String locatedInGovernorate(String governorate) {
    return 'يتواجد في سناتر محافظة $governorate';
  }

  @override
  String get academicTitle => 'المراحل والأنظمة الدراسية';

  @override
  String get subjectField => 'المادة الدراسية';

  @override
  String get gradeField => 'المراحل الدراسية';

  @override
  String get systemField => 'نظام التدريس';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get generalSecondary => 'ثانوية عامة';

  @override
  String get azhariSecondary => 'ثانوية أزهرية';

  @override
  String get stemSchools => 'مدارس المتفوقين (STEM)';

  @override
  String get modeOnline => 'أونلاين (من خلال المنصة فقط)';

  @override
  String get modeCenter => 'حضور مباشر في السنتر فقط';

  @override
  String get modeBoth => 'أونلاين ومن خلال السناتر التعليمية';

  @override
  String get modeOnlineShort => 'أونلاين';

  @override
  String get teacherInfoLoadError => 'تعذر تحميل معلومات المدرس';

  @override
  String get bookmarksTitle => 'محفوظاتي';

  @override
  String get bookmarksSubtitle => 'كورسات حفظتها للمراجعة';

  @override
  String get loadBookmarksError => 'حدث خطأ في تحميل المحفوظات';

  @override
  String get noBookmarks =>
      'لا توجد محفوظات بعد\nاضغط على أيقونة الحفظ لإضافة الكورسات هنا';

  @override
  String get remove => 'إزالة';

  @override
  String get reviewsSubtitle => 'آراء حقيقية على صفحات الدفتر';

  @override
  String basedOnReviews(int count) {
    return 'بناءً على $count تقييم من الطلاب';
  }

  @override
  String get excellent => 'ممتاز';

  @override
  String get veryGood => 'جيد جداً';

  @override
  String get average => 'متوسط';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد — كن أول من يقيّم هذا الكورس';

  @override
  String get addYourReview => 'أضف تقييمك';

  @override
  String get writeReviewTitle => 'كتابة تقييم';

  @override
  String get writeReviewSubtitle => 'اكتب رأيك بخط يدك';

  @override
  String get reviewHelpsOthers =>
      'تقييمك يساعد زملاءك على اختيار الكورس المناسب';

  @override
  String get yourRatingQuestion => 'ما هو تقييمك للكورس؟';

  @override
  String get detailedReviewTitle => 'اكتب تقييمك بالتفصيل';

  @override
  String get reviewHint =>
      'ما هي تجربتك مع هذا الكورس والمدرس؟ شارك برأيك لمساعدة بقية الطلاب...';

  @override
  String get submitReview => 'إرسال التقييم';

  @override
  String get mustLoginFirst => 'يجب تسجيل الدخول أولاً';

  @override
  String get reviewSubmitted => 'تم إرسال تقييمك بنجاح';

  @override
  String get reviewSubmitError => 'حدث خطأ أثناء إرسال التقييم، حاول مرة أخرى';

  @override
  String get examProgressTitle => 'التقدم والامتحانات';

  @override
  String get examProgressSubtitle => 'اختبر ما درسته على أوراق دفترك';

  @override
  String get loadExamsError => 'حدث خطأ في تحميل الامتحانات';

  @override
  String get noExamsAvailable =>
      'لا توجد امتحانات متاحة حالياً\nستظهر هنا امتحاناتك عندما يضيفها المدرسون';

  @override
  String get examAttemptsExhaustedTitle => 'انتهت محاولات الامتحان';

  @override
  String examAttemptsExhaustedMessage(int max) {
    return 'استنفدت المحاولات المسموحة لهذا الامتحان ($max محاولات). يمكنك الاطلاع على نتائجك أو التواصل مع المدرس لإعادة فتح الامتحان.';
  }

  @override
  String get viewResults => 'عرض النتائج';

  @override
  String examDurationLabel(int duration) {
    return 'مدة الامتحان: $duration دقيقة';
  }

  @override
  String attemptsCount(int used, int max) {
    return 'المحاولات: $used/$max';
  }

  @override
  String get resultsLabel => 'النتائج';

  @override
  String get lockedLabel => 'مقفل';

  @override
  String get enterExam => 'دخول الامتحان';

  @override
  String get anotherAttempt => 'محاولة أخرى';

  @override
  String get comprehensiveExam => 'امتحان شامل';

  @override
  String durationMinutes(int min) {
    return '$min دقيقة';
  }

  @override
  String totalMarks(String marks) {
    return '$marks درجة';
  }

  @override
  String get examInstructionsTitle => 'تعليمات وضوابط الامتحان';

  @override
  String get examInstructionsSubtitle => 'اقرأ القواعد قبل بدء التقييم';

  @override
  String responsibleTeacher(String name) {
    return 'المدرس المسؤول: $name';
  }

  @override
  String get durationStat => 'المدة الزمنية';

  @override
  String get questionCountStat => 'عدد الأسئلة';

  @override
  String get totalScoreStat => 'الدرجة الكلية';

  @override
  String get examRulesTitle => 'قواعد وضوابط الامتحان';

  @override
  String get strictRulesNote => 'ضوابط حازمة، قراءتها إلزامية قبل البدء';

  @override
  String get ruleTimingTitle => 'توقيت دقيق محدد';

  @override
  String get ruleTimingDesc =>
      'يبدأ التوقيت فور دخول الامتحان، وسيتم تسليم الإجابات تلقائياً فور انتهاء الوقت.';

  @override
  String get ruleNoExitTitle => 'حظر الخروج من الشاشة (تسليم تلقائي)';

  @override
  String get ruleNoExitDesc =>
      'في حالة الخروج من التطبيق، تصغير الشاشة، أو الانتقال لتطبيق آخر، سيتم تسليم الامتحان فوراً وحساب الدرجة على ما تم حله فقط!';

  @override
  String get ruleConnectionTitle => 'الحفاظ على استقرار الاتصال';

  @override
  String get ruleConnectionDesc =>
      'تأكد من شحن الهاتف واستقرار شبكة الإنترنت قبل البدء.';

  @override
  String get attemptsFinished => 'انتهت المحاولات المسموحة';

  @override
  String remainingAttempts(int remaining, int max) {
    return 'المحاولات المتبقية: $remaining من $max';
  }

  @override
  String get attemptsFinishedMessage =>
      'يمكنك التواصل مع المدرس لإعادة فتح الامتحان، أو الاطلاع على نتائجك';

  @override
  String retakeMessage(int max) {
    return 'لك كل الحق في إعادة الامتحان حتى $max محاولات للحصول على أفضل نتيجة';
  }

  @override
  String get startExamNow => 'بدء الامتحان الآن';

  @override
  String get confirmStartTitle => 'تأكيد بدء الامتحان';

  @override
  String get confirmStartMessage =>
      'بمجرد الضغط على \"بدء\"، سيبدأ التوقيت ولا يمكن إيقافه، وسيتم حظر مغادرة الشاشة وإلا سيتم تسليم إجاباتك فوراً. هل أنت جاهز؟';

  @override
  String get loadQuestionsError => 'تعذر تحميل أسئلة الامتحان';

  @override
  String get backLabel => 'العودة';

  @override
  String get monitoringBanner =>
      'مراقبة أمنية: يمنع خروجك أو تصغير الشاشة لعدم التسليم التلقائي!';

  @override
  String questionOf(int questionNumber, int total) {
    return 'سؤال $questionNumber من $total';
  }

  @override
  String get noOptionsAvailable => 'لا توجد إجابات متاحة لهذا السؤال';

  @override
  String get previousQuestion => 'السابق';

  @override
  String get nextQuestion => 'السؤال التالي';

  @override
  String get submitExamLabel => 'تسليم الامتحان';

  @override
  String get writeAnswerHere => 'اكتب إجابتك هنا';

  @override
  String get writeAnswerHint => 'اكتب الإجابة بالتفصيل...';

  @override
  String savedChars(int count) {
    return 'المحفوظ: $count حرف';
  }

  @override
  String get exitBlockedTitle => 'حظر الخروج من الامتحان';

  @override
  String get exitBlockedMessage =>
      'مغادرة شاشة الامتحان الآن ستؤدي إلى التسليم الفوري لكافة إجاباتك الحالية واحتساب الدرجة النهائية. هل ترغب بالتسليم والخروج؟';

  @override
  String get cancelAndContinue => 'إلغاء ومتابعة الحل';

  @override
  String get submitNow => 'تسليم الآن';

  @override
  String get examResultTitle => 'نتيجة الامتحان';

  @override
  String get gradedSaved => 'تم التقييم وحفظ الدرجة';

  @override
  String get gradedSuccess => 'جرى التقييم بنجاح';

  @override
  String get autoSubmitWarning =>
      'تنبيه: تم تسليم الامتحان تلقائياً بسبب مغادرة الشاشة أو تصغير التطبيق أثناء التقييم.';

  @override
  String get timeoutSubmitNote =>
      'تم تسليم الامتحان تلقائياً بانتهاء الوقت المخصص للحل.';

  @override
  String get resultStamp => 'نتيجة';

  @override
  String percentage(String percent) {
    return 'النسبة المئوية: $percent%';
  }

  @override
  String get examPassed => 'مبارك، اجتزت الامتحان بنجاح';

  @override
  String get examFailed => 'لم تتجاوز النسبة المطلوبة';

  @override
  String attemptInfoExhausted(int attempt, int max) {
    return 'هذه المحاولة $attempt من $max — انتهت محاولاتك لهذا الامتحان. يمكنك مراجعة نتائجك في أي وقت.';
  }

  @override
  String attemptInfoRemaining(int attempt, int max, int remaining) {
    return 'هذه المحاولة $attempt من $max — لديك $remaining محاولات متبقية.';
  }

  @override
  String get viewAllResults => 'عرض جميع النتائج';

  @override
  String get backToExams => 'العودة لقائمة الامتحانات';

  @override
  String get examResultsTitle => 'نتائج الامتحان';

  @override
  String get loadResultsError => 'حدث خطأ في تحميل النتائج';

  @override
  String get noAttemptsYet => 'لم تخض أي محاولة في هذا الامتحان بعد';

  @override
  String attemptsCountLabel(int total) {
    return 'عدد المحاولات: $total';
  }

  @override
  String attemptNumber(int index) {
    return 'المحاولة رقم $index';
  }

  @override
  String passedPercent(int percent) {
    return '$percent% ناجح';
  }

  @override
  String get gradeHistoryTitle => 'سجل الدرجات';

  @override
  String get gradeHistorySubtitle => 'نتائج امتحاناتك على صفحات الدفتر';

  @override
  String get loadGradesError => 'حدث خطأ في تحميل الدرجات';

  @override
  String get noGradesYet => 'لا توجد درجات بعد\nقم بحل امتحان لتظهر نتيجتك هنا';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get languageSubtitle => 'لغة عرض الدفتر';

  @override
  String get availableLanguages => 'اللغات المتاحة';

  @override
  String get profileSubtitle => 'بياناتك وإعداداتك';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get notificationSettings => 'إعدادات التنبيهات';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get termsAndPolicies => 'الشروط والأحكام والسياسات';

  @override
  String get supportCenter => 'مركز الدعم والمساعدة';

  @override
  String get supportCenterMessage => 'مركز المساعدة والدعم الفني';

  @override
  String get inviteFriends => 'دعوة الأصدقاء للمنصة';

  @override
  String get inviteLink =>
      'انضم لمنصة الثانوية أونلاين: https://thanaweya-online-website.vercel.app/';

  @override
  String get inviteCopied => 'تم نسخ رابط الدعوة بنجاح';

  @override
  String get logoutConfirmMessage =>
      'هل أنت متأكد أنك تريد تسجيل الخروج من الحساب؟';

  @override
  String get editProfileSubtitle => 'بياناتك على صفحات الدفتر';

  @override
  String get basicData => 'البيانات الأساسية';

  @override
  String get nickName => 'الاسم المستعار';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get studentLabel => 'طالب';

  @override
  String get gender => 'الجنس';

  @override
  String get updateData => 'تحديث البيانات';

  @override
  String get updateDataError => 'حدث خطأ أثناء تحديث البيانات';

  @override
  String get changePasswordSubtitle => 'أدخل كلمة المرور الحالية أولاً';

  @override
  String get passwordSecurityNote =>
      'للحفاظ على أمان حسابك، يجب إدخال كلمة المرور الحالية ثم اختيار كلمة مرور جديدة قوية.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get enterCurrentPassword => 'أدخل كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get passwordMinLength => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get reenterNewPassword => 'أعد إدخال كلمة المرور الجديدة';

  @override
  String get changingPassword => 'جارٍ التغيير...';

  @override
  String get passwordChangedSuccess => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get changePasswordError => 'حدث خطأ أثناء تغيير كلمة المرور';

  @override
  String get notificationsTitle => 'التنبيهات والإشعارات';

  @override
  String get notificationsSubtitle => 'تحكم في تنبيهات دفترك';

  @override
  String get notifSpecialOffers => 'العروض الخاصة';

  @override
  String get notifSounds => 'الأصوات والتنبيهات';

  @override
  String get notifVibration => 'الاهتزاز';

  @override
  String get notifGeneral => 'الإشعارات العامة';

  @override
  String get notifPromotions => 'الخصومات والعروض الترويجية';

  @override
  String get notifPayment => 'معاملات وسائل الدفع';

  @override
  String get notifAppUpdates => 'تحديثات التطبيق';

  @override
  String get notifNewServices => 'الخدمات الجديدة';

  @override
  String get notifTips => 'النصائح والإرشادات';

  @override
  String get commentsTitle => 'التعليقات';

  @override
  String get commentsSubtitle => 'ملاحظات الطلاب على الدرس';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد\nكن أول من يعلق على الدرس';

  @override
  String get commentHint => 'اكتب تعليقاً...';

  @override
  String get userGeneric => 'مستخدم';

  @override
  String get certificateTitle => 'شهادة إتمام';

  @override
  String get certificateSubtitle => 'صفحة التكريم في دفترك';

  @override
  String get courseCompleted => 'إتمام الكورس بنجاح';

  @override
  String get certWitness => 'تشهد منصة الثانوية أونلاين بأن الطالب';

  @override
  String get certCompleted =>
      'قد أتم بنجاح كافة متطلبات واختبارات الكورس التعليمي:';

  @override
  String issueDateLabel(String date) {
    return 'تاريخ الإصدار: $date';
  }

  @override
  String get studentSignature => 'توقيع الطالب';

  @override
  String get platformManager => 'مدير المنصة';

  @override
  String get platformName => 'منصة الثانوية أونلاين';

  @override
  String get downloadCertificate => 'تحميل الشهادة';

  @override
  String get certificateDownloaded => 'تم تحميل الشهادة بنجاح بصيغة PDF';

  @override
  String get enterActivationCodeFirst => 'أدخل كود التفعيل أولاً';

  @override
  String get congratulations => 'تهانينا';

  @override
  String get subscriptionActivated =>
      'تم تفعيل اشتراكك بنجاح.\nيمكنك الآن البدء في دراسة المحاضرات';

  @override
  String get watchLecturesNow => 'مشاهدة المحاضرات الآن';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get subscribeToCourse => 'الاشتراك في الكورس';

  @override
  String get freeCourse => 'كورس مجاني';

  @override
  String get courseSubscription => 'اشتراك كورس';

  @override
  String get activationCodeHint => 'أدخل كود التفعيل الذي حصلت عليه من مدرسك';

  @override
  String get activationCode => 'كود التفعيل';

  @override
  String get codeExample => 'مثال: TH-8921-X90';

  @override
  String get codeNote =>
      'بعد التأكيد سيتم تفعيل اشتراكك فوراً في جميع كورسات المدرس';

  @override
  String get activateSubscriptionSubtitle =>
      'أدخل كود التفعيل للبدء في دراسة الكورس';

  @override
  String get codeTab => 'كود التفعيل';

  @override
  String get electronicPaymentTab => 'الدفع الإلكتروني';

  @override
  String get activatingCode => 'جارٍ تفعيل الكود...';

  @override
  String get processingPayment => 'جارٍ معالجة الدفع...';

  @override
  String get activateAndSubscribe => 'تفعيل الكود والاشتراك الآن';

  @override
  String get confirmPayment => 'تأكيد الدفع والاشتراك الآن';

  @override
  String get paySecurely => 'ادفع بأمان وسهولة عبر الدفع الإلكتروني المباشر';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get visaMastercard => 'بطاقة فيزا / ماستر كارد';

  @override
  String get fawryPayments => 'فوري للمدفوعات';

  @override
  String get cardData => 'بيانات البطاقة';

  @override
  String get cardHolderName => 'اسم صاحب البطاقة';

  @override
  String get cardHolderExample => 'مثال: أحمد محمد علي';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get cvvCode => 'الرمز السري (CVV)';

  @override
  String get payViaFawry => 'الدفع عبر فوري';

  @override
  String get fawryNote =>
      'سيتم إصدار كود دفع فوري مؤقت لإتمام عملية الدفع في أي منفذ فوري.';

  @override
  String get fillCardData => 'يرجى ملء جميع بيانات البطاقة';

  @override
  String get paymentFailed => 'تعذر إتمام الدفع الإلكتروني، حاول مرة أخرى';

  @override
  String get transactionsTitle => 'المعاملات المالية';

  @override
  String get transactionsSubtitle => 'سجل المدفوعات والاشتراكات';

  @override
  String get transactionsLoadError => 'حدث خطأ في تحميل المعاملات';

  @override
  String get transactionsEmpty =>
      'لا توجد معاملات بعد\nستظهر هنا مدفوعاتك عند اشتراكك في الكورسات';

  @override
  String get courseSubscriptionFallback => 'اشتراك كورس';

  @override
  String get electronicPayment => 'دفع إلكتروني';

  @override
  String get teacherActivationCode => 'كود تفعيل من المدرس';

  @override
  String get fawryGateway => 'فوري للمدفوعات';

  @override
  String get creditCardGateway => 'بطاقة ائتمانية';

  @override
  String get freeViaCode => 'مجاناً (كود)';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusFailed => 'فشل';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get receiptTitle => 'إيصال الدفع الإلكتروني';

  @override
  String get receiptSubtitle => 'نسخة من الإيصال على صفحة دفترك';

  @override
  String get shareReceipt => 'مشاركة الإيصال';

  @override
  String get shareAction => 'مشاركة';

  @override
  String get downloadPdf => 'تحميل PDF';

  @override
  String get downloadAction => 'تحميل';

  @override
  String get printReceipt => 'طباعة الإيصال';

  @override
  String get printAction => 'طباعة';

  @override
  String get actionExecuted => 'تم تنفيذ الأمر: ';

  @override
  String get studentNameLabel => 'اسم الطالب';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get courseNameLabel => 'اسم الكورس';

  @override
  String get categoryLabel => 'التصنيف';

  @override
  String get transactionNumberLabel => 'رقم المعاملة';

  @override
  String get transactionIdCopied => 'تم نسخ رقم المعاملة';

  @override
  String get amountPaidLabel => 'المبلغ المدفوع';

  @override
  String get transactionDateLabel => 'تاريخ المعاملة';

  @override
  String get paymentStatusLabel => 'حالة الدفع';

  @override
  String get paidStatus => 'مدفوع';

  @override
  String get egpCurrency => 'ج.م';

  @override
  String get addCardTitle => 'إضافة بطاقة جديدة';

  @override
  String get addCardSubtitle => 'سجّل وسيلة دفع جديدة في دفترك';

  @override
  String get cardDataSection => 'بيانات البطاقة';

  @override
  String get cardHolderNameRequired => 'اسم صاحب البطاقة *';

  @override
  String get cardHolderHint => 'أدخل الاسم المطبوع على البطاقة';

  @override
  String get cardNumberRequired => 'رقم البطاقة *';

  @override
  String get cardNumberHint => '•••• •••• •••• ••••';

  @override
  String get expiryDateRequired => 'تاريخ الانتهاء *';

  @override
  String get cvvRequired => 'رمز الأمان *';

  @override
  String get cvvHint => '•••';

  @override
  String get addCardButton => 'إضافة البطاقة';

  @override
  String get enterCardHolderName => 'يرجى إدخال اسم صاحب البطاقة';

  @override
  String get enterValidCardNumber => 'يرجى إدخال رقم بطاقة صحيح';

  @override
  String get enterValidExpiry => 'يرجى إدخال تاريخ انتهاء صحيح (MM/YY)';

  @override
  String get loginRequiredFirst => 'يجب تسجيل الدخول أولاً';

  @override
  String get cardAddedSuccess => 'تمت إضافة البطاقة بنجاح';

  @override
  String get cardAddError => 'حدث خطأ أثناء إضافة البطاقة، حاول مرة أخرى';

  @override
  String get defaultCardFallback => 'بطاقة مصرفية';

  @override
  String get paymentOptionsTitle => 'خيارات وسائل الدفع';

  @override
  String get paymentOptionsSubtitle => 'بطاقاتك المسجلة في الدفتر';

  @override
  String get noSavedCards => 'لا توجد بطاقات محفوظة بعد';

  @override
  String get defaultCardLabel => 'الافتراضية';

  @override
  String get connectedCardLabel => 'متصلة';

  @override
  String get addNewCardButton => 'إضافة بطاقة جديدة';

  @override
  String get courseLessonsTitle => 'دروس الكورس';

  @override
  String get courseLessonsSubtitle => 'شاهد الحصص واكمل تقدمك';

  @override
  String get lessonNumber => 'الدرس ';

  @override
  String get startFirstLesson => 'ابدأ الدرس الأول';

  @override
  String get lessonLockedTitle => 'الدرس مغلق';

  @override
  String lessonLockedMessage(String lessonTitle) {
    return 'عفواً، المنهج متاح للاطلاع فقط. لمشاهدة فيديو \"$lessonTitle\" يجب الدفع والاشتراك وتفعيل الكود أولاً.';
  }

  @override
  String get payAndActivateCode => 'الدفع وتفعيل الكود';

  @override
  String get termsTitle => 'الشروط والأحكام';

  @override
  String get termsSubtitle => 'قواعد الدفتر والمنصة';

  @override
  String get attendanceTermsTitle => 'شروط الحضور والالتحاق';

  @override
  String get attendanceTermsBody =>
      'تلتزم منصة الثانوية أونلاين بتقديم أفضل المحتويات المعتمدة والدروس التعليمية عالية الجودة. يتعهد الطالب بالحضور والمتابعة المستمرة للحصص والامتحانات المقررة. يمنع منعا باتا مشاركة الحسابات الشخصية أو إعادة بيع المحتوى التعليمي بدون إذن كتابي مسبق.';

  @override
  String get usageTermsTitle => 'شروط الاستخدام والخدمة';

  @override
  String get usageTermsBody =>
      'جميع حقوق الملكية الفكرية والعلامات التجارية والمواد التوضيحية محفوظة لمنصة الثانوية أونلاين والمعلمين المعتمدين. يتم تشفير وسائط الفيديو وحمايتها، وأي محاولة لتسجيل الشاشة أو قرصنة المحتوى تعرض الحساب للحظر النهائي والملاحقة القانونية.';
}
