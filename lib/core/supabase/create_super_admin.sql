-- ============================================================================
-- CREATE OR UPDATE SUPER ADMIN USER (sohib / sohib2025)
-- Email: sohib@admin.com (or username: sohib)
-- Password: sohib2025
-- Role: super_admin
-- ============================================================================

DO $$
DECLARE
  v_user_id UUID;
  v_encrypted_pw TEXT;
BEGIN
  -- Generate bcrypt encrypted password for 'sohib2025'
  v_encrypted_pw := crypt('sohib2025', gen_salt('bf'));

  -- Check if user already exists
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'sohib@admin.com';

  IF v_user_id IS NULL THEN
    v_user_id := gen_random_uuid();

    -- Insert into auth.users
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      role,
      aud,
      confirmation_token
    ) VALUES (
      v_user_id,
      '00000000-0000-0000-0000-000000000000',
      'sohib@admin.com',
      v_encrypted_pw,
      NOW(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"full_name": "صهيب عماد", "role": "super_admin", "phone": "01096462825", "username": "sohib"}'::jsonb,
      NOW(),
      NOW(),
      'authenticated',
      'authenticated',
      ''
    );

    -- Insert into auth.identities
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
      v_user_id,
      v_user_id,
      json_build_object('sub', v_user_id::text, 'email', 'sohib@admin.com')::jsonb,
      'email',
      'sohib@admin.com',
      NOW(),
      NOW(),
      NOW()
    ) ON CONFLICT (provider, provider_id) DO NOTHING;

  ELSE
    -- Update existing user password and metadata to super_admin
    UPDATE auth.users
    SET
      encrypted_password = v_encrypted_pw,
      email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
      raw_user_meta_data = '{"full_name": "صهيب عماد", "role": "super_admin", "phone": "01096462825", "username": "sohib"}'::jsonb,
      updated_at = NOW()
    WHERE id = v_user_id;
  END IF;

  -- Ensure public.users entry exists and has super_admin role
  INSERT INTO public.users (
    id,
    email,
    full_name,
    phone,
    role,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    'sohib@admin.com',
    'صهيب عماد',
    '01096462825',
    'super_admin',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE
  SET
    role = 'super_admin',
    full_name = 'صهيب عماد',
    phone = '01096462825',
    updated_at = NOW();

  RAISE NOTICE 'Super Admin user (sohib@admin.com / sohib2025) created/updated successfully with ID: %', v_user_id;
END $$;
