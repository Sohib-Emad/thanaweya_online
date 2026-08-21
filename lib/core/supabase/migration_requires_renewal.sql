-- Add requires_renewal column to teachers table for subscription renewal alerts
ALTER TABLE public.teachers ADD COLUMN IF NOT EXISTS requires_renewal BOOLEAN NOT NULL DEFAULT false;
