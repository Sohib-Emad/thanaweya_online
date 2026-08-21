-- ============================================================
-- Thanaweya Online Platform - Complete Database Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. ENUMS
-- ============================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('super_admin', 'teacher', 'student');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'teacher_stage') THEN
    CREATE TYPE teacher_stage AS ENUM ('first', 'second', 'third');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'approval_status') THEN
    CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_grade') THEN
    CREATE TYPE student_grade AS ENUM ('first', 'second', 'third');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'video_source') THEN
    CREATE TYPE video_source AS ENUM ('youtube', 'upload');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'question_type') THEN
    CREATE TYPE question_type AS ENUM ('mcq', 'true_false', 'essay');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_status') THEN
    CREATE TYPE subscription_status AS ENUM ('active', 'suspended', 'expired');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'billing_period') THEN
    CREATE TYPE billing_period AS ENUM ('monthly', 'term', 'yearly');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payer_type') THEN
    CREATE TYPE payer_type AS ENUM ('teacher_subscription', 'student_subscription');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_gateway') THEN
    CREATE TYPE payment_gateway AS ENUM ('paymob', 'fawry', 'kashier');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
    CREATE TYPE payment_status AS ENUM ('pending', 'success', 'failed', 'refunded');
  END IF;
END $$;

-- ============================================================
-- 2. TABLES
-- ============================================================

-- Users (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'student',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subjects
CREATE TABLE IF NOT EXISTS public.subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  icon_name TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subscription Plans
CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  billing_period billing_period NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  max_students INTEGER,
  max_courses INTEGER,
  storage_limit_mb INTEGER,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Teachers
CREATE TABLE IF NOT EXISTS public.teachers (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  subject_id UUID REFERENCES public.subjects(id) ON DELETE SET NULL,
  stage teacher_stage NOT NULL,
  bio TEXT,
  approval_status approval_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  subscription_plan_id UUID REFERENCES public.subscription_plans(id),
  subscription_expires_at TIMESTAMPTZ,
  avatar_url TEXT,
  id_card_front_url TEXT,
  id_card_back_url TEXT,
  teacher_proof_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Students
CREATE TABLE IF NOT EXISTS public.students (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  grade_level student_grade NOT NULL,
  parent_phone TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Courses
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  price NUMERIC(10,2),
  intro_video_url TEXT,
  intro_video_source_type video_source NOT NULL DEFAULT 'youtube',
  is_published BOOLEAN NOT NULL DEFAULT false,
  "order" INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Lessons
CREATE TABLE IF NOT EXISTS public.lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_source_type video_source NOT NULL DEFAULT 'youtube',
  video_url_or_id TEXT NOT NULL,
  duration_seconds INTEGER,
  thumbnail_url TEXT,
  is_free_preview BOOLEAN NOT NULL DEFAULT false,
  "order" INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Exams
CREATE TABLE IF NOT EXISTS public.exams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  max_score INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Questions
CREATE TABLE IF NOT EXISTS public.questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
  question_type question_type NOT NULL DEFAULT 'mcq',
  text TEXT NOT NULL,
  options JSONB DEFAULT '[]'::jsonb,
  correct_answer TEXT,
  points INTEGER NOT NULL DEFAULT 1,
  "order" INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subscriptions
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  activation_code_id UUID,
  status subscription_status NOT NULL DEFAULT 'active',
  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, teacher_id)
);

-- Keep existing databases in sync (column may already exist)
ALTER TABLE public.subscriptions
  ADD COLUMN IF NOT EXISTS activation_code_id UUID;

-- Activation Codes (one-time redeemable codes)
CREATE TABLE IF NOT EXISTS public.activation_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  code TEXT UNIQUE NOT NULL,
  is_used BOOLEAN NOT NULL DEFAULT false,
  used_by UUID REFERENCES public.students(id) ON DELETE SET NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Payments
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payer_id UUID NOT NULL REFERENCES public.users(id),
  payer_type payer_type NOT NULL,
  plan_id UUID REFERENCES public.subscription_plans(id),
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  amount NUMERIC(10,2) NOT NULL,
  payment_gateway payment_gateway NOT NULL,
  gateway_transaction_id TEXT,
  status payment_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Lesson Progress
CREATE TABLE IF NOT EXISTS public.lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  watched_seconds INTEGER NOT NULL DEFAULT 0,
  last_watched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, lesson_id)
);

