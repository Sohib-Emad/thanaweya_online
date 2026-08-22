-- Fix GoTrue Schema Database Error:

DELETE FROM auth.identities WHERE user_id = '4d817052-c05d-4927-a54b-7bbd5a128909' OR identity_data->>'email' = 'hasaninelsaid99@gmail.com';

INSERT INTO auth.identities (
  id,
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  '4d817052-c05d-4927-a54b-7bbd5a128909',
  '4d817052-c05d-4927-a54b-7bbd5a128909',
  jsonb_build_object('sub', '4d817052-c05d-4927-a54b-7bbd5a128909', 'email', 'hasaninelsaid99@gmail.com', 'email_verified', true),
  'email',
  NOW(),
  NOW(),
  NOW()
)
ON CONFLICT DO NOTHING;

-- Also update auth.users with all expected defaults
UPDATE auth.users
SET 
  is_sso_user = false,
  deleted_at = NULL,
  aud = 'authenticated',
  role = 'authenticated',
  email_confirmed_at = NOW(),
  raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
  raw_user_meta_data = '{"full_name":"حسنين السيد محمد عثمان","role":"teacher"}'::jsonb
WHERE id = '4d817052-c05d-4927-a54b-7bbd5a128909';
