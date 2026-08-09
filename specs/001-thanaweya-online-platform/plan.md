# Implementation Plan: Thanaweya Online Platform

**Branch**: `001-thanaweya-online-platform` | **Date**: 2026-07-21 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-thanaweya-online-platform/spec.md`

## Summary

Thanaweya Online is a multi-tenant SaaS educational platform for Egyptian secondary school teachers and students. Teachers upload video courses (YouTube + direct upload), create exams, and manage students. Students subscribe to teachers and consume content. Built with Flutter + Supabase, supporting 46 screens across three roles (Super Admin, Teacher, Student).

## Technical Context

**Language/Version**: Dart 3.12+, Flutter SDK ^3.12.0

**Primary Dependencies**: flutter_riverpod (state management), supabase_flutter (auth + database + storage), go_router (navigation), youtube_player_flutter (YouTube playback), fl_chart (reports/charts), cached_network_image (image caching), connectivity_plus (network status)

**Storage**: Supabase (PostgreSQL + Row Level Security + Storage + Realtime)

**Testing**: flutter_test (unit/widget), integration_test (integration)

**Target Platform**: Android, iOS, Web (mobile-first)

**Project Type**: mobile-app (Flutter cross-platform)

**Performance Goals**: Video start <3s, exam submission grading <10s, offline detection <2s

**Constraints**: Arabic RTL primary, offline-resilient, content protection via RLS

**Scale/Scope**: 46 screens, 3 user roles, 7 implementation phases

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Multi-Tenant Data Isolation | PASS | Supabase RLS enforces per-teacher data boundaries |
| II. Arabic-First RTL | PASS | Flutter natively supports RTL; all screens use Arabic |
| III. Phased Incremental Delivery | PASS | 7 phases defined, each independently runnable |
| IV. Offline-Resilient UX | PASS | connectivity_plus + offline screen pattern |
| V. Role-Based Access Control | PASS | Three roles with Supabase auth + RLS policies |
| VI. Simplicity Over Premature Optimization | PASS | Leveraging Supabase built-ins, no custom backend |
| VII. Content Protection First | PASS | Free preview flag + RLS subscription checks |

## Project Structure

### Documentation (this feature)

```text
specs/001-thanaweya-online-platform/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── core/
│   ├── auth/
│   │   ├── auth_service.dart
│   │   ├── auth_provider.dart
│   │   └── role_guard.dart
│   ├── supabase/
│   │   ├── supabase_client.dart
│   │   └── rls_policies.sql
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_strings.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
│       ├── validators.dart
│       └── formatters.dart
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── role_selection/
│   │   └── role_selection_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── otp_screen.dart
│   ├── teacher/
│   │   ├── onboarding/
│   │   │   ├── teacher_form_screen.dart
│   │   │   ├── pending_review_screen.dart
│   │   │   └── rejection_screen.dart
│   │   ├── dashboard/
│   │   │   ├── teacher_home_screen.dart
│   │   │   └── teacher_bottom_nav.dart
│   │   ├── courses/
│   │   │   ├── courses_list_screen.dart
│   │   │   ├── create_course_screen.dart
│   │   │   ├── lessons_list_screen.dart
│   │   │   └── add_lesson_screen.dart
│   │   ├── exams/
│   │   │   ├── exams_list_screen.dart
│   │   │   ├── create_exam_screen.dart
│   │   │   ├── add_questions_screen.dart
│   │   │   └── question_bank_screen.dart
│   │   ├── students/
│   │   │   ├── students_list_screen.dart
│   │   │   ├── student_detail_screen.dart
│   │   │   └── activation_codes_screen.dart
│   │   ├── reports/
│   │   │   └── teacher_reports_screen.dart
│   │   └── settings/
│   │       └── teacher_settings_screen.dart
│   ├── student/
│   │   ├── onboarding/
│   │   │   ├── subject_selection_screen.dart
│   │   │   ├── teacher_selection_screen.dart
│   │   │   ├── student_form_screen.dart
│   │   │   └── activation_screen.dart
│   │   ├── dashboard/
│   │   │   ├── student_home_screen.dart
│   │   │   └── student_bottom_nav.dart
│   │   ├── courses/
│   │   │   ├── teacher_page_screen.dart
│   │   │   ├── course_lessons_screen.dart
│   │   │   └── video_player_screen.dart
│   │   ├── exams/
│   │   │   ├── exams_list_screen.dart
│   │   │   ├── exam_start_screen.dart
│   │   │   ├── exam_taking_screen.dart
│   │   │   ├── exam_result_screen.dart
│   │   │   └── grade_history_screen.dart
│   │   ├── comments/
│   │   │   └── lesson_comments_screen.dart
│   │   └── settings/
│   │       └── student_settings_screen.dart
│   ├── admin/
│   │   ├── dashboard/
│   │   │   └── admin_dashboard_screen.dart
│   │   ├── teachers/
│   │   │   ├── teacher_requests_screen.dart
│   │   │   └── all_teachers_screen.dart
│   │   ├── subjects/
│   │   │   └── manage_subjects_screen.dart
│   │   ├── plans/
│   │   │   ├── subscription_plans_screen.dart
│   │   │   └── edit_plan_screen.dart
│   │   └── reports/
│   │       └── platform_reports_screen.dart
│   └── shared/
│       ├── widgets/
│       │   ├── app_button.dart
│       │   ├── app_card.dart
│       │   ├── loading_indicator.dart
│       │   ├── offline_screen.dart
│       │   └── role_based_scaffold.dart
│       └── models/
│           ├── user_model.dart
│           ├── teacher_model.dart
│           ├── student_model.dart
│           ├── course_model.dart
│           ├── lesson_model.dart
│           ├── exam_model.dart
│           ├── question_model.dart
│           ├── subscription_model.dart
│           └── activation_code_model.dart
├── theme/
│   ├── app_theme.dart
│   └── dark_theme.dart
└── l10n/
    └── app_ar.dart