-- Exam Submissions
CREATE TABLE IF NOT EXISTS public.exam_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  score INTEGER,
  total_points INTEGER NOT NULL DEFAULT 0,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  submitted_at TIMESTAMPTZ,
  answers JSONB DEFAULT '{}'::jsonb
);

-- Comments
CREATE TABLE IF NOT EXISTS public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Bookmarks
CREATE TABLE IF NOT EXISTS public.bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, course_id)
);

-- Course Reviews
CREATE TABLE IF NOT EXISTS public.course_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  text TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(course_id, student_id)
);

-- Payment Methods (cards)
CREATE TABLE IF NOT EXISTS public.payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  card_holder TEXT NOT NULL,
  card_last4 TEXT NOT NULL,
  card_brand TEXT,
  expiry_month INTEGER,
  expiry_year INTEGER,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 3. INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

CREATE INDEX IF NOT EXISTS idx_teachers_approval ON public.teachers(approval_status);
CREATE INDEX IF NOT EXISTS idx_teachers_subject ON public.teachers(subject_id);

CREATE INDEX IF NOT EXISTS idx_courses_teacher ON public.courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_courses_published ON public.courses(is_published);

CREATE INDEX IF NOT EXISTS idx_lessons_course ON public.lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_order ON public.lessons(course_id, "order");

CREATE INDEX IF NOT EXISTS idx_exams_teacher ON public.exams(teacher_id);
CREATE INDEX IF NOT EXISTS idx_exams_course ON public.exams(course_id);
CREATE INDEX IF NOT EXISTS idx_exams_dates ON public.exams(start_at, end_at);

