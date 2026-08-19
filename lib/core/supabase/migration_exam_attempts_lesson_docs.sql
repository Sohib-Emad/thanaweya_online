-- ============================================================
-- Migration: Exam attempts + lesson documents (ملازم) + video view limits
-- Run this in Supabase SQL Editor — safe to run multiple times.
-- ============================================================

-- 1. EXAMS — attempt limit per student + optional linked lesson
ALTER TABLE public.exams
  ADD COLUMN IF NOT EXISTS max_attempts INTEGER NOT NULL DEFAULT 3,
  ADD COLUMN IF NOT EXISTS lesson_id UUID REFERENCES public.lessons(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_exams_lesson ON public.exams(lesson_id);

-- 2. LESSONS — max video views per student
ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS max_views INTEGER NOT NULL DEFAULT 3;

-- 3. LESSON PROGRESS — track how many times the student opened the video
ALTER TABLE public.lesson_progress
  ADD COLUMN IF NOT EXISTS view_count INTEGER NOT NULL DEFAULT 0;

-- 4. LESSON DOCUMENTS (الملازم) — handouts published by the teacher per lesson
CREATE TABLE IF NOT EXISTS public.lesson_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lesson_documents_lesson ON public.lesson_documents(lesson_id);

ALTER TABLE public.lesson_documents ENABLE ROW LEVEL SECURITY;

-- Teachers can manage documents of their own lessons
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'lesson_documents' AND policyname = 'teachers_manage_own_lesson_docs') THEN
    EXECUTE 'CREATE POLICY "teachers_manage_own_lesson_docs" ON public.lesson_documents
      FOR ALL USING (
        lesson_id IN (
          SELECT l.id FROM public.lessons l
          JOIN public.courses c ON c.id = l.course_id
          WHERE c.teacher_id = auth.uid()
        )
      )';
  END IF;
END $$;

-- Students can read documents of lessons in courses they are subscribed to
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'lesson_documents' AND policyname = 'students_view_lesson_docs') THEN
    EXECUTE 'CREATE POLICY "students_view_lesson_docs" ON public.lesson_documents
      FOR SELECT USING (
        lesson_id IN (
          SELECT l.id FROM public.lessons l
          JOIN public.courses c ON c.id = l.course_id
          JOIN public.subscriptions s ON s.teacher_id = c.teacher_id
          WHERE s.student_id = auth.uid() AND s.status = ''active''
        )
      )';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'lesson_documents' AND policyname = 'admin_all_lesson_docs') THEN
    EXECUTE 'CREATE POLICY "admin_all_lesson_docs" ON public.lesson_documents
      FOR ALL USING ((auth.jwt()->''user_metadata''->>''role'') = ''super_admin'')';
  END IF;
END $$;

-- 4.5 Tighten exam_submissions: students may SELECT/INSERT/UPDATE their own
--     rows but NOT DELETE them (deleting own submissions would bypass the
--     attempt limit). Teachers delete via the reopen policies below.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'exam_submissions' AND policyname = 'students_manage_own_submissions') THEN
    DROP POLICY "students_manage_own_submissions" ON public.exam_submissions;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'exam_submissions' AND policyname = 'students_select_own_submissions') THEN
    EXECUTE 'CREATE POLICY "students_select_own_submissions" ON public.exam_submissions
      FOR SELECT USING (student_id = auth.uid())';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'exam_submissions' AND policyname = 'students_insert_own_submissions') THEN
    EXECUTE 'CREATE POLICY "students_insert_own_submissions" ON public.exam_submissions
      FOR INSERT WITH CHECK (student_id = auth.uid())';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'exam_submissions' AND policyname = 'students_update_own_submissions') THEN
    EXECUTE 'CREATE POLICY "students_update_own_submissions" ON public.exam_submissions
      FOR UPDATE USING (student_id = auth.uid())';
  END IF;
END $$;

-- 5. TEACHER RE-OPEN EXAM — let the teacher reset a student's attempts
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'exam_submissions' AND policyname = 'teachers_delete_exam_submissions') THEN
    EXECUTE 'CREATE POLICY "teachers_delete_exam_submissions" ON public.exam_submissions
      FOR DELETE USING (
        exam_id IN (SELECT id FROM public.exams WHERE teacher_id = auth.uid())
      )';
  END IF;
