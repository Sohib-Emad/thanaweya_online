-- ============================================================
-- COMPLETE FIX — Run this ONE file in Supabase SQL Editor
-- ============================================================

-- 1. Kill broken trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- 2. Ensure types exist
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
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'billing_period') THEN
    CREATE TYPE billing_period AS ENUM ('monthly', 'term', 'yearly');
  END IF;
END $$;

-- 2.5 Ensure video_source type exists (for intro_video_source_type)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'video_source') THEN
    CREATE TYPE video_source AS ENUM ('youtube', 'upload');
  END IF;
END $$;

-- 2.6 Ensure courses has price + intro video columns (idempotent)
ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS price NUMERIC(10,2),
  ADD COLUMN IF NOT EXISTS intro_video_url TEXT,
  ADD COLUMN IF NOT EXISTS intro_video_source_type video_source NOT NULL DEFAULT 'youtube';

-- 2.7 Ensure payments tracks the purchased course (idempotent)
ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL;

-- 2.8 Activation code redemption — atomic + secure (SECURITY DEFINER)
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

  RETURN jsonb_build_object('ok', true, 'teacher_id', v_code.teacher_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.redeem_activation_code(TEXT) TO authenticated;

-- 2.9 Paid subscription — atomic payment + subscription (SECURITY DEFINER)
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

-- 3. Ensure tables exist
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL DEFAULT '',
  phone TEXT NOT NULL DEFAULT '',
  role user_role NOT NULL DEFAULT 'student',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  icon_name TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  billing_period billing_period NOT NULL DEFAULT 'monthly',
  price NUMERIC(10,2) NOT NULL,
  max_students INTEGER,
  max_courses INTEGER,
  storage_limit_mb INTEGER,
  is_active BOOLEAN NOT NULL DEFAULT true,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.teachers (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES public.subjects(id),
  stage teacher_stage NOT NULL DEFAULT 'first',
  bio TEXT,
  approval_status approval_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  subscription_plan_id UUID REFERENCES public.subscription_plans(id),
  subscription_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.students (
  id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  grade_level student_grade NOT NULL DEFAULT 'first',
  parent_phone TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.courses (
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

CREATE TABLE IF NOT EXISTS public.lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_source_type TEXT NOT NULL DEFAULT 'youtube',
  video_url_or_id TEXT NOT NULL,
  duration_seconds INTEGER,
  thumbnail_url TEXT,
  is_free_preview BOOLEAN NOT NULL DEFAULT false,
  "order" INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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

CREATE TABLE IF NOT EXISTS public.questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
  question_type TEXT NOT NULL DEFAULT 'mcq',
  text TEXT NOT NULL,
  options JSONB DEFAULT '[]'::jsonb,
  correct_answer TEXT,
  points INTEGER NOT NULL DEFAULT 1,
  "order" INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  activation_code_id UUID,
  status TEXT NOT NULL DEFAULT 'active',
  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, teacher_id)
);

CREATE TABLE IF NOT EXISTS public.activation_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  code TEXT UNIQUE NOT NULL,
  is_used BOOLEAN NOT NULL DEFAULT false,
  used_by UUID REFERENCES public.students(id),
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payer_id UUID NOT NULL REFERENCES public.users(id),
  payer_type TEXT NOT NULL,
  plan_id UUID REFERENCES public.subscription_plans(id),
  amount NUMERIC(10,2) NOT NULL,
  payment_gateway TEXT NOT NULL,
  gateway_transaction_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  watched_seconds INTEGER NOT NULL DEFAULT 0,
  last_watched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(student_id, lesson_id)
);

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

CREATE TABLE IF NOT EXISTS public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Seed data (only if empty)
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

INSERT INTO public.subscription_plans (name, billing_period, price, display_order)
SELECT * FROM (VALUES
  ('الباقة الشهرية', 'monthly'::billing_period, 99.99, 1),
  ('باقة الفصل', 'term'::billing_period, 249.99, 2),
  ('باقة السنة', 'yearly'::billing_period, 599.99, 3)
) AS v(name, billing_period, price, display_order)
WHERE NOT EXISTS (SELECT 1 FROM public.subscription_plans LIMIT 1);

-- 5. Wipe ALL existing RLS policies and recreate correctly
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
  ) LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
  END LOOP;
