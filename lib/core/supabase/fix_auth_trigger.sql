-- ============================================================
-- FIX: Drop the broken trigger, app will handle user creation
-- Run this in Supabase SQL Editor
-- ============================================================

-- Drop the trigger and function that's causing the 500 error
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Ensure users table exists with correct structure
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'student',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ensure RLS is correct (no recursion)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_select_own" ON public.users;
DROP POLICY IF EXISTS "users_update_own" ON public.users;
DROP POLICY IF EXISTS "admin_select_all_users" ON public.users;
DROP POLICY IF EXISTS "admin_update_all_users" ON public.users;

CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "admin_select_all_users" ON public.users
  FOR SELECT USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

CREATE POLICY "admin_update_all_users" ON public.users
  FOR UPDATE USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
  );

-- Allow authenticated users to insert their own row
CREATE POLICY "users_insert_own" ON public.users
  FOR INSERT WITH CHECK (id = auth.uid());
