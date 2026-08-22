-- 1. Clean up corrupted auth records
DELETE FROM auth.identities WHERE identity_data->>'email' = 'hasaninelsaid99@gmail.com' OR user_id = '4d817052-c05d-4927-a54b-7bbd5a128909';
DELETE FROM auth.users WHERE email = 'hasaninelsaid99@gmail.com' OR id = '4d817052-c05d-4927-a54b-7bbd5a128909';

-- 2. Insert valid user with all GoTrue default columns
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  invited_at,
  confirmation_token,
  confirmation_sent_at,
  recovery_token,
  recovery_sent_at,
  email_change_token_new,
  email_change,
  email_change_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  created_at,
  updated_at,
  phone,
  phone_confirmed_at,
  phone_change,
  phone_change_token,
  phone_change_sent_at,
  email_change_token_current,
  email_change_confirm_status,
  banned_until,
  reauthentication_token,
  reauthentication_sent_at,
  is_sso_user,
  deleted_at,
  is_anonymous
) VALUES (
  '4d817052-c05d-4927-a54b-7bbd5a128909',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'hasaninelsaid99@gmail.com',
  crypt('12345678', gen_salt('bf', 10)),
  NOW(),
  NULL,
  '',
  NULL,
  '',
  NULL,
  '',
  '',
  NULL,
  NOW(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"حسنين السيد محمد عثمان","role":"teacher"}'::jsonb,
  false,
  NOW(),
  NOW(),
  NULL,
  NULL,
  '',
  '',
  NULL,
  '',
  0,
  NULL,
  '',
  NULL,
  false,
  NULL,
  false
);

-- 3. Insert identity with correct columns
INSERT INTO auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  provider_id,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  '4d817052-c05d-4927-a54b-7bbd5a128909',
  jsonb_build_object('sub', '4d817052-c05d-4927-a54b-7bbd5a128909', 'email', 'hasaninelsaid99@gmail.com', 'email_verified', true),
  'email',
  '4d817052-c05d-4927-a54b-7bbd5a128909',
  NOW(),
  NOW(),
  NOW()
);

-- 4. Sync public.users and public.teachers
UPDATE public.users 
SET id = '4d817052-c05d-4927-a54b-7bbd5a128909',
    plain_password = '12345678',
    role = 'teacher',
    full_name = 'حسنين السيد محمد عثمان'
WHERE email = 'hasaninelsaid99@gmail.com';

UPDATE public.teachers
SET id = '4d817052-c05d-4927-a54b-7bbd5a128909',
    approval_status = 'approved',
    plain_password = '12345678'
WHERE id = '4d817052-c05d-4927-a54b-7bbd5a128909';