END $$;

-- 6. Enable RLS on all tables
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

-- 7. USERS policies
CREATE POLICY "users_select_own" ON public.users FOR SELECT USING (id = auth.uid());
CREATE POLICY "users_select_teacher_profiles" ON public.users FOR SELECT TO anon, authenticated USING (id IN (SELECT id FROM public.teachers WHERE approval_status = 'approved'));
CREATE POLICY "users_insert_own" ON public.users FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "users_update_own" ON public.users FOR UPDATE USING (id = auth.uid());
CREATE POLICY "admin_all_users" ON public.users FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 8. TEACHERS policies
CREATE POLICY "teachers_select_own" ON public.teachers FOR SELECT USING (id = auth.uid());
CREATE POLICY "teachers_insert_own" ON public.teachers FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "teachers_update_own" ON public.teachers FOR UPDATE USING (id = auth.uid());
CREATE POLICY "admin_all_teachers" ON public.teachers FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');
CREATE POLICY "public_select_approved_teachers" ON public.teachers FOR SELECT USING (approval_status = 'approved');

-- 9. STUDENTS policies
CREATE POLICY "students_select_own" ON public.students FOR SELECT USING (id = auth.uid());
CREATE POLICY "students_insert_own" ON public.students FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "students_update_own" ON public.students FOR UPDATE USING (id = auth.uid());
CREATE POLICY "admin_all_students" ON public.students FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 10. SUBJECTS policies (public read)
CREATE POLICY "subjects_select_all" ON public.subjects FOR SELECT USING (true);
CREATE POLICY "admin_all_subjects" ON public.subjects FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 11. COURSES policies
CREATE POLICY "teachers_manage_own_courses" ON public.courses FOR ALL USING (teacher_id = auth.uid());
CREATE POLICY "public_select_published_courses" ON public.courses FOR SELECT USING (is_published = true);
CREATE POLICY "admin_all_courses" ON public.courses FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 12. LESSONS policies
CREATE POLICY "teachers_manage_own_lessons" ON public.lessons FOR ALL USING (
  course_id IN (SELECT id FROM public.courses WHERE teacher_id = auth.uid())
);
CREATE POLICY "public_select_lessons" ON public.lessons FOR SELECT USING (is_free_preview = true);
CREATE POLICY "students_select_lessons" ON public.lessons FOR SELECT TO authenticated USING (true);
CREATE POLICY "admin_all_lessons" ON public.lessons FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 13. EXAMS policies
CREATE POLICY "teachers_manage_own_exams" ON public.exams FOR ALL USING (teacher_id = auth.uid());
CREATE POLICY "students_select_published_exams" ON public.exams FOR SELECT TO authenticated USING (is_published = true);
CREATE POLICY "admin_all_exams" ON public.exams FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 14. QUESTIONS policies
CREATE POLICY "teachers_manage_own_questions" ON public.questions FOR ALL USING (
  exam_id IN (SELECT id FROM public.exams WHERE teacher_id = auth.uid())
);
CREATE POLICY "students_select_questions" ON public.questions FOR SELECT TO authenticated USING (exam_id IN (SELECT id FROM public.exams WHERE is_published = true));
CREATE POLICY "admin_all_questions" ON public.questions FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 15. SUBSCRIPTIONS policies
CREATE POLICY "students_view_own_subscriptions" ON public.subscriptions FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "teachers_view_own_subscriptions" ON public.subscriptions FOR SELECT USING (teacher_id = auth.uid());
CREATE POLICY "admin_all_subscriptions" ON public.subscriptions FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 16. ACTIVATION CODES policies
CREATE POLICY "teachers_manage_own_codes" ON public.activation_codes FOR ALL USING (teacher_id = auth.uid());
CREATE POLICY "public_select_unused_codes" ON public.activation_codes FOR SELECT USING (is_used = false);