CREATE INDEX IF NOT EXISTS idx_questions_exam ON public.questions(exam_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_student ON public.subscriptions(student_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_teacher ON public.subscriptions(teacher_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);

CREATE INDEX IF NOT EXISTS idx_payments_payer ON public.payments(payer_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);

CREATE INDEX IF NOT EXISTS idx_lesson_progress_student ON public.lesson_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_lesson ON public.lesson_progress(lesson_id);

CREATE INDEX IF NOT EXISTS idx_exam_submissions_exam ON public.exam_submissions(exam_id);
CREATE INDEX IF NOT EXISTS idx_exam_submissions_student ON public.exam_submissions(student_id);

CREATE INDEX IF NOT EXISTS idx_comments_lesson ON public.comments(lesson_id);
CREATE INDEX IF NOT EXISTS idx_comments_author ON public.comments(author_id);

-- ============================================================
-- 4. FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_users_updated_at ON public.users;
CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_courses_updated_at ON public.courses;
CREATE TRIGGER trigger_courses_updated_at
  BEFORE UPDATE ON public.courses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_lessons_updated_at ON public.lessons;
CREATE TRIGGER trigger_lessons_updated_at
  BEFORE UPDATE ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_plans_updated_at ON public.subscription_plans;
CREATE TRIGGER trigger_plans_updated_at
  BEFORE UPDATE ON public.subscription_plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- NOTE: The on_auth_user_created trigger was deliberately REMOVED (see
-- fix_auth_trigger.sql / fix_complete.sql) because it caused signup errors.
-- The app creates public.users rows itself from the client (see
-- _ensureStudentProfileExists) and via the SECURITY DEFINER RPCs below.
-- Auto-compute exam max_score from questions
CREATE OR REPLACE FUNCTION compute_exam_max_score()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.exams
  SET max_score = (
    SELECT COALESCE(SUM(points), 0)
    FROM public.questions
    WHERE exam_id = COALESCE(NEW.exam_id, OLD.exam_id)
  )
  WHERE id = COALESCE(NEW.exam_id, OLD.exam_id);
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_questions_score_update ON public.questions;
CREATE TRIGGER trigger_questions_score_update
  AFTER INSERT OR UPDATE OR DELETE ON public.questions
  FOR EACH ROW EXECUTE FUNCTION compute_exam_max_score();

-- Auto-update subscription status on expiry
CREATE OR REPLACE FUNCTION check_subscription_expiry()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.expires_at IS NOT NULL AND NEW.expires_at < NOW() AND NEW.status = 'active' THEN
    NEW.status = 'expired';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_subscription_expiry ON public.subscriptions;
CREATE TRIGGER trigger_subscription_expiry
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION check_subscription_expiry();

-- ============================================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;

-- NOTE: policies created by other migration files (fix_rls_inserts.sql,
-- migration_exam_attempts_lesson_docs.sql, ...) are deliberately NOT wiped
-- here — only the policies this file owns are dropped+recreated below.
-- Each CREATE POLICY is preceded by DROP POLICY IF EXISTS to stay idempotent.
-- ============================================================
-- USERS
-- ============================================================

DROP POLICY IF EXISTS "users_select_own" ON public.users;
CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (id = auth.uid());

DROP POLICY IF EXISTS "users_select_teacher_profiles" ON public.users;
CREATE POLICY "users_select_teacher_profiles" ON public.users
  FOR SELECT TO anon, authenticated
  USING (id IN (SELECT id FROM public.teachers WHERE approval_status = 'approved'));

DROP POLICY IF EXISTS "teachers_select_subscribed_students" ON public.users;
CREATE POLICY "teachers_select_subscribed_students" ON public.users
  FOR SELECT USING (
    id IN (
      SELECT student_id FROM public.subscriptions
      WHERE teacher_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "users_update_own" ON public.users;
CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE USING (id = auth.uid());

DROP POLICY IF EXISTS "admin_select_all_users" ON public.users;
CREATE POLICY "admin_select_all_users" ON public.users
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_update_all_users" ON public.users;
CREATE POLICY "admin_update_all_users" ON public.users
  FOR UPDATE USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- Safe public profile view (id, full_name, avatar_url only — no email/phone)
CREATE OR REPLACE VIEW public.user_profiles AS
SELECT id, full_name, avatar_url
FROM public.users;

GRANT SELECT ON public.user_profiles TO anon, authenticated;

-- ============================================================
-- TEACHERS
-- ============================================================

DROP POLICY IF EXISTS "teachers_select_own" ON public.teachers;
CREATE POLICY "teachers_select_own" ON public.teachers
  FOR SELECT USING (id = auth.uid());

DROP POLICY IF EXISTS "teachers_update_own" ON public.teachers;
CREATE POLICY "teachers_update_own" ON public.teachers
  FOR UPDATE USING (id = auth.uid());

DROP POLICY IF EXISTS "admin_select_all_teachers" ON public.teachers;
CREATE POLICY "admin_select_all_teachers" ON public.teachers
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_manage_teachers" ON public.teachers;
CREATE POLICY "admin_manage_teachers" ON public.teachers
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "public_select_approved_teachers" ON public.teachers;
CREATE POLICY "public_select_approved_teachers" ON public.teachers
  FOR SELECT USING (approval_status = 'approved');

-- ============================================================
-- STUDENTS
-- ============================================================

DROP POLICY IF EXISTS "students_select_own" ON public.students;
CREATE POLICY "students_select_own" ON public.students
  FOR SELECT USING (id = auth.uid());

DROP POLICY IF EXISTS "students_update_own" ON public.students;
CREATE POLICY "students_update_own" ON public.students
  FOR UPDATE USING (id = auth.uid());

DROP POLICY IF EXISTS "admin_select_all_students" ON public.students;
CREATE POLICY "admin_select_all_students" ON public.students
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "teachers_select_subscribed_students" ON public.students;
CREATE POLICY "teachers_select_subscribed_students" ON public.students
  FOR SELECT USING (
    id IN (
      SELECT student_id FROM public.subscriptions
      WHERE teacher_id = auth.uid()
    )
  );

-- ============================================================
-- SUBJECTS
-- ============================================================

DROP POLICY IF EXISTS "subjects_select_active" ON public.subjects;
CREATE POLICY "subjects_select_active" ON public.subjects
  FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "subjects_select_all" ON public.subjects;
CREATE POLICY "subjects_select_all" ON public.subjects
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "admin_manage_subjects" ON public.subjects;
CREATE POLICY "admin_manage_subjects" ON public.subjects
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- COURSES
-- ============================================================

DROP POLICY IF EXISTS "teachers_manage_own_courses" ON public.courses;
CREATE POLICY "teachers_manage_own_courses" ON public.courses
  FOR ALL USING (teacher_id = auth.uid());

DROP POLICY IF EXISTS "students_view_subscribed_courses" ON public.courses;
CREATE POLICY "students_view_subscribed_courses" ON public.courses
  FOR SELECT USING (
    is_published = true AND (
      teacher_id IN (
        SELECT teacher_id FROM public.subscriptions
        WHERE student_id = auth.uid() AND status = 'active'
      )
    )
  );

DROP POLICY IF EXISTS "students_view_free_preview_courses" ON public.courses;
CREATE POLICY "students_view_free_preview_courses" ON public.courses
  FOR SELECT USING (is_published = true);

DROP POLICY IF EXISTS "admin_select_all_courses" ON public.courses;
CREATE POLICY "admin_select_all_courses" ON public.courses
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- LESSONS
-- ============================================================

DROP POLICY IF EXISTS "teachers_manage_own_lessons" ON public.lessons;
CREATE POLICY "teachers_manage_own_lessons" ON public.lessons
  FOR ALL USING (
    course_id IN (
      SELECT id FROM public.courses WHERE teacher_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "students_view_subscribed_lessons" ON public.lessons;
CREATE POLICY "students_view_subscribed_lessons" ON public.lessons
  FOR SELECT USING (
    is_free_preview = true OR
    course_id IN (
      SELECT c.id FROM public.courses c
      JOIN public.subscriptions s ON s.teacher_id = c.teacher_id
      WHERE s.student_id = auth.uid() AND s.status = 'active'
    )
  );

DROP POLICY IF EXISTS "admin_select_all_lessons" ON public.lessons;
CREATE POLICY "admin_select_all_lessons" ON public.lessons
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- EXAMS
-- ============================================================

DROP POLICY IF EXISTS "teachers_manage_own_exams" ON public.exams;
CREATE POLICY "teachers_manage_own_exams" ON public.exams
  FOR ALL USING (teacher_id = auth.uid());

DROP POLICY IF EXISTS "students_view_available_exams" ON public.exams;
CREATE POLICY "students_view_available_exams" ON public.exams
  FOR SELECT USING (
    is_published = true AND
    NOW() BETWEEN start_at AND end_at AND
    teacher_id IN (
      SELECT teacher_id FROM public.subscriptions
      WHERE student_id = auth.uid() AND status = 'active'
    )
  );

DROP POLICY IF EXISTS "admin_select_all_exams" ON public.exams;
CREATE POLICY "admin_select_all_exams" ON public.exams
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- QUESTIONS
-- ============================================================

DROP POLICY IF EXISTS "teachers_manage_own_questions" ON public.questions;
CREATE POLICY "teachers_manage_own_questions" ON public.questions
  FOR ALL USING (
    exam_id IN (
      SELECT id FROM public.exams WHERE teacher_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "students_view_exam_questions" ON public.questions;
CREATE POLICY "students_view_exam_questions" ON public.questions
  FOR SELECT USING (
    exam_id IN (
      SELECT id FROM public.exams
      WHERE is_published = true AND
      teacher_id IN (
        SELECT teacher_id FROM public.subscriptions
        WHERE student_id = auth.uid() AND status = 'active'
      )
    )
  );

-- ============================================================
-- SUBSCRIPTIONS
-- ============================================================

DROP POLICY IF EXISTS "students_view_own_subscriptions" ON public.subscriptions;
CREATE POLICY "students_view_own_subscriptions" ON public.subscriptions
  FOR SELECT USING (student_id = auth.uid());

DROP POLICY IF EXISTS "teachers_view_own_subscriptions" ON public.subscriptions;
CREATE POLICY "teachers_view_own_subscriptions" ON public.subscriptions
  FOR SELECT USING (teacher_id = auth.uid());

DROP POLICY IF EXISTS "admin_manage_subscriptions" ON public.subscriptions;
CREATE POLICY "admin_manage_subscriptions" ON public.subscriptions
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- SUBSCRIPTION PLANS
-- ============================================================

DROP POLICY IF EXISTS "plans_select_active" ON public.subscription_plans;
CREATE POLICY "plans_select_active" ON public.subscription_plans
  FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "plans_select_all" ON public.subscription_plans;
CREATE POLICY "plans_select_all" ON public.subscription_plans
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "admin_manage_plans" ON public.subscription_plans;
CREATE POLICY "admin_manage_plans" ON public.subscription_plans
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- PAYMENTS
-- ============================================================

DROP POLICY IF EXISTS "users_view_own_payments" ON public.payments;
CREATE POLICY "users_view_own_payments" ON public.payments
  FOR SELECT USING (payer_id = auth.uid());

DROP POLICY IF EXISTS "users_insert_own_payments" ON public.payments;
CREATE POLICY "users_insert_own_payments" ON public.payments
  FOR INSERT WITH CHECK (payer_id = auth.uid());

DROP POLICY IF EXISTS "admin_manage_payments" ON public.payments;
CREATE POLICY "admin_manage_payments" ON public.payments
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- Activation code redemption — atomic + secure (SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.redeem_activation_code(p_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_code public.activation_codes%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  -- Ensure the user profile row exists in public.users
  INSERT INTO public.users (id, email, full_name, phone, role)
  VALUES (
    auth.uid(),
    COALESCE(auth.jwt()->>'email', ''),
    COALESCE(auth.jwt()->'user_metadata'->>'full_name', 'طالب'),
    COALESCE(auth.jwt()->'user_metadata'->>'phone', '01000000000'),
    'student'
  )
  ON CONFLICT (id) DO NOTHING;

  -- Ensure the student profile row exists
  INSERT INTO public.students (id, grade_level, parent_phone)
  VALUES (auth.uid(), 'first', '')
  ON CONFLICT (id) DO NOTHING;

  -- Lock the code row so two students can't redeem it at once
  SELECT * INTO v_code
  FROM public.activation_codes
  WHERE code = p_code
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'code_not_found';
  END IF;

  IF v_code.is_used THEN
    RAISE EXCEPTION 'code_already_used';
  END IF;

  UPDATE public.activation_codes
  SET is_used = true, used_by = auth.uid(), used_at = NOW()
  WHERE id = v_code.id;

  -- Create / renew the student's subscription to the code's teacher
  INSERT INTO public.subscriptions (
    student_id, teacher_id, activation_code_id, status, starts_at, expires_at
  )
  VALUES (
    auth.uid(), v_code.teacher_id, v_code.id, 'active', NOW(), NOW() + INTERVAL '1 year'
  )
  ON CONFLICT (student_id, teacher_id)
  DO UPDATE SET
    status = 'active',
    expires_at = EXCLUDED.expires_at,
    activation_code_id = EXCLUDED.activation_code_id;

  RETURN jsonb_build_object(
    'ok', true,
    'teacher_id', v_code.teacher_id,
    'course_id', v_code.course_id,
    'course_price', (SELECT price FROM public.courses WHERE id = v_code.course_id)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.redeem_activation_code(TEXT) TO authenticated;

-- Paid subscription — atomic payment + subscription (SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.create_subscription_with_payment(
  p_teacher_id UUID,
  p_amount NUMERIC,
  p_course_id UUID DEFAULT NULL,
  p_gateway TEXT DEFAULT 'paymob'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Ensure the user profile row exists in public.users
  INSERT INTO public.users (id, email, full_name, phone, role)
  VALUES (
    auth.uid(),
    COALESCE(auth.jwt()->>'email', ''),
    COALESCE(auth.jwt()->'user_metadata'->>'full_name', 'طالب'),
    COALESCE(auth.jwt()->'user_metadata'->>'phone', '01000000000'),
    'student'
  )
  ON CONFLICT (id) DO NOTHING;

  -- Ensure the student profile row exists in public.students
  INSERT INTO public.students (id, grade_level, parent_phone)
  VALUES (auth.uid(), 'first', '')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.subscriptions (
    student_id, teacher_id, status, starts_at, expires_at
  )
  VALUES (
    auth.uid(), p_teacher_id, 'active', NOW(), NOW() + INTERVAL '1 year'
  )
  ON CONFLICT (student_id, teacher_id)
  DO UPDATE SET
    status = 'active',
    expires_at = EXCLUDED.expires_at;

  INSERT INTO public.payments (
    payer_id, payer_type, course_id, amount, payment_gateway,
    gateway_transaction_id, status
  )
  VALUES (
    auth.uid(), 'student_subscription', p_course_id, p_amount, p_gateway,
    'TXN-' || EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT, 'success'
  );

  RETURN jsonb_build_object('ok', true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_subscription_with_payment(UUID, NUMERIC, UUID, TEXT) TO authenticated;

-- ============================================================
-- LESSON PROGRESS
-- ============================================================

DROP POLICY IF EXISTS "students_manage_own_progress" ON public.lesson_progress;
CREATE POLICY "students_manage_own_progress" ON public.lesson_progress
  FOR ALL USING (student_id = auth.uid());

DROP POLICY IF EXISTS "teachers_view_student_progress" ON public.lesson_progress;
CREATE POLICY "teachers_view_student_progress" ON public.lesson_progress
  FOR SELECT USING (
    lesson_id IN (
      SELECT l.id FROM public.lessons l
      JOIN public.courses c ON c.id = l.course_id
      WHERE c.teacher_id = auth.uid()
    )
  );

-- ============================================================
-- EXAM SUBMISSIONS
-- ============================================================

DROP POLICY IF EXISTS "students_manage_own_submissions" ON public.exam_submissions;
CREATE POLICY "students_manage_own_submissions" ON public.exam_submissions
  FOR ALL USING (student_id = auth.uid());

DROP POLICY IF EXISTS "teachers_view_exam_submissions" ON public.exam_submissions;
CREATE POLICY "teachers_view_exam_submissions" ON public.exam_submissions
  FOR SELECT USING (
    exam_id IN (
      SELECT id FROM public.exams WHERE teacher_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "admin_select_all_submissions" ON public.exam_submissions;
CREATE POLICY "admin_select_all_submissions" ON public.exam_submissions
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- COMMENTS
-- ============================================================

DROP POLICY IF EXISTS "comments_select_all" ON public.comments;
CREATE POLICY "comments_select_all" ON public.comments
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "comments_insert_own" ON public.comments;
CREATE POLICY "comments_insert_own" ON public.comments
  FOR INSERT WITH CHECK (author_id = auth.uid());

DROP POLICY IF EXISTS "comments_update_own" ON public.comments;
CREATE POLICY "comments_update_own" ON public.comments
  FOR UPDATE USING (author_id = auth.uid());

DROP POLICY IF EXISTS "comments_delete_own" ON public.comments;
CREATE POLICY "comments_delete_own" ON public.comments
  FOR DELETE USING (author_id = auth.uid());

-- ============================================================
-- BOOKMARKS
-- ============================================================

DROP POLICY IF EXISTS "bookmarks_select_own" ON public.bookmarks;
CREATE POLICY "bookmarks_select_own" ON public.bookmarks
  FOR SELECT USING (student_id = auth.uid());

DROP POLICY IF EXISTS "bookmarks_insert_own" ON public.bookmarks;
CREATE POLICY "bookmarks_insert_own" ON public.bookmarks
  FOR INSERT WITH CHECK (student_id = auth.uid());

DROP POLICY IF EXISTS "bookmarks_delete_own" ON public.bookmarks;
CREATE POLICY "bookmarks_delete_own" ON public.bookmarks
  FOR DELETE USING (student_id = auth.uid());

-- ============================================================
-- COURSE REVIEWS
-- ============================================================

DROP POLICY IF EXISTS "course_reviews_select_all" ON public.course_reviews;
CREATE POLICY "course_reviews_select_all" ON public.course_reviews
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "course_reviews_insert_own" ON public.course_reviews;
CREATE POLICY "course_reviews_insert_own" ON public.course_reviews
  FOR INSERT WITH CHECK (student_id = auth.uid());

DROP POLICY IF EXISTS "course_reviews_update_own" ON public.course_reviews;
CREATE POLICY "course_reviews_update_own" ON public.course_reviews
  FOR UPDATE USING (student_id = auth.uid());

DROP POLICY IF EXISTS "course_reviews_delete_own" ON public.course_reviews;
CREATE POLICY "course_reviews_delete_own" ON public.course_reviews
  FOR DELETE USING (student_id = auth.uid());

-- ============================================================
-- PAYMENT METHODS
-- ============================================================

DROP POLICY IF EXISTS "payment_methods_select_own" ON public.payment_methods;
CREATE POLICY "payment_methods_select_own" ON public.payment_methods
  FOR SELECT USING (student_id = auth.uid());

DROP POLICY IF EXISTS "payment_methods_insert_own" ON public.payment_methods;
CREATE POLICY "payment_methods_insert_own" ON public.payment_methods
  FOR INSERT WITH CHECK (student_id = auth.uid());

DROP POLICY IF EXISTS "payment_methods_update_own" ON public.payment_methods;
CREATE POLICY "payment_methods_update_own" ON public.payment_methods
  FOR UPDATE USING (student_id = auth.uid());

DROP POLICY IF EXISTS "payment_methods_delete_own" ON public.payment_methods;
CREATE POLICY "payment_methods_delete_own" ON public.payment_methods
  FOR DELETE USING (student_id = auth.uid());

-- ============================================================
-- 6. SEED DATA (Optional)
-- ============================================================

-- Default subjects (only if table is empty)
INSERT INTO public.subjects (name_ar, name_en, icon_name, display_order)
SELECT * FROM (VALUES
  ('رياضيات', 'Mathematics', 'calculate', 1),
  ('فيزياء', 'Physics', 'science', 2),
  ('كيمياء', 'Chemistry', 'science_outlined', 3),
  ('أحياء', 'Biology', 'eco', 4),
  ('لغة عربية', 'Arabic', 'menu_book', 5),
  ('لغة إنجليزية', 'English', 'language', 6),
  ('لغة فرنسية', 'French', 'translate', 7),
  ('تاريخ', 'History', 'history_edu', 8),
  ('جغرافيا', 'Geography', 'public', 9),
  ('فلسفة', 'Philosophy', 'psychology', 10)
) AS v(name_ar, name_en, icon_name, display_order)
WHERE NOT EXISTS (SELECT 1 FROM public.subjects LIMIT 1);

-- Default subscription plans (only if table is empty)
INSERT INTO public.subscription_plans (name, billing_period, price, display_order)
SELECT * FROM (VALUES
  ('الباقة الشهرية', 'monthly'::billing_period, 99.99, 1),
  ('باقة الفصل', 'term'::billing_period, 249.99, 2),
  ('باقة السنة', 'yearly'::billing_period, 599.99, 3)
) AS v(name, billing_period, price, display_order)
WHERE NOT EXISTS (SELECT 1 FROM public.subscription_plans LIMIT 1);
