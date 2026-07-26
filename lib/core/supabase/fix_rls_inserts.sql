-- RUN THIS IN SUPABASE SQL EDITOR
-- This adds INSERT policies for teachers and students

-- Teachers: allow inserting own row
DROP POLICY IF EXISTS "teachers_insert_own" ON public.teachers;
CREATE POLICY "teachers_insert_own" ON public.teachers
  FOR INSERT WITH CHECK (id = auth.uid());

-- Students: allow inserting own row
DROP POLICY IF EXISTS "students_insert_own" ON public.students;
CREATE POLICY "students_insert_own" ON public.students
  FOR INSERT WITH CHECK (id = auth.uid());

-- Verify it worked (should show "teachers_insert_own")
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'teachers' AND schemaname = 'public';
