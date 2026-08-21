-- Migration: Enforce Per-Course Independent Subscriptions & Access
-- Ensures subscriptions table has course_id and appropriate index

ALTER TABLE public.subscriptions 
ADD COLUMN IF NOT EXISTS course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE;

-- Optional index for faster lookups
CREATE INDEX IF NOT EXISTS idx_subscriptions_student_course 
ON public.subscriptions(student_id, course_id);
