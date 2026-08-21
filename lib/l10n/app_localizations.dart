import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Thanaweya Online'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offline;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again'**
  String get offlineMessage;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidOtp;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @parentPhone.
  ///
  /// In en, this message translates to:
  /// **'Parent Phone'**
  String get parentPhone;

  /// No description provided for @gradeLevel.
  ///
  /// In en, this message translates to:
  /// **'Grade Level'**
  String get gradeLevel;

  /// No description provided for @firstStage.
  ///
  /// In en, this message translates to:
  /// **'First Year Secondary'**
  String get firstStage;

  /// No description provided for @secondStage.
  ///
  /// In en, this message translates to:
  /// **'Second Year Secondary'**
  String get secondStage;

  /// No description provided for @thirdStage.
  ///
  /// In en, this message translates to:
  /// **'Third Year Secondary'**
  String get thirdStage;

  /// No description provided for @studentRegistration.
  ///
  /// In en, this message translates to:
  /// **'Student Registration'**
  String get studentRegistration;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to start your student notebook'**
  String get signUpSubtitle;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name...'**
  String get fullNameHint;

  /// No description provided for @gradeLevelHint.
  ///
  /// In en, this message translates to:
  /// **'Select your grade level...'**
  String get gradeLevelHint;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creatingAccount;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseFromGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a clear image saved on your device'**
  String get chooseFromGallerySubtitle;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get takePhoto;

  /// No description provided for @takePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your phone camera for an instant photo'**
  String get takePhotoSubtitle;

  /// No description provided for @chooseProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile picture'**
  String get chooseProfilePicture;

  /// No description provided for @selectSubjects.
  ///
  /// In en, this message translates to:
  /// **'Select Subjects'**
  String get selectSubjects;

  /// No description provided for @selectSubjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the subjects you will study this year'**
  String get selectSubjectsSubtitle;

  /// No description provided for @generalSystem.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSystem;

  /// No description provided for @baccalaureateSystem.
  ///
  /// In en, this message translates to:
  /// **'Baccalaureate System'**
  String get baccalaureateSystem;

  /// No description provided for @loadSubjectsError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading subjects'**
  String get loadSubjectsError;

  /// No description provided for @noSubjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subjects available'**
  String get noSubjectsAvailable;

  /// No description provided for @nextWithCount.
  ///
  /// In en, this message translates to:
  /// **'Next ({count})'**
  String nextWithCount(int count);

  /// No description provided for @trackMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine & Life Sciences Track'**
  String get trackMedicine;

  /// No description provided for @trackMedicineDesc.
  ///
  /// In en, this message translates to:
  /// **'Qualifies for: Medicine, Pharmacy, Dentistry, Physiotherapy, and Nursing.'**
  String get trackMedicineDesc;

  /// No description provided for @trackEngineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering & Computer Science Track'**
  String get trackEngineering;

  /// No description provided for @trackEngineeringDesc.
  ///
  /// In en, this message translates to:
  /// **'Qualifies for: Engineering, Computer Science, and Biotechnology.'**
  String get trackEngineeringDesc;

  /// No description provided for @trackBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business & Economics Track'**
  String get trackBusiness;

  /// No description provided for @trackBusinessDesc.
  ///
  /// In en, this message translates to:
  /// **'Qualifies for: Commerce, Economics & Political Science, Media, and Law.'**
  String get trackBusinessDesc;

  /// No description provided for @trackArts.
  ///
  /// In en, this message translates to:
  /// **'Arts & Humanities Track'**
  String get trackArts;

  /// No description provided for @trackArtsDesc.
  ///
  /// In en, this message translates to:
  /// **'Qualifies for: Arts, Languages, Fine Arts, and Dar Al Uloom.'**
  String get trackArtsDesc;

  /// No description provided for @selectTeachers.
  ///
  /// In en, this message translates to:
  /// **'Select Teachers'**
  String get selectTeachers;

  /// No description provided for @selectTeachersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the teachers you want to follow'**
  String get selectTeachersSubtitle;

  /// No description provided for @noTeachersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No teachers available'**
  String get noTeachersAvailable;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App and profile settings'**
  String get settingsSubtitle;

  /// No description provided for @studentNotebook.
  ///
  /// In en, this message translates to:
  /// **'Student Notebook'**
  String get studentNotebook;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name} 👋'**
  String welcomeBack(String name);

  /// No description provided for @whatToLearnToday.
  ///
  /// In en, this message translates to:
  /// **'What would you like to learn today?'**
  String get whatToLearnToday;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a subject, course, or teacher...'**
  String get searchPlaceholder;

  /// No description provided for @discountStamp.
  ///
  /// In en, this message translates to:
  /// **'25% OFF'**
  String get discountStamp;

  /// No description provided for @todaysOffer.
  ///
  /// In en, this message translates to:
  /// **'Today\'s special offer!'**
  String get todaysOffer;

  /// No description provided for @todaysOfferMessage.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now and get a discount on any course for a limited time'**
  String get todaysOfferMessage;

  /// No description provided for @popularCourses.
  ///
  /// In en, this message translates to:
  /// **'Popular Courses'**
  String get popularCourses;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filteredCourses.
  ///
  /// In en, this message translates to:
  /// **'Filtered: {count} course(s)'**
  String filteredCourses(int count);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noCoursesMatch.
  ///
  /// In en, this message translates to:
  /// **'No courses match your filters — try another subject'**
  String get noCoursesMatch;

  /// No description provided for @topTeachers.
  ///
  /// In en, this message translates to:
  /// **'Top Teachers'**
  String get topTeachers;

  /// No description provided for @continueCourse.
  ///
  /// In en, this message translates to:
  /// **'Continue Course'**
  String get continueCourse;

  /// No description provided for @myCoursesTab.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCoursesTab;

  /// No description provided for @transactionsTab.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTab;

  /// No description provided for @examsTab.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get examsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @myCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Educational Courses'**
  String get myCoursesTitle;

  /// No description provided for @myCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your courses on notebook pages'**
  String get myCoursesSubtitle;

  /// No description provided for @searchInCoursesHint.
  ///
  /// In en, this message translates to:
  /// **'Search your courses...'**
  String get searchInCoursesHint;

  /// No description provided for @completedTab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTab;

  /// No description provided for @ongoingTab.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoingTab;

  /// No description provided for @noCoursesMatching.
  ///
  /// In en, this message translates to:
  /// **'No matching courses — try adjusting the filters'**
  String get noCoursesMatching;

  /// No description provided for @noCompletedCourses.
  ///
  /// In en, this message translates to:
  /// **'No completed courses yet'**
  String get noCompletedCourses;

  /// No description provided for @videoLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson Video'**
  String get videoLesson;

  /// No description provided for @videoOfSubject.
  ///
  /// In en, this message translates to:
  /// **'{subject} Video'**
  String videoOfSubject(String subject);

  /// No description provided for @lessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String lessonCount(int count);

  /// No description provided for @aboutTab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTab;

  /// No description provided for @curriculumTab.
  ///
  /// In en, this message translates to:
  /// **'Curriculum'**
  String get curriculumTab;

  /// No description provided for @subscribedLabel.
  ///
  /// In en, this message translates to:
  /// **'You are subscribed to this course ✓'**
  String get subscribedLabel;

  /// No description provided for @subscribeWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Subscribe & activate code — {price}'**
  String subscribeWithPrice(String price);

  /// No description provided for @activateCode.
  ///
  /// In en, this message translates to:
  /// **'Activate subscription code'**
  String get activateCode;

  /// No description provided for @teacherNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not identify the teacher, please try again'**
  String get teacherNotFound;

  /// No description provided for @courseIntroFallback.
  ///
  /// In en, this message translates to:
  /// **'This course explains the subject curriculum step by step with problem solutions and comprehensive reviews to help you prepare for the exam.'**
  String get courseIntroFallback;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more...'**
  String get readMore;

  /// No description provided for @instructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// No description provided for @teacherRole.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacherRole;

  /// No description provided for @whatYouGetTitle.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll learn and get in this course?'**
  String get whatYouGetTitle;

  /// No description provided for @whatYouGet1.
  ///
  /// In en, this message translates to:
  /// **'Full access to all course lessons'**
  String get whatYouGet1;

  /// No description provided for @whatYouGet2.
  ///
  /// In en, this message translates to:
  /// **'Watch on mobile, tablet, and computer'**
  String get whatYouGet2;

  /// No description provided for @whatYouGet3.
  ///
  /// In en, this message translates to:
  /// **'Summaries and notes for revision'**
  String get whatYouGet3;

  /// No description provided for @whatYouGet4.
  ///
  /// In en, this message translates to:
  /// **'Quizzes and practice exams'**
  String get whatYouGet4;

  /// No description provided for @whatYouGet5.
  ///
  /// In en, this message translates to:
  /// **'Track your progress lesson by lesson'**
  String get whatYouGet5;

  /// No description provided for @studentReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Reviews'**
  String get studentReviewsTitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @reviewsAvailableNote.
  ///
  /// In en, this message translates to:
  /// **'Student ratings are available on the course page'**
  String get reviewsAvailableNote;

  /// No description provided for @lockedLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Locked'**
  String get lockedLessonTitle;

  /// No description provided for @lockedLessonMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the curriculum is for viewing only. To watch \"{title}\" you must pay, subscribe, and activate the code first.'**
  String lockedLessonMessage(String title);

  /// No description provided for @payAndActivate.
  ///
  /// In en, this message translates to:
  /// **'Pay & activate code'**
  String get payAndActivate;

  /// No description provided for @lessonAvailable.
  ///
  /// In en, this message translates to:
  /// **'Lesson available'**
  String get lessonAvailable;

  /// No description provided for @requiresSubscription.
  ///
  /// In en, this message translates to:
  /// **'Requires subscription & payment 🔒'**
  String get requiresSubscription;

  /// No description provided for @lessonDurationLocked.
  ///
  /// In en, this message translates to:
  /// **'{duration} · requires subscription & payment 🔒'**
  String lessonDurationLocked(String duration);

  /// No description provided for @noIntroVideo.
  ///
  /// In en, this message translates to:
  /// **'No intro video'**
  String get noIntroVideo;

  /// No description provided for @courseSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Lessons'**
  String get courseSectionTitle;

  /// No description provided for @sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Section {number}'**
  String sectionLabel(String number);

  /// No description provided for @curriculumTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Curriculum'**
  String get curriculumTitle;

  /// No description provided for @curriculumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your lessons on notebook pages'**
  String get curriculumSubtitle;

  /// No description provided for @searchLessonHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a lesson or content...'**
  String get searchLessonHint;

  /// No description provided for @noLessonsYet.
  ///
  /// In en, this message translates to:
  /// **'No lessons in this course yet'**
  String get noLessonsYet;

  /// No description provided for @restartCourse.
  ///
  /// In en, this message translates to:
  /// **'Restart Course'**
  String get restartCourse;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @lessonGeneric.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lessonGeneric;

  /// No description provided for @filterResults.
  ///
  /// In en, this message translates to:
  /// **'Filter Results'**
  String get filterResults;

  /// No description provided for @filterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a subject or stage from the notebook pages'**
  String get filterSubtitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @studySubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get studySubjects;

  /// No description provided for @noSubjectsNow.
  ///
  /// In en, this message translates to:
  /// **'No subjects available right now'**
  String get noSubjectsNow;

  /// No description provided for @studyStage.
  ///
  /// In en, this message translates to:
  /// **'Study Stage'**
  String get studyStage;

  /// No description provided for @showAllCourses.
  ///
  /// In en, this message translates to:
  /// **'Show All Courses'**
  String get showAllCourses;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter ({count})'**
  String applyFilter(int count);

  /// No description provided for @watchingLesson.
  ///
  /// In en, this message translates to:
  /// **'Watching Lesson'**
  String get watchingLesson;

  /// No description provided for @lessonHandout.
  ///
  /// In en, this message translates to:
  /// **'Lesson Handout'**
  String get lessonHandout;

  /// No description provided for @noHandoutYet.
  ///
  /// In en, this message translates to:
  /// **'No handout attached to this lesson yet'**
  String get noHandoutYet;

  /// No description provided for @tapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open the file'**
  String get tapToOpen;

  /// No description provided for @lessonExam.
  ///
  /// In en, this message translates to:
  /// **'Lesson Exam'**
  String get lessonExam;

  /// No description provided for @noLessonExam.
  ///
  /// In en, this message translates to:
  /// **'No exam assigned to this lesson'**
  String get noLessonExam;

  /// No description provided for @attemptsExhausted.
  ///
  /// In en, this message translates to:
  /// **'Attempts exhausted'**
  String get attemptsExhausted;

  /// No description provided for @examMeta.
  ///
  /// In en, this message translates to:
  /// **'{duration} min · Attempts {used}/{max}'**
  String examMeta(int duration, int used, int max);

  /// No description provided for @contentLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Locked'**
  String get contentLockedTitle;

  /// No description provided for @lockedContentMessage.
  ///
  /// In en, this message translates to:
  /// **'This session is available only to subscribed students. Please activate a subscription code or subscribe for full video access.'**
  String get lockedContentMessage;

  /// No description provided for @videoViewsExhaustedTitle.
  ///
  /// In en, this message translates to:
  /// **'Video views exhausted'**
  String get videoViewsExhaustedTitle;

  /// No description provided for @videoViewsExhaustedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used up the allowed number of views for this video. Contact your teacher to reopen it.'**
  String get videoViewsExhaustedMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file'**
  String get couldNotOpenFile;

  /// No description provided for @videoLockedForSubscribers.
  ///
  /// In en, this message translates to:
  /// **'This video is locked for subscribers only'**
  String get videoLockedForSubscribers;

  /// No description provided for @videoLockedSubMessage.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to the course and activate the subscription code to watch all videos'**
  String get videoLockedSubMessage;

  /// No description provided for @viewsExhaustedOverlay.
  ///
  /// In en, this message translates to:
  /// **'This video\'s views are exhausted'**
  String get viewsExhaustedOverlay;

  /// No description provided for @viewsCountMessage.
  ///
  /// In en, this message translates to:
  /// **'{viewCount} of {maxViews} views used · Contact your teacher to reopen it'**
  String viewsCountMessage(int viewCount, int maxViews);

  /// No description provided for @teacherPageFallback.
  ///
  /// In en, this message translates to:
  /// **'Teacher Page'**
  String get teacherPageFallback;

  /// No description provided for @teacherPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher profile, contact info, and centers'**
  String get teacherPageSubtitle;

  /// No description provided for @verifiedTeacher.
  ///
  /// In en, this message translates to:
  /// **'Verified teacher on Thanaweya Online'**
  String get verifiedTeacher;

  /// No description provided for @whatsappMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello Mr./Ms. {teacherName}, I would like to ask about your lessons and educational centers from the Thanaweya Online app.'**
  String whatsappMessage(String teacherName);

  /// No description provided for @whatsappOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp, please make sure the app is installed'**
  String get whatsappOpenFailed;

  /// No description provided for @quickContact.
  ///
  /// In en, this message translates to:
  /// **'Quick Contact'**
  String get quickContact;

  /// No description provided for @quickContactMessage.
  ///
  /// In en, this message translates to:
  /// **'You can contact the teacher directly to ask about centers, schedules, or any other study details.'**
  String get quickContactMessage;

  /// No description provided for @contactOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get contactOnWhatsapp;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get bioLabel;

  /// No description provided for @noBio.
  ///
  /// In en, this message translates to:
  /// **'No bio is available for this teacher yet.'**
  String get noBio;

  /// No description provided for @teachingPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Teaching Location & Method'**
  String get teachingPlaceTitle;

  /// No description provided for @teachingMethod.
  ///
  /// In en, this message translates to:
  /// **'Teaching Method'**
  String get teachingMethod;

  /// No description provided for @centerLocation.
  ///
  /// In en, this message translates to:
  /// **'Center Location'**
  String get centerLocation;

  /// No description provided for @locatedInGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Located in centers in {governorate} governorate'**
  String locatedInGovernorate(String governorate);

  /// No description provided for @academicTitle.
  ///
  /// In en, this message translates to:
  /// **'Grades & Systems'**
  String get academicTitle;

  /// No description provided for @subjectField.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectField;

  /// No description provided for @gradeField.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get gradeField;

  /// No description provided for @systemField.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemField;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @generalSecondary.
  ///
  /// In en, this message translates to:
  /// **'General Secondary'**
  String get generalSecondary;

  /// No description provided for @azhariSecondary.
  ///
  /// In en, this message translates to:
  /// **'Al-Azhar Secondary'**
  String get azhariSecondary;

  /// No description provided for @stemSchools.
  ///
  /// In en, this message translates to:
  /// **'STEM Schools'**
  String get stemSchools;

  /// No description provided for @modeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online (through the platform only)'**
  String get modeOnline;

  /// No description provided for @modeCenter.
  ///
  /// In en, this message translates to:
  /// **'In-person at the center only'**
  String get modeCenter;

  /// No description provided for @modeBoth.
  ///
  /// In en, this message translates to:
  /// **'Online and through educational centers'**
  String get modeBoth;

  /// No description provided for @modeOnlineShort.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get modeOnlineShort;

  /// No description provided for @teacherInfoLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load teacher info'**
  String get teacherInfoLoadError;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bookmarks'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Courses you saved for review'**
  String get bookmarksSubtitle;

  /// No description provided for @loadBookmarksError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred loading your bookmarks'**
  String get loadBookmarksError;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet\nTap the save icon to add courses here'**
  String get noBookmarks;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @reviewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real reviews on notebook pages'**
  String get reviewsSubtitle;

  /// No description provided for @basedOnReviews.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} student review(s)'**
  String basedOnReviews(int count);

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet — be the first to review this course'**
  String get noReviewsYet;

  /// No description provided for @addYourReview.
  ///
  /// In en, this message translates to:
  /// **'Add Your Review'**
  String get addYourReview;

  /// No description provided for @writeReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReviewTitle;

  /// No description provided for @writeReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write your opinion in your own hand'**
  String get writeReviewSubtitle;

  /// No description provided for @reviewHelpsOthers.
  ///
  /// In en, this message translates to:
  /// **'Your review helps classmates choose the right course'**
  String get reviewHelpsOthers;

  /// No description provided for @yourRatingQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your rating for this course?'**
  String get yourRatingQuestion;

  /// No description provided for @detailedReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your detailed review'**
  String get detailedReviewTitle;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'What was your experience with this course and teacher? Share your opinion to help other students...'**
  String get reviewHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @mustLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'You must log in first'**
  String get mustLoginFirst;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your review was submitted successfully'**
  String get reviewSubmitted;

  /// No description provided for @reviewSubmitError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while submitting your review, please try again'**
  String get reviewSubmitError;

  /// No description provided for @examProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress & Exams'**
  String get examProgressTitle;

  /// No description provided for @examProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test what you\'ve studied on your notebook pages'**
  String get examProgressSubtitle;

  /// No description provided for @loadExamsError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred loading exams'**
  String get loadExamsError;

  /// No description provided for @noExamsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exams available right now\nYour exams will appear here when teachers add them'**
  String get noExamsAvailable;

  /// No description provided for @examAttemptsExhaustedTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam attempts exhausted'**
  String get examAttemptsExhaustedTitle;

  /// No description provided for @examAttemptsExhaustedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used up the allowed attempts for this exam ({max} attempts). You can view your results or contact the teacher to reopen the exam.'**
  String examAttemptsExhaustedMessage(int max);

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get viewResults;

  /// No description provided for @examDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Exam duration: {duration} minutes'**
  String examDurationLabel(int duration);

  /// No description provided for @attemptsCount.
  ///
  /// In en, this message translates to:
  /// **'Attempts: {used}/{max}'**
  String attemptsCount(int used, int max);

  /// No description provided for @resultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsLabel;

  /// No description provided for @lockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedLabel;

  /// No description provided for @enterExam.
  ///
  /// In en, this message translates to:
  /// **'Enter Exam'**
  String get enterExam;

  /// No description provided for @anotherAttempt.
  ///
  /// In en, this message translates to:
  /// **'Another Attempt'**
  String get anotherAttempt;

  /// No description provided for @comprehensiveExam.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Exam'**
  String get comprehensiveExam;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{min} minutes'**
  String durationMinutes(int min);

  /// No description provided for @totalMarks.
  ///
  /// In en, this message translates to:
  /// **'{marks} marks'**
  String totalMarks(String marks);

  /// No description provided for @examInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Instructions & Rules'**
  String get examInstructionsTitle;

  /// No description provided for @examInstructionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read the rules before starting'**
  String get examInstructionsSubtitle;

  /// No description provided for @responsibleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Responsible teacher: {name}'**
  String responsibleTeacher(String name);

  /// No description provided for @durationStat.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationStat;

  /// No description provided for @questionCountStat.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questionCountStat;

  /// No description provided for @totalScoreStat.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScoreStat;

  /// No description provided for @examRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Rules & Regulations'**
  String get examRulesTitle;

  /// No description provided for @strictRulesNote.
  ///
  /// In en, this message translates to:
  /// **'Strict rules, reading is mandatory before starting'**
  String get strictRulesNote;

  /// No description provided for @ruleTimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Precise timing'**
  String get ruleTimingTitle;

  /// No description provided for @ruleTimingDesc.
  ///
  /// In en, this message translates to:
  /// **'The timer starts as soon as you enter the exam, and answers are submitted automatically when time runs out.'**
  String get ruleTimingDesc;

  /// No description provided for @ruleNoExitTitle.
  ///
  /// In en, this message translates to:
  /// **'No leaving the screen (auto-submit)'**
  String get ruleNoExitTitle;

  /// No description provided for @ruleNoExitDesc.
  ///
  /// In en, this message translates to:
  /// **'If you leave the app, minimize the screen, or switch to another app, the exam will be submitted immediately and graded only on what you answered!'**
  String get ruleNoExitDesc;

  /// No description provided for @ruleConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep a stable connection'**
  String get ruleConnectionTitle;

  /// No description provided for @ruleConnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Make sure your phone is charged and your internet connection is stable before starting.'**
  String get ruleConnectionDesc;

  /// No description provided for @attemptsFinished.
  ///
  /// In en, this message translates to:
  /// **'Allowed attempts exhausted'**
  String get attemptsFinished;

  /// No description provided for @remainingAttempts.
  ///
  /// In en, this message translates to:
  /// **'Remaining attempts: {remaining} of {max}'**
  String remainingAttempts(int remaining, int max);

  /// No description provided for @attemptsFinishedMessage.
  ///
  /// In en, this message translates to:
  /// **'You can contact the teacher to reopen the exam, or view your results'**
  String get attemptsFinishedMessage;

  /// No description provided for @retakeMessage.
  ///
  /// In en, this message translates to:
  /// **'You can retake the exam up to {max} attempts to get the best result'**
  String retakeMessage(int max);

  /// No description provided for @startExamNow.
  ///
  /// In en, this message translates to:
  /// **'Start Exam Now'**
  String get startExamNow;

  /// No description provided for @confirmStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Start'**
  String get confirmStartTitle;

  /// No description provided for @confirmStartMessage.
  ///
  /// In en, this message translates to:
  /// **'Once you press \"Start\", the timer begins and cannot be stopped, and leaving the screen is blocked otherwise your answers will be submitted immediately. Are you ready?'**
  String get confirmStartMessage;

  /// No description provided for @loadQuestionsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load exam questions'**
  String get loadQuestionsError;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @monitoringBanner.
  ///
  /// In en, this message translates to:
  /// **'Security monitoring: leaving or minimizing the screen causes auto-submission!'**
  String get monitoringBanner;

  /// No description provided for @questionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {questionNumber} of {total}'**
  String questionOf(int questionNumber, int total);

  /// No description provided for @noOptionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No answers available for this question'**
  String get noOptionsAvailable;

  /// No description provided for @previousQuestion.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousQuestion;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @submitExamLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam'**
  String get submitExamLabel;

  /// No description provided for @writeAnswerHere.
  ///
  /// In en, this message translates to:
  /// **'Write your answer here'**
  String get writeAnswerHere;

  /// No description provided for @writeAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Write your detailed answer...'**
  String get writeAnswerHint;

  /// No description provided for @savedChars.
  ///
  /// In en, this message translates to:
  /// **'Saved: {count} characters'**
  String savedChars(int count);

  /// No description provided for @exitBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaving the exam is blocked'**
  String get exitBlockedTitle;

  /// No description provided for @exitBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Leaving the exam screen now will immediately submit all your current answers and calculate the final grade. Do you want to submit and exit?'**
  String get exitBlockedMessage;

  /// No description provided for @cancelAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Cancel and continue'**
  String get cancelAndContinue;

  /// No description provided for @submitNow.
  ///
  /// In en, this message translates to:
  /// **'Submit Now'**
  String get submitNow;

  /// No description provided for @examResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Result'**
  String get examResultTitle;

  /// No description provided for @gradedSaved.
  ///
  /// In en, this message translates to:
  /// **'Graded and saved'**
  String get gradedSaved;

  /// No description provided for @gradedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Graded successfully'**
  String get gradedSuccess;

  /// No description provided for @autoSubmitWarning.
  ///
  /// In en, this message translates to:
  /// **'Note: The exam was submitted automatically because you left the screen or minimized the app during the assessment.'**
  String get autoSubmitWarning;

  /// No description provided for @timeoutSubmitNote.
  ///
  /// In en, this message translates to:
  /// **'The exam was submitted automatically when the allotted time ran out.'**
  String get timeoutSubmitNote;

  /// No description provided for @resultStamp.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultStamp;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage: {percent}%'**
  String percentage(String percent);

  /// No description provided for @examPassed.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, you passed the exam'**
  String get examPassed;

  /// No description provided for @examFailed.
  ///
  /// In en, this message translates to:
  /// **'You did not reach the required percentage'**
  String get examFailed;

  /// No description provided for @attemptInfoExhausted.
  ///
  /// In en, this message translates to:
  /// **'This is attempt {attempt} of {max} — you have used all attempts for this exam. You can review your results anytime.'**
  String attemptInfoExhausted(int attempt, int max);

  /// No description provided for @attemptInfoRemaining.
  ///
  /// In en, this message translates to:
  /// **'This is attempt {attempt} of {max} — you have {remaining} attempts left.'**
  String attemptInfoRemaining(int attempt, int max, int remaining);

  /// No description provided for @viewAllResults.
  ///
  /// In en, this message translates to:
  /// **'View All Results'**
  String get viewAllResults;

  /// No description provided for @backToExams.
  ///
  /// In en, this message translates to:
  /// **'Back to Exams List'**
  String get backToExams;

  /// No description provided for @examResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Results'**
  String get examResultsTitle;

  /// No description provided for @loadResultsError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred loading results'**
  String get loadResultsError;

  /// No description provided for @noAttemptsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t taken any attempts in this exam yet'**
  String get noAttemptsYet;

  /// No description provided for @attemptsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of attempts: {total}'**
  String attemptsCountLabel(int total);

  /// No description provided for @attemptNumber.
  ///
  /// In en, this message translates to:
  /// **'Attempt #{index}'**
  String attemptNumber(int index);

  /// No description provided for @passedPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Passed'**
  String passedPercent(int percent);

  /// No description provided for @gradeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade History'**
  String get gradeHistoryTitle;

  /// No description provided for @gradeHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your exam results on notebook pages'**
  String get gradeHistorySubtitle;

  /// No description provided for @loadGradesError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred loading grades'**
  String get loadGradesError;

  /// No description provided for @noGradesYet.
  ///
  /// In en, this message translates to:
  /// **'No grades yet\nTake an exam to see your result here'**
  String get noGradesYet;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notebook display language'**
  String get languageSubtitle;

  /// No description provided for @availableLanguages.
  ///
  /// In en, this message translates to:
  /// **'Available Languages'**
  String get availableLanguages;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data and settings'**
  String get profileSubtitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @termsAndPolicies.
  ///
  /// In en, this message translates to:
  /// **'Terms & Policies'**
  String get termsAndPolicies;

  /// No description provided for @supportCenter.
  ///
  /// In en, this message translates to:
  /// **'Support & Help Center'**
  String get supportCenter;

  /// No description provided for @supportCenterMessage.
  ///
  /// In en, this message translates to:
  /// **'Help & technical support center'**
  String get supportCenterMessage;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @inviteLink.
  ///
  /// In en, this message translates to:
  /// **'Join Thanaweya Online: https://thanaweya-online-website.vercel.app/'**
  String get inviteLink;

  /// No description provided for @inviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied successfully'**
  String get inviteCopied;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutConfirmMessage;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data on notebook pages'**
  String get editProfileSubtitle;

  /// No description provided for @basicData.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicData;

  /// No description provided for @nickName.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @studentLabel.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentLabel;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @updateData.
  ///
  /// In en, this message translates to:
  /// **'Update Data'**
  String get updateData;

  /// No description provided for @updateDataError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating your data'**
  String get updateDataError;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password first'**
  String get changePasswordSubtitle;

  /// No description provided for @passwordSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'To keep your account secure, enter your current password then choose a strong new one.'**
  String get passwordSecurityNote;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @reenterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get reenterNewPassword;

  /// No description provided for @changingPassword.
  ///
  /// In en, this message translates to:
  /// **'Changing...'**
  String get changingPassword;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @changePasswordError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while changing the password'**
  String get changePasswordError;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Alerts'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control your notebook alerts'**
  String get notificationsSubtitle;

  /// No description provided for @notifSpecialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get notifSpecialOffers;

  /// No description provided for @notifSounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds & Alerts'**
  String get notifSounds;

  /// No description provided for @notifVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get notifVibration;

  /// No description provided for @notifGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Notifications'**
  String get notifGeneral;

  /// No description provided for @notifPromotions.
  ///
  /// In en, this message translates to:
  /// **'Discounts & Promotions'**
  String get notifPromotions;

  /// No description provided for @notifPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Transactions'**
  String get notifPayment;

  /// No description provided for @notifAppUpdates.
  ///
  /// In en, this message translates to:
  /// **'App Updates'**
  String get notifAppUpdates;

  /// No description provided for @notifNewServices.
  ///
  /// In en, this message translates to:
  /// **'New Services'**
  String get notifNewServices;

  /// No description provided for @notifTips.
  ///
  /// In en, this message translates to:
  /// **'Tips & Guidance'**
  String get notifTips;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @commentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Student notes on the lesson'**
  String get commentsSubtitle;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet\nBe the first to comment on the lesson'**
  String get noCommentsYet;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get commentHint;

  /// No description provided for @userGeneric.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userGeneric;

  /// No description provided for @certificateTitle.
  ///
  /// In en, this message translates to:
  /// **'Completion Certificate'**
  String get certificateTitle;

  /// No description provided for @certificateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your honor page in the notebook'**
  String get certificateSubtitle;

  /// No description provided for @courseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Course Completed Successfully'**
  String get courseCompleted;

  /// No description provided for @certWitness.
  ///
  /// In en, this message translates to:
  /// **'Thanaweya Online certifies that the student'**
  String get certWitness;

  /// No description provided for @certCompleted.
  ///
  /// In en, this message translates to:
  /// **'has successfully completed all requirements and tests of the educational course:'**
  String get certCompleted;

  /// No description provided for @issueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue date: {date}'**
  String issueDateLabel(String date);

  /// No description provided for @studentSignature.
  ///
  /// In en, this message translates to:
  /// **'Student Signature'**
  String get studentSignature;

  /// No description provided for @platformManager.
  ///
  /// In en, this message translates to:
  /// **'Platform Manager'**
  String get platformManager;

  /// No description provided for @platformName.
  ///
  /// In en, this message translates to:
  /// **'Thanaweya Online'**
  String get platformName;

  /// No description provided for @downloadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Download Certificate'**
  String get downloadCertificate;

  /// No description provided for @certificateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Certificate downloaded successfully as PDF'**
  String get certificateDownloaded;

  /// No description provided for @enterActivationCodeFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code first'**
  String get enterActivationCodeFirst;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congratulations;

  /// No description provided for @subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Your subscription was activated successfully.\nYou can now start studying the lectures'**
  String get subscriptionActivated;

  /// No description provided for @watchLecturesNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Lectures Now'**
  String get watchLecturesNow;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @subscribeToCourse.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Course'**
  String get subscribeToCourse;

  /// No description provided for @freeCourse.
  ///
  /// In en, this message translates to:
  /// **'Free Course'**
  String get freeCourse;

  /// No description provided for @courseSubscription.
  ///
  /// In en, this message translates to:
  /// **'Course Subscription'**
  String get courseSubscription;

  /// No description provided for @activationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code you received from your teacher'**
  String get activationCodeHint;

  /// No description provided for @activationCode.
  ///
  /// In en, this message translates to:
  /// **'Activation Code'**
  String get activationCode;

  /// No description provided for @codeExample.
  ///
  /// In en, this message translates to:
  /// **'Example: TH-8921-X90'**
  String get codeExample;

  /// No description provided for @codeNote.
  ///
  /// In en, this message translates to:
  /// **'Once confirmed, your subscription will be activated immediately for all of the teacher\'s courses'**
  String get codeNote;

  /// No description provided for @activateSubscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code to start studying the course'**
  String get activateSubscriptionSubtitle;

  /// No description provided for @codeTab.
  ///
  /// In en, this message translates to:
  /// **'Activation Code'**
  String get codeTab;

  /// No description provided for @electronicPaymentTab.
  ///
  /// In en, this message translates to:
  /// **'Electronic Payment'**
  String get electronicPaymentTab;

  /// No description provided for @activatingCode.
  ///
  /// In en, this message translates to:
  /// **'Activating code...'**
  String get activatingCode;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @activateAndSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Activate Code & Subscribe Now'**
  String get activateAndSubscribe;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment & Subscribe Now'**
  String get confirmPayment;

  /// No description provided for @paySecurely.
  ///
  /// In en, this message translates to:
  /// **'Pay securely and easily via direct electronic payment'**
  String get paySecurely;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @visaMastercard.
  ///
  /// In en, this message translates to:
  /// **'Visa / Mastercard'**
  String get visaMastercard;

  /// No description provided for @fawryPayments.
  ///
  /// In en, this message translates to:
  /// **'Fawry Payments'**
  String get fawryPayments;

  /// No description provided for @cardData.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardData;

  /// No description provided for @cardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardHolderName;

  /// No description provided for @cardHolderExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Ahmed Mohamed Ali'**
  String get cardHolderExample;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvvCode.
  ///
  /// In en, this message translates to:
  /// **'Security Code (CVV)'**
  String get cvvCode;

  /// No description provided for @payViaFawry.
  ///
  /// In en, this message translates to:
  /// **'Pay via Fawry'**
  String get payViaFawry;

  /// No description provided for @fawryNote.
  ///
  /// In en, this message translates to:
  /// **'A temporary Fawry payment code will be issued to complete the payment at any Fawry outlet.'**
  String get fawryNote;

  /// No description provided for @fillCardData.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all card details'**
  String get fillCardData;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the electronic payment, please try again'**
  String get paymentFailed;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Transactions'**
  String get transactionsTitle;

  /// No description provided for @transactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payments and subscriptions record'**
  String get transactionsSubtitle;

  /// No description provided for @transactionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading transactions'**
  String get transactionsLoadError;

  /// No description provided for @transactionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet\nYour payments will appear here when you subscribe to courses'**
  String get transactionsEmpty;

  /// No description provided for @courseSubscriptionFallback.
  ///
  /// In en, this message translates to:
  /// **'Course subscription'**
  String get courseSubscriptionFallback;

  /// No description provided for @electronicPayment.
  ///
  /// In en, this message translates to:
  /// **'Electronic payment'**
  String get electronicPayment;

  /// No description provided for @teacherActivationCode.
  ///
  /// In en, this message translates to:
  /// **'Teacher activation code'**
  String get teacherActivationCode;

  /// No description provided for @fawryGateway.
  ///
  /// In en, this message translates to:
  /// **'Fawry payments'**
  String get fawryGateway;

  /// No description provided for @creditCardGateway.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get creditCardGateway;

  /// No description provided for @freeViaCode.
  ///
  /// In en, this message translates to:
  /// **'Free (code)'**
  String get freeViaCode;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Electronic Payment Receipt'**
  String get receiptTitle;

  /// No description provided for @receiptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A copy of the receipt on your notebook page'**
  String get receiptSubtitle;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get shareReceipt;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @downloadAction.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadAction;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print receipt'**
  String get printReceipt;

  /// No description provided for @printAction.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printAction;

  /// No description provided for @actionExecuted.
  ///
  /// In en, this message translates to:
  /// **'Action executed: '**
  String get actionExecuted;

  /// No description provided for @studentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Student Name'**
  String get studentNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @courseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseNameLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @transactionNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction Number'**
  String get transactionNumberLabel;

  /// No description provided for @transactionIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Transaction number copied'**
  String get transactionIdCopied;

  /// No description provided for @amountPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaidLabel;

  /// No description provided for @transactionDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDateLabel;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatusLabel;

  /// No description provided for @paidStatus.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidStatus;

  /// No description provided for @egpCurrency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egpCurrency;

  /// No description provided for @addCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addCardTitle;

  /// No description provided for @addCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register a new payment method in your notebook'**
  String get addCardSubtitle;

  /// No description provided for @cardDataSection.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDataSection;

  /// No description provided for @cardHolderNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name *'**
  String get cardHolderNameRequired;

  /// No description provided for @cardHolderHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name printed on the card'**
  String get cardHolderHint;

  /// No description provided for @cardNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Card Number *'**
  String get cardNumberRequired;

  /// No description provided for @cardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'•••• •••• •••• ••••'**
  String get cardNumberHint;

  /// No description provided for @expiryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date *'**
  String get expiryDateRequired;

  /// No description provided for @cvvRequired.
  ///
  /// In en, this message translates to:
  /// **'Security Code *'**
  String get cvvRequired;

  /// No description provided for @cvvHint.
  ///
  /// In en, this message translates to:
  /// **'•••'**
  String get cvvHint;

  /// No description provided for @addCardButton.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardButton;

  /// No description provided for @enterCardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the cardholder name'**
  String get enterCardHolderName;

  /// No description provided for @enterValidCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid card number'**
  String get enterValidCardNumber;

  /// No description provided for @enterValidExpiry.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid expiry date (MM/YY)'**
  String get enterValidExpiry;

  /// No description provided for @loginRequiredFirst.
  ///
  /// In en, this message translates to:
  /// **'You must log in first'**
  String get loginRequiredFirst;

  /// No description provided for @cardAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get cardAddedSuccess;

  /// No description provided for @cardAddError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while adding the card, please try again'**
  String get cardAddError;

  /// No description provided for @defaultCardFallback.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get defaultCardFallback;

  /// No description provided for @paymentOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods Options'**
  String get paymentOptionsTitle;

  /// No description provided for @paymentOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved cards in the notebook'**
  String get paymentOptionsSubtitle;

  /// No description provided for @noSavedCards.
  ///
  /// In en, this message translates to:
  /// **'No saved cards yet'**
  String get noSavedCards;

  /// No description provided for @defaultCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultCardLabel;

  /// No description provided for @connectedCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectedCardLabel;

  /// No description provided for @addNewCardButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCardButton;

  /// No description provided for @courseLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Lessons'**
  String get courseLessonsTitle;

  /// No description provided for @courseLessonsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch the sessions and continue your progress'**
  String get courseLessonsSubtitle;

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson '**
  String get lessonNumber;

  /// No description provided for @startFirstLesson.
  ///
  /// In en, this message translates to:
  /// **'Start First Lesson'**
  String get startFirstLesson;

  /// No description provided for @lessonLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Locked'**
  String get lessonLockedTitle;

  /// No description provided for @lessonLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the curriculum is available for viewing only. To watch the video \"{lessonTitle}\" you must pay, subscribe and activate the code first.'**
  String lessonLockedMessage(String lessonTitle);

  /// No description provided for @payAndActivateCode.
  ///
  /// In en, this message translates to:
  /// **'Pay & Activate Code'**
  String get payAndActivateCode;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notebook and platform rules'**
  String get termsSubtitle;

  /// No description provided for @attendanceTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance & Enrollment Terms'**
  String get attendanceTermsTitle;

  /// No description provided for @attendanceTermsBody.
  ///
  /// In en, this message translates to:
  /// **'Thanaweya Online platform is committed to providing the best approved content and high-quality educational lessons. The student undertakes to attend and continuously follow up on scheduled sessions and exams. Sharing personal accounts or reselling educational content without prior written permission is strictly prohibited.'**
  String get attendanceTermsBody;

  /// No description provided for @usageTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage & Service Terms'**
  String get usageTermsTitle;

  /// No description provided for @usageTermsBody.
  ///
  /// In en, this message translates to:
  /// **'All intellectual property rights, trademarks and illustrative materials are reserved to Thanaweya Online platform and certified teachers. Video media is encrypted and protected, and any attempt to record the screen or hack the content subjects the account to permanent ban and legal prosecution.'**
  String get usageTermsBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
