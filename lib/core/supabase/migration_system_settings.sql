-- ==============================================================================
-- Migration: System Settings Table & Teacher Ban Enum Value
-- Run this in Supabase SQL Editor (Idempotent / Safe to re-run)
-- ==============================================================================

-- 1. Add 'banned' value to approval_status enum if not already present
ALTER TYPE approval_status ADD VALUE IF NOT EXISTS 'banned';

-- 2. Create System Settings Table for global Maintenance & Update Modes
CREATE TABLE IF NOT EXISTS public.system_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Enable Row Level Security
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- 4. Allow all users (including anon/guests) to read system settings (to check for maintenance & updates)
DROP POLICY IF EXISTS "Allow public read access on system_settings" ON public.system_settings;
CREATE POLICY "Allow public read access on system_settings"
    ON public.system_settings
    FOR SELECT
    USING (true);

-- 5. Allow super admins to insert, update, and delete system settings
DROP POLICY IF EXISTS "Allow super_admin to manage system_settings" ON public.system_settings;
CREATE POLICY "Allow super_admin to manage system_settings"
    ON public.system_settings
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.role = 'super_admin'
        )
    );

-- 6. Initial default settings for app modes
INSERT INTO public.system_settings (key, value)
VALUES (
    'app_modes',
    jsonb_build_object(
        'maintenance_mode', false,
        'maintenance_message', 'التطبيق قيد أعمال الصيانة والتطوير حالياً، سنعود قريباً بإذن الله.',
        'update_mode', false,
        'update_message', 'يتوفر إصدار جديد وأكثر استقراراً من التطبيق، يرجى التحديث للمتابعة.',
        'update_url', 'https://play.google.com',
        'support_phone', '201096462825'
    )
)
ON CONFLICT (key) DO NOTHING;
