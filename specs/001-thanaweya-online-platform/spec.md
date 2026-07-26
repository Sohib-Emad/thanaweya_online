# Feature Specification: Thanaweya Online Platform

**Feature Branch**: `001-thanaweya-online-platform`

**Created**: 2026-07-21

**Status**: Draft

**Input**: SaaS platform for Egyptian secondary school teachers to upload video courses, create exams, and manage students. Students subscribe to one or more teachers and access their content.

## User Scenarios & Testing

### User Story 1 - Teacher Registration & Approval (Priority: P1)

A teacher signs up with their personal information, subject, and credentials. Their account enters a "pending review" state. A Super Admin reviews and approves the teacher. Once approved, the teacher gains access to their dashboard where they can create courses, upload videos, and manage students.

**Why this priority**: Without teachers, there is no content. Teacher onboarding is the entry point for the entire supply side of the platform.

**Independent Test**: Can be fully tested by registering a teacher, having a Super Admin approve them, and verifying the teacher can access their dashboard. Delivers a complete teacher onboarding flow.

**Acceptance Scenarios**:

1. **Given** a new teacher visits the app, **When** they select "I am a teacher" and fill in their data (name, subject, phone, email, password), **Then** their account is created with "pending review" status.
2. **Given** a teacher is in "pending review" status, **When** they open the app, **Then** they see a waiting screen with a status update button.
3. **Given** a Super Admin reviews a pending teacher, **When** they approve the teacher, **Then** the teacher receives access to the full dashboard.
4. **Given** a Super Admin rejects a teacher, **When** they provide a rejection reason, **Then** the teacher sees the rejection screen with the reason and an option to edit and resubmit.
5. **Given** a teacher is approved, **When** they log in, **Then** they see the teacher dashboard with navigation to courses, students, reports, and settings.

---

### User Story 2 - Course & Video Content Management (Priority: P1)

A teacher creates courses, adds lessons to each course, and uploads video content for each lesson. Videos can be either uploaded directly or linked from YouTube. Each lesson can be marked as a free preview or paid content.

**Why this priority**: Video courses are the core value proposition. Without content, students have nothing to consume. This is the second half of the supply-side MVP.

**Independent Test**: Can be tested by a logged-in approved teacher creating a course, adding lessons with YouTube links, and verifying the lessons appear in the course management list with correct thumbnails and metadata.

**Acceptance Scenarios**:

1. **Given** a teacher is on the courses screen, **When** they tap the add button, **Then** they can enter a course name, description, and cover image.
2. **Given** a teacher opens a course, **When** they add a new lesson, **Then** they can choose between uploading a video or pasting a YouTube link.
3. **Given** a teacher pastes a YouTube link, **When** they tap preview, **Then** the system fetches and displays the video thumbnail and duration.
4. **Given** a teacher saves a lesson, **When** the lesson is saved, **Then** it appears in the course lesson list in the correct order.
5. **Given** a lesson is marked as "free preview", **When** a student views the course, **Then** that lesson is accessible without a subscription.

---

### User Story 3 - Student Onboarding & Subscription (Priority: P2)

A student selects one or more subjects, chooses a teacher for each subject, registers with personal information, and activates their subscription using an activation code or electronic payment. The student then gains access to their selected teachers' content.

**Why this priority**: Without students, the platform has no demand side. This completes the core loop: teacher creates content, student accesses it.

**Independent Test**: Can be tested by registering a student, selecting subjects and teachers, entering an activation code, and verifying the student sees the teacher's courses on their home screen.

**Acceptance Scenarios**:

1. **Given** a new student opens the app, **When** they select "I am a student", **Then** they see a grid of subjects to choose from (multi-select).
2. **Given** a student has selected subjects, **When** they proceed, **Then** for each subject they see available teachers and can select one.
3. **Given** a student fills in their personal data, **When** they submit, **Then** they are prompted for an activation code or payment.
4. **Given** a student enters a valid activation code, **When** the code is verified, **Then** their subscription is activated and they can access the teacher's content.
5. **Given** a student is subscribed to multiple teachers, **When** they open the home screen, **Then** they see tabs for each teacher with that teacher's courses listed below.

---

### User Story 4 - Student Video Learning Experience (Priority: P2)

A student navigates to a course, views the lesson list with progress indicators, and watches video lessons in a unified player. The player handles both YouTube and uploaded videos with the same interface. Progress is tracked.

**Why this priority**: The learning experience is the core value for students. Watching videos and tracking progress completes the educational loop.

