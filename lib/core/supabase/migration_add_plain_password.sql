-- Migration: Add plain_password column to users, students, and teachers for Admin visibility
-- Allows administrators to view account passwords and assist users.

-- 1. Add plain_password column to public.users
ALTER TABLE IF EXISTS public.users
  ADD COLUMN IF NOT EXISTS plain_password TEXT;

-- 2. Add plain_password column to public.students
ALTER TABLE IF EXISTS public.students
  ADD COLUMN IF NOT EXISTS plain_password TEXT;

-- 3. Add plain_password column to public.teachers
ALTER TABLE IF EXISTS public.teachers
  ADD COLUMN IF NOT EXISTS plain_password TEXT;

-- 4. Create RPC to allow admin to update a student/teacher password securely
CREATE OR REPLACE FUNCTION public.admin_set_user_password(
  p_user_id UUID,
  p_new_password TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update auth.users password hash
  UPDATE auth.users
  SET encrypted_password = crypt(p_new_password, gen_salt('bf')),
      updated_at = NOW()
  WHERE id = p_user_id;

  -- Update public tables
  UPDATE public.users
  SET plain_password = p_new_password
  WHERE id = p_user_id;

  UPDATE public.students
  SET plain_password = p_new_password
  WHERE id = p_user_id;

  UPDATE public.teachers
  SET plain_password = p_new_password
  WHERE id = p_user_id;

  RETURN jsonb_build_object('ok', true, 'message', 'Password updated successfully');
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', SQLERRM);
END;
$$;
