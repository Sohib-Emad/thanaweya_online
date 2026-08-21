-- Migration: Student Points & Rewards System
-- Adds bonus_points and last_daily_claim_at to students table

ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS bonus_points INTEGER NOT NULL DEFAULT 0;

ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS last_daily_claim_at TIMESTAMPTZ;

-- Points Transactions log for tracking (optional/auditing)
CREATE TABLE IF NOT EXISTS public.student_points_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  points INTEGER NOT NULL,
  type TEXT NOT NULL DEFAULT 'bonus', -- 'daily_gift', 'exam', 'lesson', 'admin_gift', 'mission'
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.student_points_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own points transactions"
  ON public.student_points_transactions
  FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());