**Independent Test**: Can be tested by a subscribed student opening a course, watching a YouTube lesson, marking it complete, and verifying the progress bar updates.

**Acceptance Scenarios**:

1. **Given** a student opens a course, **When** they view the lesson list, **Then** completed lessons show a green checkmark and an overall progress bar is displayed.
2. **Given** a student taps a lesson, **When** the video loads, **Then** it plays in a unified player regardless of whether it is YouTube or uploaded content.
3. **Given** a student watches a video to completion, **When** the video ends, **Then** the lesson is marked complete and progress updates.
4. **Given** a student is viewing a YouTube video, **When** the player loads, **Then** only the video plays without related video suggestions or YouTube branding (simplified controls).

---

### User Story 5 - Exam System (Priority: P3)

A teacher creates exams linked to courses, adds questions (multiple choice, true/false, essay), and sets time limits. Students take exams within the time limit, receive automatic grading for objective questions, and view results.

**Why this priority**: Exams add assessment capability, completing the educational cycle. They are more complex technically and can follow the core content delivery.

**Independent Test**: Can be tested by a teacher creating an exam with 5 multiple-choice questions, a student taking the exam within the time limit, and both seeing the auto-graded result.

**Acceptance Scenarios**:

1. **Given** a teacher creates an exam, **When** they set the title, course, duration, and start/end times, **Then** the exam is saved and appears in the exam list.
2. **Given** a teacher adds questions, **When** they select a question type and enter the question and choices, **Then** the question is saved with the correct answer marked.
3. **Given** a student starts an exam, **When** the timer begins, **Then** they see one question at a time with navigation and a countdown timer.
4. **Given** a student submits an exam, **When** grading is complete, **Then** they see their score and can review correct/incorrect answers.
5. **Given** a student views their grades, **When** they open the grade history, **Then** they see a list of all exams with scores and a performance chart.

---

### User Story 6 - Student Management by Teacher (Priority: P3)

A teacher views a list of their subscribed students, sees individual student progress and exam scores, can block or unblock students, and generates activation codes for student subscriptions.

**Why this priority**: Student management gives teachers control over their classroom. Activation codes are the primary mechanism for student subscription in the current design.

**Independent Test**: Can be tested by a teacher viewing their student list, generating 5 activation codes, and verifying a student can use one to subscribe.

**Acceptance Scenarios**:

1. **Given** a teacher opens the students screen, **When** the list loads, **Then** they see all subscribed students with their names, status (active/suspended/blocked), and subscription date.
2. **Given** a teacher taps a student, **When** the student detail opens, **Then** they see the student's progress in each course and exam scores.
3. **Given** a teacher generates activation codes, **When** they select a course and quantity, **Then** a list of unique codes is generated and can be copied or exported.
4. **Given** a teacher blocks a student, **When** the block is applied, **Then** the student can no longer access the teacher's content.

---

### User Story 7 - Super Admin Management (Priority: P4)

A Super Admin manages the entire platform: approves new teacher registrations, manages available subjects, views platform-wide reports, and manages subscription plans.

**Why this priority**: Super Admin functionality is needed for governance but can initially be handled manually through Supabase Studio. Full in-app admin screens come later.

**Independent Test**: Can be tested by a Super Admin logging in, viewing pending teacher requests, approving a teacher, and verifying the teacher gains access.

**Acceptance Scenarios**:

1. **Given** a Super Admin opens the app, **When** they log in with admin credentials, **Then** they see the admin dashboard with pending teacher requests, total teachers, and total students.
2. **Given** pending teacher requests exist, **When** the Super Admin views the list, **Then** they see each teacher's details with approve/reject actions.
3. **Given** a Super Admin approves a teacher, **When** the approval is submitted, **Then** the teacher's status changes to "approved" and they gain dashboard access.
4. **Given** a Super Admin manages subjects, **When** they add or remove a subject, **Then** the change is reflected in the student subject selection screen.

---

### Edge Cases

- What happens when a student tries to access a course from a teacher they are not subscribed to?
- What happens when a teacher's subscription expires while students are enrolled?
- What happens when a YouTube video is deleted or made private after being added to a lesson?
- What happens when a student loses internet mid-exam?
- What happens when a teacher uploads a very large video file?
- What happens when two students try to use the same activation code simultaneously?
- What happens when a Super Admin tries to approve themselves as a teacher?

## Requirements

### Functional Requirements

