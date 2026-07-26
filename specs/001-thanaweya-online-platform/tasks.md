# Tasks: Thanaweya Online Platform

**Input**: Design documents from `/specs/001-thanaweya-online-platform/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, dependencies, and core structure

- [X] T001 Update pubspec.yaml with all required dependencies (flutter_riverpod, supabase_flutter, go_router, youtube_player_flutter, fl_chart, cached_network_image, connectivity_plus)
- [X] T002 Create lib/core/constants/app_colors.dart with design system colors (#1D4ED8 primary, #0FA37F secondary, #22C55E success, #EF4444 error, #F59E0B warning, #FAFAFA background)
- [X] T003 [P] Create lib/core/constants/app_text_styles.dart with Arabic typography styles
- [X] T004 [P] Create lib/core/constants/app_strings.dart with all Arabic UI strings
- [X] T005 [P] Create lib/theme/app_theme.dart with MaterialTheme for light mode (RTL, Arabic fonts)
- [X] T006 [P] Create lib/theme/dark_theme.dart stub for future dark mode support
- [X] T007 Create lib/core/supabase/supabase_client.dart with Supabase initialization
- [X] T008 [P] Create lib/core/utils/validators.dart with form validation helpers (email, phone, password)
- [X] T009 [P] Create lib/core/utils/formatters.dart with Arabic date/number formatters

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T010 Create lib/core/auth/auth_service.dart with Supabase auth methods (signUp, signIn, signOut, resetPassword, getCurrentUser)
- [X] T011 Create lib/core/auth/auth_provider.dart with Riverpod auth state provider
- [X] T012 Create lib/core/auth/role_guard.dart with role-based route redirect logic
- [X] T013 Create lib/core/router/app_router.dart with GoRouter configuration and role-based guards
- [X] T014 Create lib/features/shared/models/user_model.dart with User data class
- [X] T015 [P] Create lib/features/shared/models/teacher_model.dart with Teacher data class
- [X] T016 [P] Create lib/features/shared/models/student_model.dart with Student data class
- [X] T017 [P] Create lib/features/shared/widgets/app_button.dart with reusable button component
- [X] T018 [P] Create lib/features/shared/widgets/app_card.dart with reusable card component
- [X] T019 [P] Create lib/features/shared/widgets/loading_indicator.dart with loading spinner
- [X] T020 [P] Create lib/features/shared/widgets/offline_screen.dart with offline state UI
- [X] T021 [P] Create lib/features/shared/widgets/role_based_scaffold.dart with role-aware shell
- [X] T022 Create lib/main.dart with app initialization, Supabase setup, and MaterialApp configuration (RTL, Arabic locale, theme)

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Teacher Registration & Approval (Priority: P1) MVP

**Goal**: Teacher can register, get approved by Super Admin, and access their dashboard

**Independent Test**: Register a teacher, approve via Supabase, verify dashboard access

### Implementation for User Story 1

- [X] T023 [P] [US1] Create lib/features/splash/splash_screen.dart with session check and auto-redirect
- [X] T024 [P] [US1] Create lib/features/role_selection/role_selection_screen.dart with teacher/student cards
- [X] T025 [P] [US1] Create lib/features/auth/login_screen.dart with email/password login
- [X] T026 [P] [US1] Create lib/features/auth/forgot_password_screen.dart with email reset flow
- [X] T027 [P] [US1] Create lib/features/auth/otp_screen.dart with OTP verification
- [X] T028 [US1] Create lib/features/teacher/onboarding/teacher_form_screen.dart with registration form (name, subject dropdown, stage, phone, bio, email, password)
- [X] T029 [US1] Create lib/features/teacher/onboarding/pending_review_screen.dart with waiting state UI
- [X] T030 [US1] Create lib/features/teacher/onboarding/rejection_screen.dart with rejection reason display
- [X] T031 [US1] Create lib/features/teacher/dashboard/teacher_home_screen.dart with stats cards and recent activity
- [X] T032 [US1] Create lib/features/teacher/dashboard/teacher_bottom_nav.dart with bottom navigation (Home, Courses, Students, Reports, Settings)
- [X] T033 [US1] Create lib/features/teacher/settings/teacher_settings_screen.dart with profile editing and logout

**Checkpoint**: Teacher can register, get approved, and navigate their dashboard

---

## Phase 4: User Story 2 - Course & Video Content Management (Priority: P1)

**Goal**: Teacher can create courses, add lessons with YouTube or uploaded videos

**Independent Test**: Create a course with 3 YouTube lessons, verify they appear correctly

### Implementation for User Story 2

- [X] T034 [P] [US2] Create lib/features/shared/models/course_model.dart with Course data class
- [X] T035 [P] [US2] Create lib/features/shared/models/lesson_model.dart with Lesson data class
- [X] T036 [US2] Create lib/features/teacher/courses/courses_list_screen.dart with course cards and add button
- [X] T037 [US2] Create lib/features/teacher/courses/create_course_screen.dart with name, description, cover image form
- [X] T038 [US2] Create lib/features/teacher/courses/lessons_list_screen.dart with draggable lesson list
- [X] T039 [US2] Create lib/features/teacher/courses/add_lesson_screen.dart with YouTube/upload tabs, title, description, free preview toggle
- [X] T040 [US2] Implement YouTube link preview logic (fetch thumbnail and duration from youtube_player_flutter)

**Checkpoint**: Teacher can create courses and add video lessons

---

## Phase 5: User Story 3 - Student Onboarding & Subscription (Priority: P2)

**Goal**: Student can select subjects, choose teachers, activate subscription via code

**Independent Test**: Register student, select subjects/teachers, enter activation code, verify home screen

### Implementation for User Story 3

- [X] T041 [P] [US3] Create lib/features/shared/models/subscription_model.dart with Subscription data class
- [X] T042 [P] [US3] Create lib/features/shared/models/activation_code_model.dart with ActivationCode data class
- [X] T043 [US3] Create lib/features/student/onboarding/subject_selection_screen.dart with multi-select grid
- [X] T044 [US3] Create lib/features/student/onboarding/teacher_selection_screen.dart with teacher cards per subject
- [X] T045 [US3] Create lib/features/student/onboarding/student_form_screen.dart with personal data form
- [X] T046 [US3] Create lib/features/student/onboarding/activation_screen.dart with code input and payment option stubs
- [X] T047 [US3] Create lib/features/student/dashboard/student_home_screen.dart with teacher tabs and course cards
- [X] T048 [US3] Create lib/features/student/dashboard/student_bottom_nav.dart with bottom navigation (Home, Exams, Grades, Settings)
- [X] T049 [US3] Create lib/features/student/settings/student_settings_screen.dart with profile and logout

**Checkpoint**: Student can complete onboarding and see subscribed teachers' courses

---

## Phase 6: User Story 4 - Student Video Learning (Priority: P2)

**Goal**: Student watches videos in a unified player with progress tracking

**Independent Test**: Watch a YouTube lesson, verify progress updates

### Implementation for User Story 4

- [X] T050 [P] [US4] Create lib/features/shared/models/lesson_progress_model.dart with progress tracking data class
- [X] T051 [US4] Create lib/features/student/courses/teacher_page_screen.dart with teacher banner and course list
- [X] T052 [US4] Create lib/features/student/courses/course_lessons_screen.dart with lesson list, progress bar, completion checkmarks
- [X] T053 [US4] Create lib/features/student/courses/video_player_screen.dart with unified player (YouTube + uploaded), playback controls, progress tracking

**Checkpoint**: Student can browse courses and watch videos with progress tracking

---

## Phase 7: User Story 5 - Exam System (Priority: P3)

**Goal**: Teacher creates exams, students take them with auto-grading

**Independent Test**: Create exam with 5 MCQ questions, student takes exam, both see results

### Implementation for User Story 5

- [X] T054 [P] [US5] Create lib/features/shared/models/exam_model.dart with Exam data class
- [X] T055 [P] [US5] Create lib/features/shared/models/question_model.dart with Question data class
- [X] T056 [US5] Create lib/features/teacher/exams/exams_list_screen.dart with exam cards
- [X] T057 [US5] Create lib/features/teacher/exams/create_exam_screen.dart with title, course, duration, dates form
- [X] T058 [US5] Create lib/features/teacher/exams/add_questions_screen.dart with question type selector, MCQ/TF/essay forms
- [X] T059 [US5] Create lib/features/teacher/exams/question_bank_screen.dart with reusable questions list
- [X] T060 [US5] Create lib/features/student/exams/exams_list_screen.dart with available exams
- [X] T061 [US5] Create lib/features/student/exams/exam_start_screen.dart with instructions and start button
- [X] T062 [US5] Create lib/features/student/exams/exam_taking_screen.dart with countdown timer, question navigation, answer selection
- [X] T063 [US5] Create lib/features/student/exams/exam_result_screen.dart with score display and answer review
- [X] T064 [US5] Create lib/features/student/exams/grade_history_screen.dart with exam list, scores, and performance chart

**Checkpoint**: Complete exam flow from creation to taking to results

---

## Phase 8: User Story 6 - Student Management (Priority: P3)

**Goal**: Teacher manages students, generates activation codes, views progress

**Independent Test**: View student list, generate codes, verify student can use one

### Implementation for User Story 6

- [X] T065 [US6] Create lib/features/teacher/students/students_list_screen.dart with student list, filters, search
- [X] T066 [US6] Create lib/features/teacher/students/student_detail_screen.dart with progress and scores per course
- [X] T067 [US6] Create lib/features/teacher/students/activation_codes_screen.dart with bulk code generation and export

**Checkpoint**: Teacher can manage students and generate activation codes

---

## Phase 9: User Story 7 - Super Admin (Priority: P4)

**Goal**: Super Admin manages platform: approves teachers, manages subjects, views reports

**Independent Test**: Log in as admin, approve a teacher, manage subjects

### Implementation for User Story 7

- [X] T068 [US7] Create lib/features/admin/dashboard/admin_dashboard_screen.dart with stats and pending requests
- [X] T069 [US7] Create lib/features/admin/teachers/teacher_requests_screen.dart with approve/reject actions
- [X] T070 [US7] Create lib/features/admin/teachers/all_teachers_screen.dart with full teacher list
- [X] T071 [US7] Create lib/features/admin/subjects/manage_subjects_screen.dart with add/edit/delete subjects
- [X] T072 [US7] Create lib/features/admin/plans/subscription_plans_screen.dart with plan cards and toggle
- [X] T073 [US7] Create lib/features/admin/plans/edit_plan_screen.dart with plan form
- [X] T074 [US7] Create lib/features/admin/reports/platform_reports_screen.dart with platform-wide charts

**Checkpoint**: Super Admin can manage the entire platform from within the app

---

## Phase 10: User Story Additional - Comments & Notifications (Priority: P4)

**Goal**: Students comment on lessons, both roles receive notifications

### Implementation

- [X] T075 [P] Create lib/features/student/comments/lesson_comments_screen.dart with comment list and input
- [X] T076 [P] Create lib/features/shared/models/comment_model.dart with Comment data class

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T077 Implement RLS policies in Supabase SQL (lib/core/supabase/rls_policies.sql) for all tables
- [X] T078 Add comprehensive error handling and user-friendly Arabic error messages across all screens
- [X] T079 Implement pull-to-refresh on all list screens
- [X] T080 Add skeleton loading states for all data-dependent screens
- [X] T081 Ensure all forms have proper Arabic validation messages
- [X] T082 Test and fix RTL layout on all 46 screens
- [X] T083 Run quickstart.md validation scenarios end-to-end

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **US1 Teacher Registration (Phase 3)**: Depends on Phase 2 - MVP entry point
- **US2 Course Management (Phase 4)**: Depends on Phase 2, integrates with US1 (teacher must be approved)
- **US3 Student Onboarding (Phase 5)**: Depends on Phase 2, integrates with US1 (teacher approval enables student subscription)
- **US4 Video Learning (Phase 6)**: Depends on Phase 5 (student must be subscribed) and Phase 4 (courses must exist)
- **US5 Exams (Phase 7)**: Depends on Phase 2, can run parallel to US3/US4
- **US6 Student Management (Phase 8)**: Depends on Phase 2, integrates with US1 and US3
- **US7 Super Admin (Phase 9)**: Depends on Phase 2, can run any time
- **Comments (Phase 10)**: Depends on Phase 4 and Phase 6
- **Polish (Phase 11)**: Depends on all desired phases being complete

### Parallel Opportunities

- Phase 1 tasks marked [P] can all run in parallel
- Phase 2 models (T015-T016) and widgets (T017-T021) can run in parallel
- US1 screens (T023-T027) can run in parallel
- US2 models (T034-T035) can run in parallel
- US5 models (T054-T055) can run in parallel
- US7 screens (T068-T074) can run in parallel
- Comments (T075-T076) can run in parallel

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: US1 Teacher Registration
4. Complete Phase 4: US2 Course Management
5. **STOP and VALIDATE**: Teacher can register, get approved, create courses

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US1 + US2 → Teacher can create content (MVP!)
3. US3 + US4 → Students can subscribe and learn
4. US5 → Exam system complete
5. US6 + US7 → Full management capabilities
6. Polish → Production-ready

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
