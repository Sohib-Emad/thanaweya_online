-- Migration: Enforce Per-Course Independent Subscriptions & Access
-- Ensures subscriptions table has course_id and removes the legacy (student_id, teacher_id) unique constraint

ALTER TABLE public.subscriptions 
ADD COLUMN IF NOT EXISTS course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE;

-- 1. Drop the legacy unique constraint that prevented a student from subscribing to multiple courses of the same teacher
ALTER TABLE public.subscriptions 
DROP CONSTRAINT IF EXISTS subscriptions_student_id_teacher_id_key;

-- 2. Ensure each student can have only one active subscription per course
CREATE UNIQUE INDEX IF NOT EXISTS subscriptions_student_course_unique_idx 
ON public.subscriptions(student_id, course_id) 
WHERE course_id IS NOT NULL;

-- 3. Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_subscriptions_student_course 
ON public.subscriptions(student_id, course_id);

