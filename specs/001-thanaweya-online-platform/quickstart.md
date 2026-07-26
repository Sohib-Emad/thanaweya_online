# Quickstart: Thanaweya Online Platform

**Date**: 2026-07-21

## Prerequisites

- Flutter SDK 3.12+
- Dart 3.12+
- Supabase account (free tier works for development)
- Android Studio / Xcode for device testing

## Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Create a Supabase project at supabase.com
4. Run the SQL migrations from `lib/core/supabase/rls_policies.sql` in Supabase SQL Editor
5. Copy `.env.example` to `.env` and fill in Supabase URL and anon key
6. Run `flutter run` to launch the app

## Validation Scenarios

### Scenario 1: Teacher Onboarding (E2E)

1. Launch app → Splash screen → Role selection
2. Select "I am a teacher" → Fill in registration form → Submit
3. See "pending review" screen
4. In Supabase, update teacher approval_status to 'approved'
5. Reopen app → Teacher dashboard appears with empty courses

### Scenario 2: Course Creation & Student Viewing

1. As approved teacher: Create course "الرياضيات - الفصل الأول"
2. Add 3 lessons with YouTube links → Verify thumbnails load
3. Mark lesson 1 as free preview
4. As a new student: Register, select math subject, choose this teacher
5. Enter activation code → Subscription active
6. Open home → See teacher tab → See course → Lesson 1 accessible without subscription, lessons 2-3 require subscription

### Scenario 3: Exam Flow

1. As teacher: Create exam "امتحان الفصل" with 5 MCQ questions
2. Set duration to 30 minutes, publish exam
3. As student: Navigate to exams → Start exam → Answer questions → Submit
4. See auto-graded result (score out of total)
5. As teacher: View student's score in reports

### Scenario 4: Offline Handling

1. Enable airplane mode
2. Launch app → See offline screen with retry button
3. Disable airplane mode → Tap retry → App loads normally

### Scenario 5: Super Admin Approval

1. Register a new teacher
2. Log in as Super Admin → See pending request
3. Approve teacher → Teacher gains dashboard access
4. Register another teacher → Reject with reason → Teacher sees rejection screen
