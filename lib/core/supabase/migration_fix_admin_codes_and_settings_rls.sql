-- ============================================================
-- Migration: Fix Admin RLS Policies for Activation Codes & System Settings
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1. Activation Codes: Allow Super Admin to Manage (SELECT, INSERT, UPDATE, DELETE)
DROP POLICY IF EXISTS "admin_select_all_codes" ON public.activation_codes;
DROP POLICY IF EXISTS "admin_manage_activation_codes" ON public.activation_codes;

CREATE POLICY "admin_manage_activation_codes" ON public.activation_codes
  FOR ALL
  USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
    OR EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'super_admin'
    )
  )
  WITH CHECK (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
    OR EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'super_admin'
    )
  );

-- 2. System Settings: Allow Super Admin to Manage (SELECT, INSERT, UPDATE, DELETE)
DROP POLICY IF EXISTS "Allow super_admin to manage system_settings" ON public.system_settings;
DROP POLICY IF EXISTS "admin_manage_system_settings" ON public.system_settings;

CREATE POLICY "admin_manage_system_settings" ON public.system_settings
  FOR ALL
  USING (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
    OR EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'super_admin'
    )
  )
  WITH CHECK (
    (auth.jwt()->'user_metadata'->>'role') = 'super_admin'
    OR EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'super_admin'
    )
  );
