-- Helper RPC: Find the auth.users ID for a given email
CREATE OR REPLACE FUNCTION public.find_auth_user_id(p_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
BEGIN
  SELECT id INTO v_id FROM auth.users WHERE email = p_email LIMIT 1;
  RETURN v_id::text;
END;
$$;
