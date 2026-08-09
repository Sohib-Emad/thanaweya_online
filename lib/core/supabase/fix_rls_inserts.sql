-- ============================================================
-- Migration: Add missing RLS INSERT/UPDATE policies
-- Fixes: teacher registration, student registration,
--        subscription activation, activation code redemption
-- Run this in Supabase SQL Editor (or via MCP apply_migration).
-- Idempotent: safe to re-run (each policy is created only if missing).
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'users' AND policyname = 'users_insert_own') THEN
    EXECUTE 'CREATE POLICY "users_insert_own" ON public.users FOR INSERT WITH CHECK (id = auth.uid())';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'teachers' AND policyname = 'teachers_insert_own') THEN
    EXECUTE 'CREATE POLICY "teachers_insert_own" ON public.teachers FOR INSERT WITH CHECK (id = auth.uid())';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'students' AND policyname = 'students_insert_own') THEN
    EXECUTE 'CREATE POLICY "students_insert_own" ON public.students FOR INSERT WITH CHECK (id = auth.uid())';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'subscriptions' AND policyname = 'students_insert_own_subscriptions') THEN
    EXECUTE 'CREATE POLICY "students_insert_own_subscriptions" ON public.subscriptions FOR INSERT WITH CHECK (student_id = auth.uid())';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'subscriptions' AND policyname = 'students_update_own_subscriptions') THEN
    EXECUTE 'CREATE POLICY "students_update_own_subscriptions" ON public.subscriptions FOR UPDATE USING (student_id = auth.uid())';
  END IF;

  -- Activation code redemption now goes through the SECURITY DEFINER RPC
  -- public.redeem_activation_code (atomic FOR UPDATE claim). The old direct
  -- student-update policy is a redundant attack surface, so drop it.
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'activation_codes' AND policyname = 'students_update_unused_codes') THEN
    EXECUTE 'DROP POLICY "students_update_unused_codes" ON public.activation_codes';
  END IF;
END $$;
