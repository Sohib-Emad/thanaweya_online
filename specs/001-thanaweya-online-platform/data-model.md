# Data Model: Thanaweya Online Platform

**Date**: 2026-07-21

## Entity Relationship Overview

```
User (base) ─┬─ Teacher ──── Course ──── Lesson
              │                 │
              │                 └─── Exam ──── Question
              │
              └─ Student ──── Subscription ──── Teacher
                               │
                               └─── ActivationCode
```

## Entities

### users
Base authentication entity managed by Supabase Auth.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | References auth.users |
| email | text | Unique |
| full_name | text | |
| phone | text | |
| role | enum | 'super_admin' / 'teacher' / 'student' |
| avatar_url | text | Nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### teachers
Extended teacher profile. One-to-one with users where role='teacher'.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | References users.id |
| subject_id | uuid (FK) | References subjects.id |
| stage | enum | 'first' / 'second' / 'third' (secondary school year) |
| bio | text | Nullable, short description |
| approval_status | enum | 'pending' / 'approved' / 'rejected' |
| rejection_reason | text | Nullable |
| subscription_plan_id | uuid (FK) | References subscription_plans.id, nullable |
| subscription_expires_at | timestamptz | Nullable |
| created_at | timestamptz | |

### students
Extended student profile. One-to-one with users where role='student'.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | References users.id |
| grade_level | enum | 'first' / 'second' / 'third' |
| parent_phone | text | |
| created_at | timestamptz | |

### subjects
Platform-wide subjects managed by Super Admin.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| name_ar | text | Arabic name (e.g., رياضيات) |
| name_en | text | English name (e.g., Mathematics) |
| icon_name | text | Icon identifier |
| is_active | boolean | Default true |
| display_order | integer | |
| created_at | timestamptz | |

### courses
Teacher's courses. Each course belongs to one teacher.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| teacher_id | uuid (FK) | References teachers.id |
| title | text | |
| description | text | Nullable |
| cover_image_url | text | Nullable |
| is_published | boolean | Default false |
| order | integer | Display order |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### lessons
Video lessons within a course. Supports YouTube and uploaded videos.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| course_id | uuid (FK) | References courses.id |
| title | text | |
| description | text | Nullable |
| video_source_type | enum | 'youtube' / 'upload' |
| video_url_or_id | text | YouTube URL/ID or Bunny.net video ID |
| duration_seconds | integer | Nullable, auto-fetched for YouTube |
| thumbnail_url | text | Nullable, auto-fetched for YouTube |
| is_free_preview | boolean | Default false |
| order | integer | Display order within course |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### exams
Exams created by teachers, linked to courses.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| teacher_id | uuid (FK) | References teachers.id |
| course_id | uuid (FK) | References courses.id, nullable |
| title | text | |
| duration_minutes | integer | |
| start_at | timestamptz | When exam becomes available |
| end_at | timestamptz | When exam stops being available |
| max_score | integer | Computed from questions |
| is_published | boolean | Default false |
| created_at | timestamptz | |

### questions
Questions within an exam.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| exam_id | uuid (FK) | References exams.id |
| question_type | enum | 'mcq' / 'true_false' / 'essay' |
| text | text | Question text |
| options | jsonb | Array of choices (for MCQ/TF) |
| correct_answer | text | Correct option index or value |
| points | integer | Score for this question |
| order | integer | |
| created_at | timestamptz | |

### subscriptions
Links students to teachers. The core access control entity.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| student_id | uuid (FK) | References students.id |
| teacher_id | uuid (FK) | References teachers.id |
| activation_code_id | uuid (FK) | References activation_codes.id, nullable |
| status | enum | 'active' / 'suspended' / 'expired' |
| starts_at | timestamptz | |
| expires_at | timestamptz | Nullable (null = lifetime) |
| created_at | timestamptz | |

Unique constraint: (student_id, teacher_id)

### activation_codes
Bulk-generated codes for student subscription.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| teacher_id | uuid (FK) | References teachers.id |
| course_id | uuid (FK) | References courses.id, nullable |
| code | text | Unique, random string |
| is_used | boolean | Default false |
| used_by | uuid (FK) | References students.id, nullable |
| used_at | timestamptz | Nullable |
| created_at | timestamptz | |

### subscription_plans
Dynamic plans managed by Super Admin.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| name | text | e.g., "الباقة الشهرية" |
| billing_period | enum | 'monthly' / 'term' / 'yearly' |
| price | numeric | In EGP |
| max_students | integer | Nullable (unlimited) |
| max_courses | integer | Nullable (unlimited) |
| storage_limit_mb | integer | Nullable |
| is_active | boolean | Default true |
| display_order | integer | |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### payments
Payment transaction records.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| payer_id | uuid (FK) | References users.id |
| payer_type | enum | 'teacher_subscription' / 'student_subscription' |
| plan_id | uuid (FK) | References subscription_plans.id, nullable |
| amount | numeric | In EGP |
| payment_gateway | enum | 'paymob' / 'fawry' / 'kashier' |
| gateway_transaction_id | text | |
| status | enum | 'pending' / 'success' / 'failed' / 'refunded' |
| created_at | timestamptz | |

### lesson_progress
Tracks student video viewing progress.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| student_id | uuid (FK) | References students.id |
| lesson_id | uuid (FK) | References lessons.id |
| is_completed | boolean | Default false |
| watched_seconds | integer | |
| last_watched_at | timestamptz | |

Unique constraint: (student_id, lesson_id)

### exam_submissions
Student exam attempts.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| exam_id | uuid (FK) | References exams.id |
| student_id | uuid (FK) | References students.id |
| score | integer | Nullable until graded |
| total_points | integer | |
| started_at | timestamptz | |
| submitted_at | timestamptz | |
| answers | jsonb | Student's answers per question |

### comments
Lesson comments from students and teachers.

| Field | Type | Notes |
|-------|------|-------|
| id | uuid (PK) | |
| lesson_id | uuid (FK) | References lessons.id |
| author_id | uuid (FK) | References users.id |
| text | text | |
| created_at | timestamptz | |

## Key RLS Policies

```sql
-- Teachers can only see their own data
CREATE POLICY "teachers_own_data" ON courses
  FOR ALL USING (teacher_id = auth.uid());

-- Students can only see content from subscribed teachers
CREATE POLICY "students_subscribed_content" ON lessons
  FOR SELECT USING (
    course_id IN (
      SELECT c.id FROM courses c
      JOIN subscriptions s ON s.teacher_id = c.teacher_id
      WHERE s.student_id = auth.uid() AND s.status = 'active'
    )
    OR is_free_preview = true
  );

-- Super Admin can see everything
CREATE POLICY "admin_full_access" ON teachers
  FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'super_admin')
  );
```
