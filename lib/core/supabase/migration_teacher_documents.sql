-- ============================================================
-- Migration: Add teacher document columns + storage bucket
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1. Add document URL & subscription payment columns to the teachers table
ALTER TABLE public.teachers
  ADD COLUMN IF NOT EXISTS avatar_url TEXT,
  ADD COLUMN IF NOT EXISTS id_card_front_url TEXT,
  ADD COLUMN IF NOT EXISTS id_card_back_url TEXT,
  ADD COLUMN IF NOT EXISTS teacher_proof_url TEXT,
  ADD COLUMN IF NOT EXISTS payment_receipt_url TEXT,
  ADD COLUMN IF NOT EXISTS selected_plan TEXT,
  ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'instapay',
  ADD COLUMN IF NOT EXISTS subscription_amount NUMERIC(10,2);

-- 2. Create storage bucket for teacher documents
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'teacher-documents',
  'teacher-documents',
  true,
  10485760,  -- 10 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- 3. Storage RLS policies (Idempotent - safe to re-run)
-- Allow authenticated users to upload to their own folder
DROP POLICY IF EXISTS "teachers_upload_own_docs" ON storage.objects;
CREATE POLICY "teachers_upload_own_docs"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'teacher-documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Allow anyone to read teacher documents (public bucket)
DROP POLICY IF EXISTS "public_read_teacher_docs" ON storage.objects;
CREATE POLICY "public_read_teacher_docs"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'teacher-documents');

-- Allow owners to delete their own documents
DROP POLICY IF EXISTS "teachers_delete_own_docs" ON storage.objects;
CREATE POLICY "teachers_delete_own_docs"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'teacher-documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
