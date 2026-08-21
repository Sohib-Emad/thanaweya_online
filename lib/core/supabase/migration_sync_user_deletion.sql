-- Migration: Automatically delete from auth.users when a user is deleted from public.users
-- This ensures that deleting a user from the public.users or public.students table also removes them from Supabase Auth (auth.users)
-- so the email becomes immediately available for new registrations.

CREATE OR REPLACE FUNCTION public.handle_user_deleted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = OLD.id;
  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS on_public_user_deleted ON public.users;
CREATE TRIGGER on_public_user_deleted
  AFTER DELETE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_user_deleted();

-- If a student row is deleted directly, cascade delete to public.users (which triggers auth.users deletion)
CREATE OR REPLACE FUNCTION public.handle_student_deleted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.users WHERE id = OLD.id;
  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS on_public_student_deleted ON public.students;
CREATE TRIGGER on_public_student_deleted
  AFTER DELETE ON public.students
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_student_deleted();
