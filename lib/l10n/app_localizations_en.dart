// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Thanaweya Online';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No data';

  @override
  String get offline => 'No internet connection';

  @override
  String get offlineMessage => 'Check your internet connection and try again';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get passwordTooShort => 'Password is too short';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get invalidOtp => 'Invalid code';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get register => 'Sign Up';

  @override
  String get login => 'Log In';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get parentPhone => 'Parent Phone';

  @override
  String get gradeLevel => 'Grade Level';

  @override
  String get firstStage => 'First Year Secondary';

  @override
  String get secondStage => 'Second Year Secondary';

  @override
  String get thirdStage => 'Third Year Secondary';

  @override
  String get studentRegistration => 'Student Registration';

  @override
  String get signUpSubtitle =>
      'Enter your details to start your student notebook';

  @override
  String get fullNameHint => 'Enter your full name...';

  @override
  String get gradeLevelHint => 'Select your grade level...';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get chooseFromGallerySubtitle =>
      'Pick a clear image saved on your device';

  @override
  String get takePhoto => 'Take a new photo';

  @override
  String get takePhotoSubtitle => 'Use your phone camera for an instant photo';

  @override
  String get chooseProfilePicture => 'Choose a profile picture';

  @override
  String get selectSubjects => 'Select Subjects';

  @override
  String get selectSubjectsSubtitle =>
      'Choose the subjects you will study this year';

  @override
  String get generalSystem => 'General';

  @override
  String get baccalaureateSystem => 'Baccalaureate System';

  @override
  String get loadSubjectsError => 'An error occurred while loading subjects';

  @override
  String get noSubjectsAvailable => 'No subjects available';

  @override
  String nextWithCount(int count) {
    return 'Next ($count)';
  }

  @override
  String get trackMedicine => 'Medicine & Life Sciences Track';

  @override
  String get trackMedicineDesc =>
      'Qualifies for: Medicine, Pharmacy, Dentistry, Physiotherapy, and Nursing.';

  @override
  String get trackEngineering => 'Engineering & Computer Science Track';

  @override
  String get trackEngineeringDesc =>
      'Qualifies for: Engineering, Computer Science, and Biotechnology.';

  @override
  String get trackBusiness => 'Business & Economics Track';

  @override
  String get trackBusinessDesc =>
      'Qualifies for: Commerce, Economics & Political Science, Media, and Law.';

  @override
  String get trackArts => 'Arts & Humanities Track';

  @override
  String get trackArtsDesc =>
      'Qualifies for: Arts, Languages, Fine Arts, and Dar Al Uloom.';

  @override
  String get selectTeachers => 'Select Teachers';

  @override
  String get selectTeachersSubtitle => 'Choose the teachers you want to follow';

  @override
  String get noTeachersAvailable => 'No teachers available';

  @override
  String get settingsSubtitle => 'App and profile settings';

  @override
  String get studentNotebook => 'Student Notebook';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name 👋';
  }

  @override
  String get whatToLearnToday => 'What would you like to learn today?';

  @override
  String get searchPlaceholder => 'Search for a subject, course, or teacher...';

  @override
  String get discountStamp => '25% OFF';

  @override
  String get todaysOffer => 'Today\'s special offer!';

  @override
  String get todaysOfferMessage =>
      'Subscribe now and get a discount on any course for a limited time';

  @override
  String get popularCourses => 'Popular Courses';

  @override
  String get all => 'All';

  @override
  String filteredCourses(int count) {
    return 'Filtered: $count course(s)';
  }

  @override
  String get clear => 'Clear';

  @override
  String get noCoursesMatch =>
      'No courses match your filters — try another subject';

  @override
  String get topTeachers => 'Top Teachers';

  @override
  String get continueCourse => 'Continue Course';

  @override
  String get myCoursesTab => 'My Courses';

  @override
  String get transactionsTab => 'Transactions';

  @override
  String get examsTab => 'Exams';

  @override
  String get profileTab => 'Profile';

  @override
  String get myCoursesTitle => 'My Educational Courses';

  @override
  String get myCoursesSubtitle => 'Your courses on notebook pages';

  @override
  String get searchInCoursesHint => 'Search your courses...';

  @override
  String get completedTab => 'Completed';

  @override
  String get ongoingTab => 'Ongoing';

  @override
  String get noCoursesMatching =>
      'No matching courses — try adjusting the filters';

  @override
  String get noCompletedCourses => 'No completed courses yet';

  @override
  String get videoLesson => 'Lesson Video';

  @override
  String videoOfSubject(String subject) {
    return '$subject Video';
  }

  @override
  String lessonCount(int count) {
    return '$count lessons';
  }

  @override
  String get aboutTab => 'About';

  @override
  String get curriculumTab => 'Curriculum';

  @override
  String get subscribedLabel => 'You are subscribed to this course ✓';

  @override
  String subscribeWithPrice(String price) {
    return 'Subscribe & activate code — $price';
  }

  @override
  String get activateCode => 'Activate subscription code';

  @override
  String get teacherNotFound =>
      'Could not identify the teacher, please try again';

  @override
  String get courseIntroFallback =>
      'This course explains the subject curriculum step by step with problem solutions and comprehensive reviews to help you prepare for the exam.';

  @override
  String get showLess => 'Show less';

  @override
  String get readMore => 'Read more...';

  @override
  String get instructor => 'Instructor';

  @override
  String get teacherRole => 'Teacher';

  @override
  String get whatYouGetTitle => 'What you\'ll learn and get in this course?';

  @override
  String get whatYouGet1 => 'Full access to all course lessons';

  @override
  String get whatYouGet2 => 'Watch on mobile, tablet, and computer';

  @override
  String get whatYouGet3 => 'Summaries and notes for revision';

  @override
  String get whatYouGet4 => 'Quizzes and practice exams';

  @override
  String get whatYouGet5 => 'Track your progress lesson by lesson';

  @override
  String get studentReviewsTitle => 'Student Reviews';

  @override
  String get viewAll => 'View All';

  @override
  String get reviewsAvailableNote =>
      'Student ratings are available on the course page';

  @override
  String get lockedLessonTitle => 'Lesson Locked';

  @override
  String lockedLessonMessage(String title) {
    return 'Sorry, the curriculum is for viewing only. To watch \"$title\" you must pay, subscribe, and activate the code first.';
  }

  @override
  String get payAndActivate => 'Pay & activate code';

  @override
  String get lessonAvailable => 'Lesson available';

  @override
  String get requiresSubscription => 'Requires subscription & payment 🔒';

  @override
  String lessonDurationLocked(String duration) {
    return '$duration · requires subscription & payment 🔒';
  }

  @override
  String get noIntroVideo => 'No intro video';

  @override
  String get courseSectionTitle => 'Course Lessons';

  @override
  String sectionLabel(String number) {
    return 'Section $number';
  }

  @override
  String get curriculumTitle => 'Course Curriculum';

  @override
  String get curriculumSubtitle => 'Your lessons on notebook pages';

  @override
  String get searchLessonHint => 'Search for a lesson or content...';

  @override
  String get noLessonsYet => 'No lessons in this course yet';

  @override
  String get restartCourse => 'Restart Course';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get lessonGeneric => 'Lesson';

  @override
  String get filterResults => 'Filter Results';

  @override
  String get filterSubtitle =>
      'Choose a subject or stage from the notebook pages';

  @override
  String get reset => 'Reset';

  @override
  String get studySubjects => 'Subjects';

  @override
  String get noSubjectsNow => 'No subjects available right now';

  @override
  String get studyStage => 'Study Stage';

  @override
  String get showAllCourses => 'Show All Courses';

  @override
  String applyFilter(int count) {
    return 'Apply Filter ($count)';
  }

  @override
  String get watchingLesson => 'Watching Lesson';

  @override
  String get lessonHandout => 'Lesson Handout';

  @override
  String get noHandoutYet => 'No handout attached to this lesson yet';

  @override
  String get tapToOpen => 'Tap to open the file';

  @override
  String get lessonExam => 'Lesson Exam';

  @override
  String get noLessonExam => 'No exam assigned to this lesson';

  @override
  String get attemptsExhausted => 'Attempts exhausted';

  @override
  String examMeta(int duration, int used, int max) {
    return '$duration min · Attempts $used/$max';
  }

  @override
  String get contentLockedTitle => 'Content Locked';

  @override
  String get lockedContentMessage =>
      'This session is available only to subscribed students. Please activate a subscription code or subscribe for full video access.';

  @override
  String get videoViewsExhaustedTitle => 'Video views exhausted';

  @override
  String get videoViewsExhaustedMessage =>
      'You have used up the allowed number of views for this video. Contact your teacher to reopen it.';

  @override
  String get ok => 'OK';

  @override
  String get couldNotOpenFile => 'Could not open the file';

  @override
  String get videoLockedForSubscribers =>
      'This video is locked for subscribers only';

  @override
  String get videoLockedSubMessage =>
      'Subscribe to the course and activate the subscription code to watch all videos';

  @override
  String get viewsExhaustedOverlay => 'This video\'s views are exhausted';

  @override
  String viewsCountMessage(int viewCount, int maxViews) {
    return '$viewCount of $maxViews views used · Contact your teacher to reopen it';
  }

  @override
  String get teacherPageFallback => 'Teacher Page';

  @override
  String get teacherPageSubtitle =>
      'Teacher profile, contact info, and centers';

  @override
  String get verifiedTeacher => 'Verified teacher on Thanaweya Online';

  @override
  String whatsappMessage(String teacherName) {
    return 'Hello Mr./Ms. $teacherName, I would like to ask about your lessons and educational centers from the Thanaweya Online app.';
  }

  @override
  String get whatsappOpenFailed =>
      'Could not open WhatsApp, please make sure the app is installed';

  @override
  String get quickContact => 'Quick Contact';

  @override
  String get quickContactMessage =>
      'You can contact the teacher directly to ask about centers, schedules, or any other study details.';

  @override
  String get contactOnWhatsapp => 'Contact via WhatsApp';

  @override
  String get bioLabel => 'About';

  @override
  String get noBio => 'No bio is available for this teacher yet.';

  @override
  String get teachingPlaceTitle => 'Teaching Location & Method';

  @override
  String get teachingMethod => 'Teaching Method';

  @override
  String get centerLocation => 'Center Location';

  @override
  String locatedInGovernorate(String governorate) {
    return 'Located in centers in $governorate governorate';
  }

  @override
  String get academicTitle => 'Grades & Systems';

  @override
  String get subjectField => 'Subject';

  @override
  String get gradeField => 'Grades';

  @override
  String get systemField => 'System';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get generalSecondary => 'General Secondary';

  @override
  String get azhariSecondary => 'Al-Azhar Secondary';

  @override
  String get stemSchools => 'STEM Schools';

  @override
  String get modeOnline => 'Online (through the platform only)';

  @override
  String get modeCenter => 'In-person at the center only';

  @override
  String get modeBoth => 'Online and through educational centers';

  @override
  String get modeOnlineShort => 'Online';

  @override
  String get teacherInfoLoadError => 'Could not load teacher info';

  @override
  String get bookmarksTitle => 'My Bookmarks';

  @override
  String get bookmarksSubtitle => 'Courses you saved for review';

  @override
  String get loadBookmarksError => 'An error occurred loading your bookmarks';

  @override
  String get noBookmarks =>
      'No bookmarks yet\nTap the save icon to add courses here';

  @override
  String get remove => 'Remove';

  @override
  String get reviewsSubtitle => 'Real reviews on notebook pages';

  @override
  String basedOnReviews(int count) {
    return 'Based on $count student review(s)';
  }

  @override
  String get excellent => 'Excellent';

  @override
  String get veryGood => 'Very Good';

  @override
  String get average => 'Average';

  @override
  String get noReviewsYet =>
      'No reviews yet — be the first to review this course';

  @override
  String get addYourReview => 'Add Your Review';

  @override
  String get writeReviewTitle => 'Write a Review';

  @override
  String get writeReviewSubtitle => 'Write your opinion in your own hand';

  @override
  String get reviewHelpsOthers =>
      'Your review helps classmates choose the right course';

  @override
  String get yourRatingQuestion => 'What\'s your rating for this course?';

  @override
  String get detailedReviewTitle => 'Write your detailed review';

  @override
  String get reviewHint =>
      'What was your experience with this course and teacher? Share your opinion to help other students...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get mustLoginFirst => 'You must log in first';

  @override
  String get reviewSubmitted => 'Your review was submitted successfully';

  @override
  String get reviewSubmitError =>
      'An error occurred while submitting your review, please try again';

  @override
  String get examProgressTitle => 'Progress & Exams';

  @override
  String get examProgressSubtitle =>
      'Test what you\'ve studied on your notebook pages';

  @override
  String get loadExamsError => 'An error occurred loading exams';

  @override
  String get noExamsAvailable =>
      'No exams available right now\nYour exams will appear here when teachers add them';

  @override
  String get examAttemptsExhaustedTitle => 'Exam attempts exhausted';

  @override
  String examAttemptsExhaustedMessage(int max) {
    return 'You have used up the allowed attempts for this exam ($max attempts). You can view your results or contact the teacher to reopen the exam.';
  }

  @override
  String get viewResults => 'View Results';

  @override
  String examDurationLabel(int duration) {
    return 'Exam duration: $duration minutes';
  }

  @override
  String attemptsCount(int used, int max) {
    return 'Attempts: $used/$max';
  }

  @override
  String get resultsLabel => 'Results';

  @override
  String get lockedLabel => 'Locked';

  @override
  String get enterExam => 'Enter Exam';

  @override
  String get anotherAttempt => 'Another Attempt';

  @override
  String get comprehensiveExam => 'Comprehensive Exam';

  @override
  String durationMinutes(int min) {
    return '$min minutes';
  }

  @override
  String totalMarks(String marks) {
    return '$marks marks';
  }

  @override
  String get examInstructionsTitle => 'Exam Instructions & Rules';

  @override
  String get examInstructionsSubtitle => 'Read the rules before starting';

  @override
  String responsibleTeacher(String name) {
    return 'Responsible teacher: $name';
  }

  @override
  String get durationStat => 'Duration';

  @override
  String get questionCountStat => 'Questions';

  @override
  String get totalScoreStat => 'Total Score';

  @override
  String get examRulesTitle => 'Exam Rules & Regulations';

  @override
  String get strictRulesNote =>
      'Strict rules, reading is mandatory before starting';

  @override
  String get ruleTimingTitle => 'Precise timing';

  @override
  String get ruleTimingDesc =>
      'The timer starts as soon as you enter the exam, and answers are submitted automatically when time runs out.';

  @override
  String get ruleNoExitTitle => 'No leaving the screen (auto-submit)';

  @override
  String get ruleNoExitDesc =>
      'If you leave the app, minimize the screen, or switch to another app, the exam will be submitted immediately and graded only on what you answered!';

  @override
  String get ruleConnectionTitle => 'Keep a stable connection';

  @override
  String get ruleConnectionDesc =>
      'Make sure your phone is charged and your internet connection is stable before starting.';

  @override
  String get attemptsFinished => 'Allowed attempts exhausted';

  @override
  String remainingAttempts(int remaining, int max) {
    return 'Remaining attempts: $remaining of $max';
  }

  @override
  String get attemptsFinishedMessage =>
      'You can contact the teacher to reopen the exam, or view your results';

  @override
  String retakeMessage(int max) {
    return 'You can retake the exam up to $max attempts to get the best result';
  }

  @override
  String get startExamNow => 'Start Exam Now';

  @override
  String get confirmStartTitle => 'Confirm Start';

  @override
  String get confirmStartMessage =>
      'Once you press \"Start\", the timer begins and cannot be stopped, and leaving the screen is blocked otherwise your answers will be submitted immediately. Are you ready?';

  @override
  String get loadQuestionsError => 'Could not load exam questions';

  @override
  String get backLabel => 'Back';

  @override
  String get monitoringBanner =>
      'Security monitoring: leaving or minimizing the screen causes auto-submission!';

  @override
  String questionOf(int questionNumber, int total) {
    return 'Question $questionNumber of $total';
  }

  @override
  String get noOptionsAvailable => 'No answers available for this question';

  @override
  String get previousQuestion => 'Previous';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get submitExamLabel => 'Submit Exam';

  @override
  String get writeAnswerHere => 'Write your answer here';

  @override
  String get writeAnswerHint => 'Write your detailed answer...';

  @override
  String savedChars(int count) {
    return 'Saved: $count characters';
  }

  @override
  String get exitBlockedTitle => 'Leaving the exam is blocked';

  @override
  String get exitBlockedMessage =>
      'Leaving the exam screen now will immediately submit all your current answers and calculate the final grade. Do you want to submit and exit?';

  @override
  String get cancelAndContinue => 'Cancel and continue';

  @override
  String get submitNow => 'Submit Now';

  @override
  String get examResultTitle => 'Exam Result';

  @override
  String get gradedSaved => 'Graded and saved';

  @override
  String get gradedSuccess => 'Graded successfully';

  @override
  String get autoSubmitWarning =>
      'Note: The exam was submitted automatically because you left the screen or minimized the app during the assessment.';

  @override
  String get timeoutSubmitNote =>
      'The exam was submitted automatically when the allotted time ran out.';

  @override
  String get resultStamp => 'Result';

  @override
  String percentage(String percent) {
    return 'Percentage: $percent%';
  }

  @override
  String get examPassed => 'Congratulations, you passed the exam';

  @override
  String get examFailed => 'You did not reach the required percentage';

  @override
  String attemptInfoExhausted(int attempt, int max) {
    return 'This is attempt $attempt of $max — you have used all attempts for this exam. You can review your results anytime.';
  }

  @override
  String attemptInfoRemaining(int attempt, int max, int remaining) {
    return 'This is attempt $attempt of $max — you have $remaining attempts left.';
  }

  @override
  String get viewAllResults => 'View All Results';

  @override
  String get backToExams => 'Back to Exams List';

  @override
  String get examResultsTitle => 'Exam Results';

  @override
  String get loadResultsError => 'An error occurred loading results';

  @override
  String get noAttemptsYet =>
      'You haven\'t taken any attempts in this exam yet';

  @override
  String attemptsCountLabel(int total) {
    return 'Number of attempts: $total';
  }

  @override
  String attemptNumber(int index) {
    return 'Attempt #$index';
  }

  @override
  String passedPercent(int percent) {
    return '$percent% Passed';
  }

  @override
  String get gradeHistoryTitle => 'Grade History';

  @override
  String get gradeHistorySubtitle => 'Your exam results on notebook pages';

  @override
  String get loadGradesError => 'An error occurred loading grades';

  @override
  String get noGradesYet =>
      'No grades yet\nTake an exam to see your result here';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get languageSubtitle => 'Notebook display language';

  @override
  String get availableLanguages => 'Available Languages';

  @override
  String get profileSubtitle => 'Your data and settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get changePassword => 'Change Password';

  @override
  String get appLanguage => 'App Language';

  @override
  String get termsAndPolicies => 'Terms & Policies';

  @override
  String get supportCenter => 'Support & Help Center';

  @override
  String get supportCenterMessage => 'Help & technical support center';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String get inviteLink =>
      'Join Thanaweya Online: https://thanaweya.online/invite';

  @override
  String get inviteCopied => 'Invite link copied successfully';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get editProfileSubtitle => 'Your data on notebook pages';

  @override
  String get basicData => 'Basic Info';

  @override
  String get nickName => 'Nickname';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get accountType => 'Account Type';

  @override
  String get studentLabel => 'Student';

  @override
  String get gender => 'Gender';

  @override
  String get updateData => 'Update Data';

  @override
  String get updateDataError => 'An error occurred while updating your data';

  @override
  String get changePasswordSubtitle => 'Enter your current password first';

  @override
  String get passwordSecurityNote =>
      'To keep your account secure, enter your current password then choose a strong new one.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get reenterNewPassword => 'Re-enter your new password';

  @override
  String get changingPassword => 'Changing...';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get changePasswordError =>
      'An error occurred while changing the password';

  @override
  String get notificationsTitle => 'Notifications & Alerts';

  @override
  String get notificationsSubtitle => 'Control your notebook alerts';

  @override
  String get notifSpecialOffers => 'Special Offers';

  @override
  String get notifSounds => 'Sounds & Alerts';

  @override
  String get notifVibration => 'Vibration';

  @override
  String get notifGeneral => 'General Notifications';

  @override
  String get notifPromotions => 'Discounts & Promotions';

  @override
  String get notifPayment => 'Payment Transactions';

  @override
  String get notifAppUpdates => 'App Updates';

  @override
  String get notifNewServices => 'New Services';

  @override
  String get notifTips => 'Tips & Guidance';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsSubtitle => 'Student notes on the lesson';

  @override
  String get noCommentsYet =>
      'No comments yet\nBe the first to comment on the lesson';

  @override
  String get commentHint => 'Write a comment...';

  @override
  String get userGeneric => 'User';

  @override
  String get certificateTitle => 'Completion Certificate';

  @override
  String get certificateSubtitle => 'Your honor page in the notebook';

  @override
  String get courseCompleted => 'Course Completed Successfully';

  @override
  String get certWitness => 'Thanaweya Online certifies that the student';

  @override
  String get certCompleted =>
      'has successfully completed all requirements and tests of the educational course:';

  @override
  String issueDateLabel(String date) {
    return 'Issue date: $date';
  }

  @override
  String get studentSignature => 'Student Signature';

  @override
  String get platformManager => 'Platform Manager';

  @override
  String get platformName => 'Thanaweya Online';

  @override
  String get downloadCertificate => 'Download Certificate';

  @override
  String get certificateDownloaded =>
      'Certificate downloaded successfully as PDF';

  @override
  String get enterActivationCodeFirst => 'Enter the activation code first';

  @override
  String get congratulations => 'Congratulations';

  @override
  String get subscriptionActivated =>
      'Your subscription was activated successfully.\nYou can now start studying the lectures';

  @override
  String get watchLecturesNow => 'Watch Lectures Now';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get subscribeToCourse => 'Subscribe to Course';

  @override
  String get freeCourse => 'Free Course';

  @override
  String get courseSubscription => 'Course Subscription';

  @override
  String get activationCodeHint =>
      'Enter the activation code you received from your teacher';

  @override
  String get activationCode => 'Activation Code';

  @override
  String get codeExample => 'Example: TH-8921-X90';

  @override
  String get codeNote =>
      'Once confirmed, your subscription will be activated immediately for all of the teacher\'s courses';

  @override
  String get activateSubscriptionSubtitle =>
      'Enter the activation code to start studying the course';

  @override
  String get codeTab => 'Activation Code';

  @override
  String get electronicPaymentTab => 'Electronic Payment';

  @override
  String get activatingCode => 'Activating code...';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get activateAndSubscribe => 'Activate Code & Subscribe Now';

  @override
  String get confirmPayment => 'Confirm Payment & Subscribe Now';

  @override
  String get paySecurely =>
      'Pay securely and easily via direct electronic payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get visaMastercard => 'Visa / Mastercard';

  @override
  String get fawryPayments => 'Fawry Payments';

  @override
  String get cardData => 'Card Details';

  @override
  String get cardHolderName => 'Cardholder Name';

  @override
  String get cardHolderExample => 'Example: Ahmed Mohamed Ali';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvvCode => 'Security Code (CVV)';

  @override
  String get payViaFawry => 'Pay via Fawry';

  @override
  String get fawryNote =>
      'A temporary Fawry payment code will be issued to complete the payment at any Fawry outlet.';

  @override
  String get fillCardData => 'Please fill in all card details';

  @override
  String get paymentFailed =>
      'Could not complete the electronic payment, please try again';

  @override
  String get transactionsTitle => 'Financial Transactions';

  @override
  String get transactionsSubtitle => 'Payments and subscriptions record';

  @override
  String get transactionsLoadError =>
      'An error occurred while loading transactions';

  @override
  String get transactionsEmpty =>
      'No transactions yet\nYour payments will appear here when you subscribe to courses';

  @override
  String get courseSubscriptionFallback => 'Course subscription';

  @override
  String get electronicPayment => 'Electronic payment';

  @override
  String get teacherActivationCode => 'Teacher activation code';

  @override
  String get fawryGateway => 'Fawry payments';

  @override
  String get creditCardGateway => 'Credit card';

  @override
  String get freeViaCode => 'Free (code)';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusPaid => 'Paid';

  @override
  String get receiptTitle => 'Electronic Payment Receipt';

  @override
  String get receiptSubtitle => 'A copy of the receipt on your notebook page';

  @override
  String get shareReceipt => 'Share receipt';

  @override
  String get shareAction => 'Share';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get downloadAction => 'Download';

  @override
  String get printReceipt => 'Print receipt';

  @override
  String get printAction => 'Print';

  @override
  String get actionExecuted => 'Action executed: ';

  @override
  String get studentNameLabel => 'Student Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get courseNameLabel => 'Course Name';

  @override
  String get categoryLabel => 'Category';

  @override
  String get transactionNumberLabel => 'Transaction Number';

  @override
  String get transactionIdCopied => 'Transaction number copied';

  @override
  String get amountPaidLabel => 'Amount Paid';

  @override
  String get transactionDateLabel => 'Transaction Date';

  @override
  String get paymentStatusLabel => 'Payment Status';

  @override
  String get paidStatus => 'Paid';

  @override
  String get egpCurrency => 'EGP';

  @override
  String get addCardTitle => 'Add New Card';

  @override
  String get addCardSubtitle =>
      'Register a new payment method in your notebook';

  @override
  String get cardDataSection => 'Card Details';

  @override
  String get cardHolderNameRequired => 'Cardholder Name *';

  @override
  String get cardHolderHint => 'Enter the name printed on the card';

  @override
  String get cardNumberRequired => 'Card Number *';

  @override
  String get cardNumberHint => '•••• •••• •••• ••••';

  @override
  String get expiryDateRequired => 'Expiry Date *';

  @override
  String get cvvRequired => 'Security Code *';

  @override
  String get cvvHint => '•••';

  @override
  String get addCardButton => 'Add Card';

  @override
  String get enterCardHolderName => 'Please enter the cardholder name';

  @override
  String get enterValidCardNumber => 'Please enter a valid card number';

  @override
  String get enterValidExpiry => 'Please enter a valid expiry date (MM/YY)';

  @override
  String get loginRequiredFirst => 'You must log in first';

  @override
  String get cardAddedSuccess => 'Card added successfully';

  @override
  String get cardAddError =>
      'An error occurred while adding the card, please try again';

  @override
  String get defaultCardFallback => 'Bank card';

  @override
  String get paymentOptionsTitle => 'Payment Methods Options';

  @override
  String get paymentOptionsSubtitle => 'Your saved cards in the notebook';

  @override
  String get noSavedCards => 'No saved cards yet';

  @override
  String get defaultCardLabel => 'Default';

  @override
  String get connectedCardLabel => 'Connected';

  @override
  String get addNewCardButton => 'Add New Card';

  @override
  String get courseLessonsTitle => 'Course Lessons';

  @override
  String get courseLessonsSubtitle =>
      'Watch the sessions and continue your progress';

  @override
  String get lessonNumber => 'Lesson ';

  @override
  String get startFirstLesson => 'Start First Lesson';

  @override
  String get lessonLockedTitle => 'Lesson Locked';

  @override
  String lessonLockedMessage(String lessonTitle) {
    return 'Sorry, the curriculum is available for viewing only. To watch the video \"$lessonTitle\" you must pay, subscribe and activate the code first.';
  }

  @override
  String get payAndActivateCode => 'Pay & Activate Code';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsSubtitle => 'Notebook and platform rules';

  @override
  String get attendanceTermsTitle => 'Attendance & Enrollment Terms';

  @override
  String get attendanceTermsBody =>
      'Thanaweya Online platform is committed to providing the best approved content and high-quality educational lessons. The student undertakes to attend and continuously follow up on scheduled sessions and exams. Sharing personal accounts or reselling educational content without prior written permission is strictly prohibited.';

  @override
  String get usageTermsTitle => 'Usage & Service Terms';

  @override
  String get usageTermsBody =>
      'All intellectual property rights, trademarks and illustrative materials are reserved to Thanaweya Online platform and certified teachers. Video media is encrypted and protected, and any attempt to record the screen or hack the content subjects the account to permanent ban and legal prosecution.';
}
