-- Final bulletproof admin_set_user_password RPC
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.admin_set_user_password(
  p_user_id UUID,
  p_new_password TEXT,
  p_email TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_email TEXT := p_email;
  v_auth_id UUID := NULL;
  v_hash TEXT;
  v_full_name TEXT := '';
  v_phone TEXT := '';
  v_role TEXT := 'teacher';
BEGIN
  -- 1. Search directly in auth.users by email
  IF v_email IS NOT NULL AND TRIM(v_email) <> '' THEN
    SELECT id INTO v_auth_id FROM auth.users WHERE LOWER(TRIM(email)) = LOWER(TRIM(v_email)) LIMIT 1;
  END IF;

  -- 2. If not found by email, try direct ID in auth.users
  IF v_auth_id IS NULL THEN
    SELECT id, email INTO v_auth_id, v_email FROM auth.users WHERE id = p_user_id;
  END IF;

  -- 3. If still not found, search public.users for email
  IF v_auth_id IS NULL AND (v_email IS NULL OR TRIM(v_email) = '') THEN
    SELECT email, full_name, phone, role INTO v_email, v_full_name, v_phone, v_role FROM public.users WHERE id = p_user_id;
    IF v_email IS NOT NULL THEN
      SELECT id INTO v_auth_id FROM auth.users WHERE LOWER(TRIM(email)) = LOWER(TRIM(v_email)) LIMIT 1;
    END IF;
  END IF;

  -- 4. If still not found, search teachers table join
  IF v_auth_id IS NULL AND (v_email IS NULL OR TRIM(v_email) = '') THEN
    SELECT u.email, u.full_name, u.phone, u.role INTO v_email, v_full_name, v_phone, v_role
    FROM public.teachers t JOIN public.users u ON u.id = t.id WHERE t.id = p_user_id;
    IF v_email IS NOT NULL THEN
      SELECT id INTO v_auth_id FROM auth.users WHERE LOWER(TRIM(email)) = LOWER(TRIM(v_email)) LIMIT 1;
    END IF;
  END IF;

  -- Generate standard bcrypt hash (10 rounds)
  v_hash := crypt(p_new_password, gen_salt('bf', 10));

  -- 5. If user exists in auth.users, UPDATE password & repair fields
  IF v_auth_id IS NOT NULL THEN
    UPDATE auth.users
    SET encrypted_password = v_hash,
        updated_at = NOW(),
        recovery_token = '',
        confirmation_token = '',
        email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
        is_sso_user = false,
        deleted_at = NULL,
        is_anonymous = false,
        aud = 'authenticated',
        role = 'authenticated'
    WHERE id = v_auth_id;

    -- Ensure identity exists and is valid
    DELETE FROM auth.identities WHERE user_id = v_auth_id OR (identity_data->>'email' = LOWER(TRIM(v_email)));
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
      v_auth_id::text,
      v_auth_id,
      jsonb_build_object('sub', v_auth_id::text, 'email', LOWER(TRIM(v_email)), 'email_verified', true),
      'email',
      NOW(),
      NOW(),
      NOW()
    );

  ELSE
    -- 6. If user DOES NOT exist in auth.users, CREATE IT
    IF v_email IS NULL OR TRIM(v_email) = '' THEN
      RETURN jsonb_build_object(
        'ok', false, 
        'error', 'لا يمكن إنشاء الحساب لعدم وجود بريد إلكتروني مسجل.'
      );
    END IF;

    v_auth_id := p_user_id;

    SELECT full_name, phone, role INTO v_full_name, v_phone, v_role
    FROM public.users WHERE id = p_user_id OR LOWER(TRIM(email)) = LOWER(TRIM(v_email)) LIMIT 1;

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
      v_auth_id,
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      LOWER(TRIM(v_email)),
      v_hash,
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
      jsonb_build_object('full_name', COALESCE(v_full_name, ''), 'phone', COALESCE(v_phone, ''), 'role', COALESCE(v_role, 'teacher')),
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
    )
    ON CONFLICT (id) DO UPDATE SET
      email = LOWER(TRIM(v_email)),
      encrypted_password = v_hash,
      email_confirmed_at = NOW(),
      updated_at = NOW(),
      deleted_at = NULL;

    DELETE FROM auth.identities WHERE user_id = v_auth_id OR (identity_data->>'email' = LOWER(TRIM(v_email)));
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
      v_auth_id::text,
      v_auth_id,
      jsonb_build_object('sub', v_auth_id::text, 'email', LOWER(TRIM(v_email)), 'email_verified', true),
      'email',
      NOW(),
      NOW(),
      NOW()
    );
  END IF;

  -- 7. Update plain_password in public tables
  UPDATE public.users SET plain_password = p_new_password WHERE LOWER(TRIM(email)) = LOWER(TRIM(v_email)) OR id = p_user_id OR id = v_auth_id;
  UPDATE public.teachers SET plain_password = p_new_password WHERE id = p_user_id OR id = v_auth_id;
  UPDATE public.students SET plain_password = p_new_password WHERE id = p_user_id OR id = v_auth_id;

  RETURN jsonb_build_object(
    'ok', true, 
    'message', 'تم تعيين كلمة المرور بنجاح',
    'auth_id', v_auth_id::text,
    'email', v_email
  );
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', SQLERRM);
END;
$$;
