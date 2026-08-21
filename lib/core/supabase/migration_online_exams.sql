-- ====================================================================
-- Migration: Online Exams Module Enhancements
-- ====================================================================

-- 1. Exams table: add passing grade, attempt policies, date windows, and randomization
ALTER TABLE exams ADD COLUMN IF NOT EXISTS passing_score INT DEFAULT 50;
ALTER TABLE exams ADD COLUMN IF NOT EXISTS allow_retake BOOLEAN DEFAULT false;
ALTER TABLE exams ADD COLUMN IF NOT EXISTS max_attempts INT DEFAULT 1;
ALTER TABLE exams ADD COLUMN IF NOT EXISTS shuffle_questions BOOLEAN DEFAULT false;
ALTER TABLE exams ADD COLUMN IF NOT EXISTS lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 2. Exam submissions table: add idempotency, timing metrics, and offline sync tracking
ALTER TABLE exam_submissions ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ;
ALTER TABLE exam_submissions ADD COLUMN IF NOT EXISTS time_spent_seconds INT;
ALTER TABLE exam_submissions ADD COLUMN IF NOT EXISTS is_pending_sync BOOLEAN DEFAULT false;
ALTER TABLE exam_submissions ADD COLUMN IF NOT EXISTS local_submission_id TEXT UNIQUE;

-- 3. Create index for faster querying by student and exam
-- 4. Atomic Lesson View Counter Function
CREATE OR REPLACE FUNCTION increment_lesson_view(p_student_id UUID, p_lesson_id UUID)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_count INT;
BEGIN
  INSERT INTO lesson_progress (student_id, lesson_id, view_count, watched_seconds, is_completed, last_watched_at)
  VALUES (p_student_id, p_lesson_id, 1, 0, false, NOW())
  ON CONFLICT (student_id, lesson_id)
  DO UPDATE SET 
    view_count = COALESCE(lesson_progress.view_count, 0) + 1,
    last_watched_at = NOW()
  RETURNING view_count INTO v_count;

  RETURN v_count;
END;
$$;

-- 5. Allow Teachers to view and select lesson progress for their students
DROP POLICY IF EXISTS "teachers_view_student_progress" ON public.lesson_progress;
CREATE POLICY "teachers_view_student_progress" ON public.lesson_progress
  FOR SELECT TO authenticated
  USING (
    student_id = auth.uid()
    OR
    lesson_id IN (
      SELECT l.id FROM public.lessons l
      JOIN public.courses c ON c.id = l.course_id
      WHERE c.teacher_id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM public.teachers WHERE id = auth.uid()
    )
  );

-- 6. Teacher RPC to fetch student progress reliably (SECURITY DEFINER)
CREATE OR REPLACE FUNCTION get_teacher_student_progress(p_teacher_id UUID, p_student_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'lessons', COALESCE(jsonb_agg(
      jsonb_build_object(
        'id', COALESCE(lp.id, l.id),
        'lesson_id', l.id,
        'title', l.title,
        'course_id', c.id,
        'course_title', c.title,
        'is_completed', COALESCE(lp.is_completed, false) OR COALESCE(lp.watched_seconds, 0) > 0 OR COALESCE(lp.view_count, 0) > 0,
        'watched_seconds', COALESCE(lp.watched_seconds, 0),
        'duration_seconds', COALESCE(l.duration_seconds, 0),
        'last_watched_at', lp.last_watched_at,
        'view_count', COALESCE(lp.view_count, 0),
        'max_views', COALESCE(l.max_views, 3)
      ) ORDER BY l."order" ASC
    ), '[]'::jsonb)
  ) INTO v_result
  FROM public.lessons l
  JOIN public.courses c ON c.id = l.course_id
  LEFT JOIN public.lesson_progress lp ON lp.lesson_id = l.id AND lp.student_id = p_student_id
  WHERE c.teacher_id = p_teacher_id;

  RETURN v_result;
END;
$$;

-- 7. Allow Teachers to read students metadata (grade_level, parent_phone)
DROP POLICY IF EXISTS "teachers_select_all_students" ON public.students;
CREATE POLICY "teachers_select_all_students" ON public.students
  FOR SELECT TO authenticated
  USING (true);



