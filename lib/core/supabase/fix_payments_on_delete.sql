-- ========================================================================
-- FIX: Allow deleting users by adding ON DELETE CASCADE to payments table
-- Run this script in Supabase Dashboard -> SQL Editor
-- ========================================================================

-- 1. Drop existing restrictive foreign key constraint
ALTER TABLE public.payments 
  DROP CONSTRAINT IF EXISTS payments_payer_id_fkey;

-- 2. Re-create foreign key with ON DELETE CASCADE
ALTER TABLE public.payments 
  ADD CONSTRAINT payments_payer_id_fkey 
  FOREIGN KEY (payer_id) 
  REFERENCES public.users(id) 
  ON DELETE CASCADE;

-- 3. Also fix plan_id & course_id references to prevent blocking on deletion
ALTER TABLE public.payments 
  DROP CONSTRAINT IF EXISTS payments_plan_id_fkey;

ALTER TABLE public.payments 
  ADD CONSTRAINT payments_plan_id_fkey 
  FOREIGN KEY (plan_id) 
  REFERENCES public.subscription_plans(id) 
  ON DELETE SET NULL;

ALTER TABLE public.payments 
  DROP CONSTRAINT IF EXISTS payments_course_id_fkey;

ALTER TABLE public.payments 
  ADD CONSTRAINT payments_course_id_fkey 
  FOREIGN KEY (course_id) 
  REFERENCES public.courses(id) 
  ON DELETE SET NULL;