- **FR-001**: System MUST support three distinct user roles: Super Admin, Teacher, and Student
- **FR-002**: System MUST enforce Row Level Security so each teacher only accesses their own data
- **FR-003**: System MUST support Arabic RTL interface as the primary language
- **FR-004**: Teachers MUST be able to register and enter a "pending review" state
- **FR-005**: Super Admin MUST be able to approve or reject teacher registrations with a reason
- **FR-006**: Teachers MUST be able to create courses with name, description, and cover image
- **FR-007**: Teachers MUST be able to add lessons to courses with video content from YouTube or direct upload
- **FR-008**: Teachers MUST be able to mark lessons as free preview or paid
- **FR-009**: Students MUST be able to select multiple subjects during onboarding
- **FR-010**: Students MUST be able to choose a teacher for each selected subject
- **FR-011**: Students MUST be able to subscribe using activation codes generated by the teacher
- **FR-012**: Students MUST see a tabbed home screen organized by subscribed teachers
- **FR-013**: Students MUST have a unified video player that handles both YouTube and uploaded content
- **FR-014**: System MUST track video viewing progress per student per lesson
- **FR-015**: Teachers MUST be able to create exams with multiple choice, true/false, and essay questions
- **FR-016**: Exams MUST have configurable time limits with a countdown timer
- **FR-017**: System MUST auto-grade multiple choice and true/false questions
- **FR-018**: Students MUST be able to view their exam scores and grade history
- **FR-019**: Teachers MUST be able to view student list with subscription status and progress
- **FR-020**: Teachers MUST be able to generate bulk activation codes for courses
- **FR-021**: Super Admin MUST be able to manage available subjects in the system
- **FR-022**: System MUST show an offline screen when network is unavailable
- **FR-023**: System MUST support dynamic subscription plans managed by Super Admin
- **FR-024**: Teachers MUST be able to view reports with charts showing student performance
- **FR-025**: System MUST support comments on lessons for student-teacher interaction

### Key Entities

- **User**: Base entity for all roles. Contains authentication credentials, role type, and profile data.
- **Teacher**: Extends User. Contains subject, bio, approval status, subscription plan.
- **Student**: Extends User. Contains grade level, parent phone, linked teachers.
- **Course**: Belongs to a Teacher. Contains name, description, cover image, lessons list.
- **Lesson**: Belongs to a Course. Contains title, video source type (upload/youtube), video URL, duration, order, free preview flag.
- **Exam**: Belongs to a Teacher/Course. Contains title, time limit, start/end dates, questions list.
- **Question**: Belongs to an Exam. Contains type (MCQ/TF/essay), text, choices, correct answer, points.
- **Subscription**: Links a Student to a Teacher. Contains activation code, status, start/end dates.
- **ActivationCode**: Generated by Teacher. Contains code string, course reference, usage status.
- **SubscriptionPlan**: Managed by Super Admin. Contains name, price, billing period, limits.
- **Payment**: Records payment transactions. Contains payer, amount, gateway, status.
- **Comment**: On lessons. Contains author, text, timestamp.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A teacher can register, get approved, create a course with 3 lessons, and have it visible to students within 30 minutes of first app launch
- **SC-002**: A student can complete the full onboarding flow (select subjects, choose teacher, activate subscription) in under 5 minutes
- **SC-003**: Video playback starts within 3 seconds on a stable connection for both YouTube and uploaded content
- **SC-004**: The app handles network disconnection gracefully without crashes or data loss
- **SC-005**: A student can take a 20-question exam and receive their auto-graded results within 10 seconds of submission
- **SC-006**: Teachers can generate up to 100 activation codes in a single batch operation
- **SC-007**: The Super Admin can approve a pending teacher within 2 taps from the admin dashboard
- **SC-008**: All screens render correctly in Arabic RTL layout on both mobile and tablet
- **SC-009**: Dark mode can be enabled without breaking any screen layout (deferred but architecture must support it)
- **SC-010**: The app supports the complete 46-screen specification across all three roles

## Assumptions

- Teachers have basic smartphone literacy and can navigate mobile apps
- Students are 15-18 years old (secondary school age in Egypt)
- Internet connectivity is generally available but may be intermittent
- Supabase will handle authentication, database, storage, and realtime subscriptions
- YouTube integration uses the youtube_player_flutter package for in-app playback
- Payment gateway integration (Paymob) will be added in Phase 3 but activation codes are the primary method initially
- Dark mode is deferred but the color system must accommodate it from the start
- The platform targets the Egyptian market with pricing in Egyptian Pounds (EGP)
- Rabbit ears ( Bunny.net or Cloudflare Stream) will be used for direct video uploads, not YouTube, for content protection
