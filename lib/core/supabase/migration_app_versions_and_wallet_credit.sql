-- ==============================================================================
-- MIGRATION: App Versions Tracking, Force Update & Admin Wallet Credit
-- ==============================================================================

-- 1. Ensure students table has app_version and last_active_at columns
ALTER TABLE public.students 
  ADD COLUMN IF NOT EXISTS app_version TEXT DEFAULT '1.0.0',
  ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMPTZ DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS wallet_balance NUMERIC(10,2) DEFAULT 0.00;

-- 2. Index for faster version reporting queries
CREATE INDEX IF NOT EXISTS idx_students_app_version ON public.students (app_version);

-- 3. Update system_settings with default app_modes including min_version
INSERT INTO public.system_settings (key, value)
VALUES (
  'app_modes',
  jsonb_build_object(
    'maintenance_mode', false,
    'maintenance_message', 'التطبيق قيد أعمال الصيانة والتطوير حالياً، سنعود قريباً بإذن الله.',
    'update_mode', false,
    'update_message', 'هذه النسخة ليست متاحة الآن، يرجى التحديث إلى أحدث إصدار للمتابعة.',
    'update_url', 'https://play.google.com',
    'support_phone', '201096462825',
    'min_version', '1.0.0',
    'latest_version', '1.0.0'
  )
)
ON CONFLICT (key) DO UPDATE
SET value = jsonb_set(
  jsonb_set(
    system_settings.value,
    '{min_version}',
    COALESCE(system_settings.value->'min_version', '"1.0.0"'::jsonb)
  ),
  '{latest_version}',
  COALESCE(system_settings.value->'latest_version', '"1.0.0"'::jsonb)
);