test/
├── unit/
├── widget/
└── integration/
```

**Structure Decision**: Single Flutter project with feature-based folder organization. Each role (teacher/student/admin) has its own feature folder. Shared code lives in `shared/`. Core infrastructure in `core/`.

## Feature Update 2026-08-05: Course Price & Intro Video

**Goal**: Teacher can set a course price (EGP) and attach an intro video (direct upload or YouTube link) from the course create/edit sheet (`courses_list_screen.dart`).

**Touch points**:

| File | Change |
|------|--------|
| `lib/features/shared/models/course_model.dart` | `price`, `introVideoUrl`, `introVideoSourceType` fields — **DONE** |
| `lib/core/supabase/storage_helper.dart` | `uploadCourseIntroVideo` — **DONE** |
| `lib/core/supabase/schema.sql` | courses: `price NUMERIC(10,2)`, `intro_video_url TEXT`, `intro_video_source_type video_source` — **DONE** |
| `lib/core/supabase/fix_complete.sql` | Idempotent migration for existing DBs (enum + columns) |
| `lib/features/teacher/data/repos/teacher_courses_repo.dart` | `createCourse` / `updateCourse` persist price + intro video |
| `lib/features/teacher/logic/teacher_courses_cubit.dart` | Pass-through params + local state sync |
| `lib/features/teacher/ui/courses/courses_list_screen.dart` | Price field, intro video picker (YouTube/upload segmented), card shows price + intro badge |

**Decisions**:
- Price is optional and nullable; an empty price = free course (matches `CourseModel.price` nullable and schema nullable column).
- Intro video mirrors the lesson-video UX (`ChalkSegmentedControl`: YouTube link / direct upload), reusing `uploadCourseIntroVideo` into the `lesson-videos` bucket.
- On create, the intro video upload runs before the course exists, so a timestamp key is used for the storage path — same pattern as the existing cover-image upload.
- `updateCourse` keeps null = "don't touch" semantics (the publish toggle relies on it); explicit `clearPrice` / `clearIntroVideo` flags let the edit sheet remove values.

## Feature Update 2026-08-05: Student Display of Price & Intro Video

**Goal**: Surface the teacher-set course price and intro video to students (browse + purchase page).

**Touch points**:

| File | Change |
|------|--------|
| `lib/features/student/data/repos/student_courses_repo.dart` | Add `price`, `intro_video_url`, `intro_video_source_type` to the selects of `getCourse`, `getMyCourses`, `getPopularCourses` |
| `lib/core/utils/formatters.dart` | New `Formatters.formatEgp` shared price helper |
| `lib/features/student/ui/courses/course_details_screen.dart` | Price in meta row + enroll CTA label; cover play button opens the intro video via `VideoPlayerScreen` |
| `lib/features/student/ui/courses/teacher_page_screen.dart` | Price + intro-video badge on course cards |
| `lib/features/student/ui/dashboard/student_home_screen.dart` | Price on popular course cards |

**Decisions**:
- Intro video plays through the existing unified `VideoPlayerScreen` (YouTube + uploaded), opened from the cover play button.
- A course without a price shows no price chip; the enroll CTA keeps its default label.
- "My courses" cards are skipped — already-enrolled students don't need pricing there.

## Feature Update 2026-08-05: Functional Subscription & Payment

**Goal**: Replace the fake payment stub with a real subscription flow: card payment creates `subscriptions` + `payments` rows; activation codes redeem atomically via a SECURITY DEFINER RPC.

**Touch points**:

| File | Change |
|------|--------|
| `lib/core/supabase/fix_complete.sql` / `schema.sql` | `payments.course_id` column; `users_insert_own_payments` + subscriptions insert/update policies; `redeem_activation_code(p_code)` RPC (atomic claim + subscription upsert) |
| `lib/features/student/data/repos/student_payments_repo.dart` | `subscribeWithPayment`, `subscribeFree`, `redeemActivationCode` |
| `lib/features/student/logic/student_payments_cubit.dart` | Matching state methods |
| `lib/core/router/app_router.dart` | `studentPaymentMethods` passes courseId/teacherId/title/price |
| `lib/features/student/ui/courses/payment_methods_screen.dart` | Rebuilt: course summary, card-payment tab, activation-code tab, real confirm, fixed success dialog → course lessons |
| `lib/features/student/ui/courses/course_details_screen.dart` | Enroll CTA passes course context; free courses subscribe directly |

**Decisions**:
- Payments are recorded in-app (gateway `paymob` placeholder); real Paymob card capture is a later swap-in.
- Subscription is per-teacher (matches the `subscriptions` UNIQUE(student_id, teacher_id) schema + RLS), 1-year expiry.
- Paid subscription + payment record are created atomically via the `create_subscription_with_payment` RPC (SECURITY DEFINER) — no partial state, and renewals upsert on the `(student_id, teacher_id)` unique constraint.
- Activation codes use the `redeem_activation_code` RPC (row lock `FOR UPDATE`) so two students can't redeem the same code; the old direct-update RLS policy is dropped (redundant attack surface).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | All principles satisfied | N/A |
