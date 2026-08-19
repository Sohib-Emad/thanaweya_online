-- ============================================================
-- SQL Script: Create & Configure Supabase Storage Buckets
-- Run this in Supabase SQL Editor (Dashboard -> SQL Editor)
-- ============================================================

-- 1. Create 'teacher-documents' bucket (Course covers, teacher ID/avatar)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'teacher-documents',
  'teacher-documents',
  true,
  10485760, -- 10 MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- 2. Create 'lesson-documents' bucket (PDFs, study materials, ملازم)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lesson-documents',
  'lesson-documents',
  true,
  20971520, -- 20 MB limit
  ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 20971520,
  allowed_mime_types = ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp'];

-- 3. Create 'lesson-videos' bucket (Directly uploaded lesson & intro videos)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'lesson-videos',
  'lesson-videos',
  true,
  524288000, -- 500 MB limit
  ARRAY['video/mp4', 'video/quicktime', 'video/x-m4v', 'video/webm']
) ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 524288000,
  allowed_mime_types = ARRAY['video/mp4', 'video/quicktime', 'video/x-m4v', 'video/webm'];

-- ============================================================
-- Storage Policies (Allow uploads & public reads)
-- ============================================================

-- Drop old policies to avoid duplicate conflicts
DROP POLICY IF EXISTS "public_read_teacher_docs" ON storage.objects;
DROP POLICY IF EXISTS "teachers_upload_own_docs" ON storage.objects;
DROP POLICY IF EXISTS "teachers_delete_own_docs" ON storage.objects;
DROP POLICY IF EXISTS "public_read_lesson_docs" ON storage.objects;
DROP POLICY IF EXISTS "teachers_upload_lesson_docs" ON storage.objects;
DROP POLICY IF EXISTS "teachers_delete_lesson_docs" ON storage.objects;
DROP POLICY IF EXISTS "public_read_lesson_videos" ON storage.objects;
DROP POLICY IF EXISTS "teachers_upload_lesson_videos" ON storage.objects;
DROP POLICY IF EXISTS "teachers_delete_lesson_videos" ON storage.objects;

-- Allow anyone to read files in public buckets
CREATE POLICY "public_read_teacher_docs"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'teacher-documents');

CREATE POLICY "public_read_lesson_docs"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'lesson-documents');

CREATE POLICY "public_read_lesson_videos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'lesson-videos');

-- Allow authenticated users (teachers) to upload files
CREATE POLICY "teachers_upload_own_docs"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'teacher-documents');

CREATE POLICY "teachers_upload_lesson_docs"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'lesson-documents');

CREATE POLICY "teachers_upload_lesson_videos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'lesson-videos');

-- Allow authenticated users to update/overwrite files
CREATE POLICY "teachers_update_own_docs"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id IN ('teacher-documents', 'lesson-documents', 'lesson-videos'));

-- Allow authenticated users to delete files
CREATE POLICY "teachers_delete_own_docs"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id IN ('teacher-documents', 'lesson-documents', 'lesson-videos'));