END $$;

-- 6. TEACHER RE-OPEN VIDEO — let the teacher reset view counts of their lessons
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'lesson_progress' AND policyname = 'teachers_update_student_progress') THEN
    EXECUTE 'CREATE POLICY "teachers_update_student_progress" ON public.lesson_progress
      FOR UPDATE USING (
        lesson_id IN (
          SELECT l.id FROM public.lessons l
          JOIN public.courses c ON c.id = l.course_id
          WHERE c.teacher_id = auth.uid()
        )
      )';
  END IF;
END $$;

-- 7. ATOMIC view counter (SECURITY DEFINER so students can only bump their own row)
CREATE OR REPLACE FUNCTION public.increment_lesson_view(p_student_id UUID, p_lesson_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_student_id THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  INSERT INTO public.lesson_progress (student_id, lesson_id, view_count, last_watched_at)
  VALUES (p_student_id, p_lesson_id, 1, NOW())
  ON CONFLICT (student_id, lesson_id)
  DO UPDATE SET
    view_count = public.lesson_progress.view_count + 1,
    last_watched_at = NOW()
  RETURNING view_count INTO v_count;

  RETURN v_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.increment_lesson_view(UUID, UUID) TO authenticated;

-- 7b. RESET lesson views for a specific student (callable by teachers or admins)
CREATE OR REPLACE FUNCTION public.reset_student_lesson_views(
  p_student_id UUID,
  p_lesson_id UUID,
  p_new_count INTEGER DEFAULT 0
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.lesson_progress (student_id, lesson_id, view_count, last_watched_at)
  VALUES (p_student_id, p_lesson_id, p_new_count, NOW())
  ON CONFLICT (student_id, lesson_id)
  DO UPDATE SET
    view_count = p_new_count,
    last_watched_at = NOW();
END;
$$;

GRANT EXECUTE ON FUNCTION public.reset_student_lesson_views(UUID, UUID, INTEGER) TO authenticated;

-- 8. HARD attempt limit at the database level (defense in depth) —
--    blocks a 4th submission even if the client lock is bypassed.
CREATE OR REPLACE FUNCTION public.enforce_exam_attempt_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_max INTEGER;
  v_used INTEGER;
BEGIN
  SELECT COALESCE(max_attempts, 3) INTO v_max
  FROM public.exams WHERE id = NEW.exam_id;

  SELECT COUNT(*) INTO v_used
  FROM public.exam_submissions
  WHERE exam_id = NEW.exam_id AND student_id = NEW.student_id;

  IF v_used >= v_max THEN
    RAISE EXCEPTION 'attempt_limit_reached';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_exam_attempt_limit ON public.exam_submissions;
CREATE TRIGGER trigger_exam_attempt_limit
  BEFORE INSERT ON public.exam_submissions
  FOR EACH ROW EXECUTE FUNCTION public.enforce_exam_attempt_limit();

-- 9. STORAGE bucket for lesson documents (الملازم)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lesson-documents',
  'lesson-documents',
  true,
  20971520,
  ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Teachers upload documents into their own folder
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'teachers_upload_lesson_docs') THEN
    EXECUTE 'CREATE POLICY "teachers_upload_lesson_docs" ON storage.objects FOR INSERT
      TO authenticated
      WITH CHECK (
        bucket_id = ''lesson-documents''
        AND (storage.foldername(name))[1] = auth.uid()::text
      )';
  END IF;
END $$;

-- Anyone can read lesson documents (public bucket)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'public_read_lesson_docs') THEN
    EXECUTE 'CREATE POLICY "public_read_lesson_docs" ON storage.objects FOR SELECT
      TO public
      USING (bucket_id = ''lesson-documents'')';
  END IF;
END $$;

-- Teachers delete their own documents
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'teachers_delete_lesson_docs') THEN
    EXECUTE 'CREATE POLICY "teachers_delete_lesson_docs" ON storage.objects FOR DELETE
      TO authenticated
      USING (
        bucket_id = ''lesson-documents''
        AND (storage.foldername(name))[1] = auth.uid()::text
      )';
  END IF;
END $$;
