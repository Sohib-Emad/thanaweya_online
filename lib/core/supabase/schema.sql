-- ============================================================
-- Thanaweya Online Platform - Complete Database Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. ENUMS
-- ============================================================

CREATE TYPE user_role AS ENUM ('super_admin', 'teacher', 'student');
CREATE TYPE teacher_stage AS ENUM ('first', 'second', 'third');
CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE student_grade AS ENUM ('first', 'second', 'third');
CREATE TYPE video_source AS ENUM ('youtube', 'upload');
CREATE TYPE question_type AS ENUM ('mcq', 'true_false', 'essay');
CREATE TYPE subscription_status AS ENUM ('active', 'suspended', 'expired');
CREATE TYPE billing_period AS ENUM ('monthly', 'term', 'yearly');
CREATE TYPE payer_type AS ENUM ('teacher_subscription', 'student_subscription');
CREATE TYPE payment_gateway AS ENUM ('paymob', 'fawry', 'kashier');
CREATE TYPE payment_status AS ENUM ('pending', 'success', 'failed', 'refunded');

-- ============================================================
-- 2. TABLES
-- ============================================================

-- Users (extends auth.users)
CREATE TABLE public.users (
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
CREATE TABLE public.subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  icon_name TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subscription Plans
CREATE TABLE public.subscription_plans (
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
CREATE TABLE public.teachers (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES public.subjects(id),
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
CREATE TABLE public.students (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  grade_level student_grade NOT NULL,
  parent_phone TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Courses
CREATE TABLE public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  is_published BOOLEAN NOT NULL DEFAULT false,
  "order" INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Lessons
CREATE TABLE public.lessons (
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
CREATE TABLE public.exams (
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
CREATE TABLE public.questions (
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
CREATE TABLE public.subscriptions (
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

-- Activation Codes
CREATE TABLE public.activation_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  code TEXT UNIQUE NOT NULL,
  is_used BOOLEAN NOT NULL DEFAULT false,
  used_by UUID REFERENCES public.students(id),
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add FK for subscriptions.activation_code_id
ALTER TABLE public.subscriptions
  ADD CONSTRAINT fk_subscriptions_activation_code
  FOREIGN KEY (activation_code_id) REFERENCES public.activation_codes(id);

-- Payments
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payer_id UUID NOT NULL REFERENCES public.users(id),
  payer_type payer_type NOT NULL,
  plan_id UUID REFERENCES public.subscription_plans(id),
  amount NUMERIC(10,2) NOT NULL,
  payment_gateway payment_gateway NOT NULL,
  gateway_transaction_id TEXT,
  status payment_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Lesson Progress
CREATE TABLE public.lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  watched_seconds INTEGER NOT NULL DEFAULT 0,
  last_watched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, lesson_id)
);

-- Exam Submissions
CREATE TABLE public.exam_submissions (
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
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Bookmarks
CREATE TABLE public.bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, course_id)
);

-- Course Reviews
CREATE TABLE public.course_reviews (
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
CREATE TABLE public.payment_methods (
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

CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_role ON public.users(role);

CREATE INDEX idx_teachers_approval ON public.teachers(approval_status);
CREATE INDEX idx_teachers_subject ON public.teachers(subject_id);

CREATE INDEX idx_courses_teacher ON public.courses(teacher_id);
CREATE INDEX idx_courses_published ON public.courses(is_published);

CREATE INDEX idx_lessons_course ON public.lessons(course_id);
CREATE INDEX idx_lessons_order ON public.lessons(course_id, "order");

CREATE INDEX idx_exams_teacher ON public.exams(teacher_id);
CREATE INDEX idx_exams_course ON public.exams(course_id);
CREATE INDEX idx_exams_dates ON public.exams(start_at, end_at);

CREATE INDEX idx_questions_exam ON public.questions(exam_id);

CREATE INDEX idx_subscriptions_student ON public.subscriptions(student_id);
CREATE INDEX idx_subscriptions_teacher ON public.subscriptions(teacher_id);
CREATE INDEX idx_subscriptions_status ON public.subscriptions(status);

CREATE INDEX idx_activation_codes_teacher ON public.activation_codes(teacher_id);
CREATE INDEX idx_activation_codes_code ON public.activation_codes(code);
CREATE INDEX idx_activation_codes_used ON public.activation_codes(is_used);

CREATE INDEX idx_payments_payer ON public.payments(payer_id);
CREATE INDEX idx_payments_status ON public.payments(status);

CREATE INDEX idx_lesson_progress_student ON public.lesson_progress(student_id);
CREATE INDEX idx_lesson_progress_lesson ON public.lesson_progress(lesson_id);

CREATE INDEX idx_exam_submissions_exam ON public.exam_submissions(exam_id);
CREATE INDEX idx_exam_submissions_student ON public.exam_submissions(student_id);

CREATE INDEX idx_comments_lesson ON public.comments(lesson_id);
CREATE INDEX idx_comments_author ON public.comments(author_id);

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

CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_courses_updated_at
  BEFORE UPDATE ON public.courses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_lessons_updated_at
  BEFORE UPDATE ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_plans_updated_at
  BEFORE UPDATE ON public.subscription_plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create user profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, phone, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')::user_role
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

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
ALTER TABLE public.activation_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- USERS
-- ============================================================

CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "users_select_teacher_profiles" ON public.users
  FOR SELECT TO anon, authenticated
  USING (id IN (SELECT id FROM public.teachers WHERE approval_status = 'approved'));

CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "admin_select_all_users" ON public.users
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

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

CREATE POLICY "teachers_select_own" ON public.teachers
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "teachers_update_own" ON public.teachers
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "admin_select_all_teachers" ON public.teachers
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

CREATE POLICY "admin_manage_teachers" ON public.teachers
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

CREATE POLICY "public_select_approved_teachers" ON public.teachers
  FOR SELECT USING (approval_status = 'approved');

-- ============================================================
-- STUDENTS
-- ============================================================

CREATE POLICY "students_select_own" ON public.students
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "students_update_own" ON public.students
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "admin_select_all_students" ON public.students
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

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

CREATE POLICY "subjects_select_active" ON public.subjects
  FOR SELECT USING (is_active = true);

CREATE POLICY "subjects_select_all" ON public.subjects
  FOR SELECT USING (true);

CREATE POLICY "admin_manage_subjects" ON public.subjects
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- COURSES
-- ============================================================

CREATE POLICY "teachers_manage_own_courses" ON public.courses
  FOR ALL USING (teacher_id = auth.uid());

CREATE POLICY "students_view_subscribed_courses" ON public.courses
  FOR SELECT USING (
    is_published = true AND (
      teacher_id IN (
        SELECT teacher_id FROM public.subscriptions
        WHERE student_id = auth.uid() AND status = 'active'
      )
    )
  );

CREATE POLICY "students_view_free_preview_courses" ON public.courses
  FOR SELECT USING (is_published = true);

CREATE POLICY "admin_select_all_courses" ON public.courses
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- LESSONS
-- ============================================================

CREATE POLICY "teachers_manage_own_lessons" ON public.lessons
  FOR ALL USING (
    course_id IN (
      SELECT id FROM public.courses WHERE teacher_id = auth.uid()
    )
  );

CREATE POLICY "students_view_subscribed_lessons" ON public.lessons
  FOR SELECT USING (
    is_free_preview = true OR
    course_id IN (
      SELECT c.id FROM public.courses c
      JOIN public.subscriptions s ON s.teacher_id = c.teacher_id
      WHERE s.student_id = auth.uid() AND s.status = 'active'
    )
  );

CREATE POLICY "admin_select_all_lessons" ON public.lessons
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- EXAMS
-- ============================================================

CREATE POLICY "teachers_manage_own_exams" ON public.exams
  FOR ALL USING (teacher_id = auth.uid());

CREATE POLICY "students_view_available_exams" ON public.exams
  FOR SELECT USING (
    is_published = true AND
    NOW() BETWEEN start_at AND end_at AND
    teacher_id IN (
      SELECT teacher_id FROM public.subscriptions
      WHERE student_id = auth.uid() AND status = 'active'
    )
  );

CREATE POLICY "admin_select_all_exams" ON public.exams
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- QUESTIONS
-- ============================================================

CREATE POLICY "teachers_manage_own_questions" ON public.questions
  FOR ALL USING (
    exam_id IN (
      SELECT id FROM public.exams WHERE teacher_id = auth.uid()
    )
  );

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

CREATE POLICY "students_view_own_subscriptions" ON public.subscriptions
  FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "teachers_view_own_subscriptions" ON public.subscriptions
  FOR SELECT USING (teacher_id = auth.uid());

CREATE POLICY "admin_manage_subscriptions" ON public.subscriptions
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- ACTIVATION CODES
-- ============================================================

CREATE POLICY "teachers_manage_own_codes" ON public.activation_codes
  FOR ALL USING (teacher_id = auth.uid());

CREATE POLICY "students_view_valid_codes" ON public.activation_codes
  FOR SELECT USING (is_used = false);

CREATE POLICY "admin_select_all_codes" ON public.activation_codes
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- SUBSCRIPTION PLANS
-- ============================================================

CREATE POLICY "plans_select_active" ON public.subscription_plans
  FOR SELECT USING (is_active = true);

CREATE POLICY "plans_select_all" ON public.subscription_plans
  FOR SELECT USING (true);

CREATE POLICY "admin_manage_plans" ON public.subscription_plans
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- PAYMENTS
-- ============================================================

CREATE POLICY "users_view_own_payments" ON public.payments
  FOR SELECT USING (payer_id = auth.uid());

CREATE POLICY "admin_manage_payments" ON public.payments
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- LESSON PROGRESS
-- ============================================================

CREATE POLICY "students_manage_own_progress" ON public.lesson_progress
  FOR ALL USING (student_id = auth.uid());

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

CREATE POLICY "students_manage_own_submissions" ON public.exam_submissions
  FOR ALL USING (student_id = auth.uid());

CREATE POLICY "teachers_view_exam_submissions" ON public.exam_submissions
  FOR SELECT USING (
    exam_id IN (
      SELECT id FROM public.exams WHERE teacher_id = auth.uid()
    )
  );

CREATE POLICY "admin_select_all_submissions" ON public.exam_submissions
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- ============================================================
-- COMMENTS
-- ============================================================

CREATE POLICY "comments_select_all" ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "comments_insert_own" ON public.comments
  FOR INSERT WITH CHECK (author_id = auth.uid());

CREATE POLICY "comments_update_own" ON public.comments
  FOR UPDATE USING (author_id = auth.uid());

CREATE POLICY "comments_delete_own" ON public.comments
  FOR DELETE USING (author_id = auth.uid());

-- ============================================================
-- BOOKMARKS
-- ============================================================

CREATE POLICY "bookmarks_select_own" ON public.bookmarks
  FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "bookmarks_insert_own" ON public.bookmarks
  FOR INSERT WITH CHECK (student_id = auth.uid());

CREATE POLICY "bookmarks_delete_own" ON public.bookmarks
  FOR DELETE USING (student_id = auth.uid());

-- ============================================================
-- COURSE REVIEWS
-- ============================================================

CREATE POLICY "course_reviews_select_all" ON public.course_reviews
  FOR SELECT USING (true);

CREATE POLICY "course_reviews_insert_own" ON public.course_reviews
  FOR INSERT WITH CHECK (student_id = auth.uid());

CREATE POLICY "course_reviews_update_own" ON public.course_reviews
  FOR UPDATE USING (student_id = auth.uid());

CREATE POLICY "course_reviews_delete_own" ON public.course_reviews
  FOR DELETE USING (student_id = auth.uid());

-- ============================================================
-- PAYMENT METHODS
-- ============================================================

CREATE POLICY "payment_methods_select_own" ON public.payment_methods
  FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "payment_methods_insert_own" ON public.payment_methods
  FOR INSERT WITH CHECK (student_id = auth.uid());

CREATE POLICY "payment_methods_update_own" ON public.payment_methods
  FOR UPDATE USING (student_id = auth.uid());

CREATE POLICY "payment_methods_delete_own" ON public.payment_methods
  FOR DELETE USING (student_id = auth.uid());

-- ============================================================
-- 6. SEED DATA (Optional)
-- ============================================================

-- Default subjects
INSERT INTO public.subjects (name_ar, name_en, icon_name, display_order) VALUES
  ('رياضيات', 'Mathematics', 'calculate', 1),
  ('فيزياء', 'Physics', 'science', 2),
  ('كيمياء', 'Chemistry', 'science_outlined', 3),
  ('أحياء', 'Biology', 'eco', 4),
  ('لغة عربية', 'Arabic', 'menu_book', 5),
  ('لغة إنجليزية', 'English', 'language', 6),
  ('لغة فرنسية', 'French', 'translate', 7),
  ('تاريخ', 'History', 'history_edu', 8),
  ('جغرافيا', 'Geography', 'public', 9),
  ('فلسفة', 'Philosophy', 'psychology', 10);

-- Default subscription plans
INSERT INTO public.subscription_plans (name, billing_period, price, display_order) VALUES
  ('الباقة الشهرية', 'monthly', 99.99, 1),
  ('باقة الفصل', 'term', 249.99, 2),
  ('باقة السنة', 'yearly', 599.99, 3);