-- 17. SUBSCRIPTION PLANS policies
CREATE POLICY "plans_select_all" ON public.subscription_plans FOR SELECT USING (true);
CREATE POLICY "admin_all_plans" ON public.subscription_plans FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 18. PAYMENTS policies
CREATE POLICY "users_view_own_payments" ON public.payments FOR SELECT USING (payer_id = auth.uid());
CREATE POLICY "admin_all_payments" ON public.payments FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 18.1 PAYMENTS insert policy (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'payments' AND policyname = 'users_insert_own_payments') THEN
    EXECUTE 'CREATE POLICY "users_insert_own_payments" ON public.payments FOR INSERT WITH CHECK (payer_id = auth.uid())';
  END IF;
END $$;

-- 18.2 SUBSCRIPTIONS insert/update policies (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'subscriptions' AND policyname = 'students_insert_own_subscriptions') THEN
    EXECUTE 'CREATE POLICY "students_insert_own_subscriptions" ON public.subscriptions FOR INSERT WITH CHECK (student_id = auth.uid())';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'subscriptions' AND policyname = 'students_update_own_subscriptions') THEN
    EXECUTE 'CREATE POLICY "students_update_own_subscriptions" ON public.subscriptions FOR UPDATE USING (student_id = auth.uid())';
  END IF;
END $$;

-- 19. LESSON PROGRESS policies
CREATE POLICY "students_manage_own_progress" ON public.lesson_progress FOR ALL USING (student_id = auth.uid());

-- 20. EXAM SUBMISSIONS policies
CREATE POLICY "students_manage_own_submissions" ON public.exam_submissions FOR ALL USING (student_id = auth.uid());
CREATE POLICY "teachers_view_submissions" ON public.exam_submissions FOR SELECT USING (
  exam_id IN (SELECT id FROM public.exams WHERE teacher_id = auth.uid())
);
CREATE POLICY "admin_all_submissions" ON public.exam_submissions FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 21. COMMENTS policies
CREATE POLICY "comments_select_all" ON public.comments FOR SELECT USING (true);
CREATE POLICY "comments_insert_own" ON public.comments FOR INSERT WITH CHECK (author_id = auth.uid());
CREATE POLICY "comments_update_own" ON public.comments FOR UPDATE USING (author_id = auth.uid());
CREATE POLICY "comments_delete_own" ON public.comments FOR DELETE USING (author_id = auth.uid());

-- 22. BOOKMARKS policies
CREATE POLICY "bookmarks_select_own" ON public.bookmarks FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "bookmarks_insert_own" ON public.bookmarks FOR INSERT WITH CHECK (student_id = auth.uid());
CREATE POLICY "bookmarks_delete_own" ON public.bookmarks FOR DELETE USING (student_id = auth.uid());

-- 23. COURSE REVIEWS policies
CREATE POLICY "course_reviews_select_all" ON public.course_reviews FOR SELECT USING (true);
CREATE POLICY "course_reviews_insert_own" ON public.course_reviews FOR INSERT WITH CHECK (student_id = auth.uid());
CREATE POLICY "course_reviews_update_own" ON public.course_reviews FOR UPDATE USING (student_id = auth.uid());
CREATE POLICY "course_reviews_delete_own" ON public.course_reviews FOR DELETE USING (student_id = auth.uid());

-- 24. PAYMENT METHODS policies
CREATE POLICY "payment_methods_select_own" ON public.payment_methods FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "payment_methods_insert_own" ON public.payment_methods FOR INSERT WITH CHECK (student_id = auth.uid());
CREATE POLICY "payment_methods_update_own" ON public.payment_methods FOR UPDATE USING (student_id = auth.uid());
CREATE POLICY "payment_methods_delete_own" ON public.payment_methods FOR DELETE USING (student_id = auth.uid());

-- DONE. Verify:
SELECT tablename, policyname, cmd FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, cmd;
