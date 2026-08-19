-- ============================================================
-- FIX: Teachers can see their subscribed students' data
-- Run this in Supabase SQL Editor (safe to re-run)
-- ============================================================
-- WHY: public.users RLS policy "users_select_own" only lets a user
-- see their OWN row, and public.students only lets a user see their
-- own row too. When the teacher app reads student profiles, RLS
-- hides every row except the teacher's own — so the students list
-- shows blank names/emails and the student's stage (grade_level)
-- is missing (shows as 'غير محدد' and can't be filtered).
--
-- Both policies below let a teacher read the profile rows of
-- students who are subscribed to them.

-- 1. Teachers can read their subscribed students' user rows (names)
DROP POLICY IF EXISTS "teachers_select_subscribed_students" ON public.users;

CREATE POLICY "teachers_select_subscribed_students" ON public.users
  FOR SELECT USING (
    id IN (
      SELECT student_id FROM public.subscriptions
      WHERE teacher_id = auth.uid()
    )
  );

-- 2. Teachers can read their subscribed students' student rows
--    (grade_level — the stage shown on the students screen).
DROP POLICY IF EXISTS "teachers_select_subscribed_students" ON public.students;

CREATE POLICY "teachers_select_subscribed_students" ON public.students
  FOR SELECT USING (
    id IN (
      SELECT student_id FROM public.subscriptions
      WHERE teacher_id = auth.uid()
    )
  );

-- ============================================================
-- SAFE NAME LOOKUP: public user_profiles view
-- ============================================================
-- The app reads student names through this view as a guaranteed path:
-- it exposes only id/full_name/avatar_url (no email/phone) and is
-- readable by any authenticated user, so exam results and student
-- lists always show names even if the RLS policy above is not yet
-- applied. Idempotent — safe to re-run.

CREATE OR REPLACE VIEW public.user_profiles AS
SELECT id, full_name, avatar_url
FROM public.users;

GRANT SELECT ON public.user_profiles TO anon, authenticated;

-- Verify:
-- SELECT tablename, policyname, cmd FROM pg_policies
-- WHERE schemaname = 'public' AND tablename = 'users' ORDER BY cmd;
-- SELECT * FROM public.user_profiles LIMIT 5;
