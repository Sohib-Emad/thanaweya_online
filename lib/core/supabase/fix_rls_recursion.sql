-- ============================================================
-- FIX: Infinite recursion in users RLS + subjects access
-- Run ONLY this file in Supabase SQL Editor
-- ============================================================

-- 1. Fix infinite recursion on users table
DROP POLICY IF EXISTS "admin_select_all_users" ON public.users;
DROP POLICY IF EXISTS "admin_update_all_users" ON public.users;

CREATE POLICY "admin_select_all_users" ON public.users
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

CREATE POLICY "admin_update_all_users" ON public.users
  FOR UPDATE USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- 2. Fix other tables that query users (replace subquery with JWT check)
DROP POLICY IF EXISTS "admin_select_all_teachers" ON public.teachers;
DROP POLICY IF EXISTS "admin_manage_teachers" ON public.teachers;

CREATE POLICY "admin_select_all_teachers" ON public.teachers
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

CREATE POLICY "admin_manage_teachers" ON public.teachers
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_select_all_students" ON public.students;
DROP POLICY IF EXISTS "teachers_select_subscribed_students" ON public.students;

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

DROP POLICY IF EXISTS "admin_manage_subjects" ON public.subjects;
CREATE POLICY "admin_manage_subjects" ON public.subjects
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- Keep public read policies for subjects
DROP POLICY IF EXISTS "subjects_select_active" ON public.subjects;
DROP POLICY IF EXISTS "subjects_select_all" ON public.subjects;

CREATE POLICY "subjects_select_active" ON public.subjects
  FOR SELECT USING (is_active = true);

CREATE POLICY "subjects_select_all" ON public.subjects
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "admin_select_all_courses" ON public.courses;
CREATE POLICY "admin_select_all_courses" ON public.courses
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_select_all_lessons" ON public.lessons;
CREATE POLICY "admin_select_all_lessons" ON public.lessons
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_select_all_exams" ON public.exams;
CREATE POLICY "admin_select_all_exams" ON public.exams
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_manage_subscriptions" ON public.subscriptions;
CREATE POLICY "admin_manage_subscriptions" ON public.subscriptions
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_select_all_codes" ON public.activation_codes;
CREATE POLICY "admin_select_all_codes" ON public.activation_codes
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_manage_plans" ON public.subscription_plans;
CREATE POLICY "admin_manage_plans" ON public.subscription_plans
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_manage_payments" ON public.payments;
CREATE POLICY "admin_manage_payments" ON public.payments
  FOR ALL USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

DROP POLICY IF EXISTS "admin_select_all_submissions" ON public.exam_submissions;
CREATE POLICY "admin_select_all_submissions" ON public.exam_submissions
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );
