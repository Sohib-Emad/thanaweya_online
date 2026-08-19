-- ============================================================
-- Push Notifications (Firebase Cloud Messaging) — migration
--
-- HOW TO APPLY
--   1) Deploy the edge function first (from the project root):
--        supabase functions deploy notify-user
--      and set its secret:
--        supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat /path/to/firebase-adminsdk.json | base64)"
--      (the service account JSON: Firebase Console -> Project settings ->
--       Service accounts -> Generate new private key)
--
--   2) Replace the two placeholders below:
--        <PROJECT_REF>  -> your Supabase project ref
--        <ANON_KEY>     -> your Supabase anon (public) key
--
--   3) Run this file in the Supabase SQL Editor (or `supabase db push`).
--
-- WHAT IT DOES
--   * device_tokens  : FCM tokens registered by the mobile app (RLS = own only)
--   * notifications  : in-app notifications shown inside the app (RLS = own only)
--   * When a lesson is inserted      -> notification row for each subscribed student
--   * When an exam is published      -> notification row for each subscribed student
--   * When a notification row is created -> calls notify-user edge function which
--     sends an FCM push message to every device of that user
-- ============================================================

-- 1. DEVICE TOKENS ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL DEFAULT 'android',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON public.device_tokens(user_id);

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "device_tokens_select_own" ON public.device_tokens;
CREATE POLICY "device_tokens_select_own" ON public.device_tokens
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "device_tokens_insert_own" ON public.device_tokens;
CREATE POLICY "device_tokens_insert_own" ON public.device_tokens
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "device_tokens_update_own" ON public.device_tokens;
CREATE POLICY "device_tokens_update_own" ON public.device_tokens
  FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "device_tokens_delete_own" ON public.device_tokens;
CREATE POLICY "device_tokens_delete_own" ON public.device_tokens
  FOR DELETE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "admin_all_device_tokens" ON public.device_tokens;
CREATE POLICY "admin_all_device_tokens" ON public.device_tokens
  FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 2. NOTIFICATIONS (in-app) -------------------------------------------------
-- Kept here so the schema is reproducible; the table already exists in most
-- environments, hence IF NOT EXISTS.
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  category TEXT NOT NULL DEFAULT 'system',
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user
  ON public.notifications(user_id, created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "notifications_select_own" ON public.notifications;
CREATE POLICY "notifications_select_own" ON public.notifications
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "notifications_update_own" ON public.notifications;
CREATE POLICY "notifications_update_own" ON public.notifications
  FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "admin_all_notifications" ON public.notifications;
CREATE POLICY "admin_all_notifications" ON public.notifications
  FOR ALL USING ((auth.jwt()->'user_metadata'->>'role') = 'super_admin');

-- 3. EVENT -> IN-APP NOTIFICATION TRIGGERS ----------------------------------

-- 3.1 New lesson added -> notify students subscribed to the course's teacher
-- (only for published courses — students shouldn't hear about draft content)
CREATE OR REPLACE FUNCTION public.notify_students_lesson_added()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_teacher_id UUID;
  v_course_title TEXT;
  v_published BOOLEAN;
BEGIN
  SELECT c.teacher_id, c.title, c.is_published
    INTO v_teacher_id, v_course_title, v_published
  FROM public.courses c
  WHERE c.id = NEW.course_id;

  IF v_teacher_id IS NULL OR NOT v_published THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, title, body, category)
  SELECT s.student_id, 'درس جديد', v_course_title || ' - ' || NEW.title, 'lesson'
  FROM public.subscriptions s
  WHERE s.teacher_id = v_teacher_id
    AND s.status = 'active';

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_notify_lesson_added ON public.lessons;
CREATE TRIGGER trigger_notify_lesson_added
  AFTER INSERT ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION public.notify_students_lesson_added();

-- 3.2 Exam published -> notify students subscribed to the teacher
CREATE OR REPLACE FUNCTION public.notify_students_exam_published()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.notifications (user_id, title, body, category)
  SELECT s.student_id, 'امتحان جديد', NEW.title, 'exam'
  FROM public.subscriptions s
  WHERE s.teacher_id = NEW.teacher_id
    AND s.status = 'active';

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_notify_exam_published ON public.exams;
CREATE TRIGGER trigger_notify_exam_published
  AFTER UPDATE OF is_published ON public.exams
  FOR EACH ROW
  WHEN (NEW.is_published = TRUE AND OLD.is_published = FALSE)
  EXECUTE FUNCTION public.notify_students_exam_published();

-- 3.3 Teacher message -> notify all subscribed students
-- Called from the teacher app: send_teacher_message('عنوان', 'نص الرسالة')
CREATE OR REPLACE FUNCTION public.send_teacher_message(
  p_title TEXT,
  p_body TEXT DEFAULT ''
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_count INTEGER;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  -- Only teachers (approved) can broadcast to their students.
  IF NOT EXISTS (
    SELECT 1 FROM public.teachers
    WHERE id = v_user_id AND approval_status = 'approved'
  ) THEN
    RAISE EXCEPTION 'not_a_teacher';
  END IF;

  INSERT INTO public.notifications (user_id, title, body, category)
  SELECT s.student_id, p_title, p_body, 'teacher_message'
  FROM public.subscriptions s
  WHERE s.teacher_id = v_user_id
    AND s.status = 'active';

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN jsonb_build_object('ok', true, 'sent', v_count);
END;
$$;

GRANT EXECUTE ON FUNCTION public.send_teacher_message(TEXT, TEXT) TO authenticated;

-- 4. NOTIFICATION INSERT -> FCM PUSH ----------------------------------------
-- Fires the `notify-user` edge function, which looks up the user's device
-- tokens and sends the FCM message (HTTP v1).
CREATE OR REPLACE FUNCTION public.send_fcm_push()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_url TEXT := 'https://<PROJECT_REF>.supabase.co/functions/v1/notify-user';
  v_anon TEXT := '<ANON_KEY>';
BEGIN
  -- Fail fast (without breaking the insert) until the placeholders are set.
  IF position('<' in v_url) > 0 OR position('<' in v_anon) > 0 THEN
    RAISE NOTICE 'send_fcm_push: replace <PROJECT_REF> and <ANON_KEY> first';
    RETURN NEW;
  END IF;

  PERFORM supabase_functions.http_request(
    url := v_url,
    method := 'POST',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_anon
    ),
    body := jsonb_build_object('notification_id', NEW.id)
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_send_fcm_push ON public.notifications;
CREATE TRIGGER trigger_send_fcm_push
  AFTER INSERT ON public.notifications
  FOR EACH ROW EXECUTE FUNCTION public.send_fcm_push();
