-- ==============================================================================
-- Migration: Fix teachers.subject_id foreign key constraint on delete behavior
-- ==============================================================================
-- Allows deleting subjects without foreign key constraint violations from teachers.

-- 1. Make subject_id nullable in teachers table so it can be set to NULL on delete
ALTER TABLE IF EXISTS public.teachers 
  ALTER COLUMN subject_id DROP NOT NULL;

-- 2. Drop existing foreign key constraint
ALTER TABLE IF EXISTS public.teachers 
  DROP CONSTRAINT IF EXISTS teachers_subject_id_fkey;

-- 3. Add foreign key constraint with ON DELETE SET NULL
ALTER TABLE IF EXISTS public.teachers 
  ADD CONSTRAINT teachers_subject_id_fkey 
  FOREIGN KEY (subject_id) 
  REFERENCES public.subjects(id) 
  ON DELETE SET NULL;
