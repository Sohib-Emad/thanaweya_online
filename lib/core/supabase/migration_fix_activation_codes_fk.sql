-- ==============================================================================
-- Migration: Fix activation_codes foreign key constraint on delete behavior
-- ==============================================================================
-- This allows deleting student rows without causing foreign key violations.
-- When a student is deleted, their used_by / used_by_student_id reference is set to NULL.

-- 1. Drop existing foreign key constraint if it exists
ALTER TABLE IF EXISTS public.activation_codes
  DROP CONSTRAINT IF EXISTS activation_codes_used_by_fkey;

-- 2. Add foreign key with ON DELETE SET NULL
ALTER TABLE IF EXISTS public.activation_codes
  ADD CONSTRAINT activation_codes_used_by_fkey
  FOREIGN KEY (used_by)
  REFERENCES public.students(id)
  ON DELETE SET NULL;

-- 3. Also handle used_by_student_id if present
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='activation_codes' AND column_name='used_by_student_id'
  ) THEN
    ALTER TABLE public.activation_codes
      DROP CONSTRAINT IF EXISTS activation_codes_used_by_student_id_fkey;
      
    ALTER TABLE public.activation_codes
      ADD CONSTRAINT activation_codes_used_by_student_id_fkey
      FOREIGN KEY (used_by_student_id)
      REFERENCES public.students(id)
      ON DELETE SET NULL;
  END IF;
END $$;
