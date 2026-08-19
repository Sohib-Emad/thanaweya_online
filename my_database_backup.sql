--
-- PostgreSQL database dump
--

\restrict z2S8u9GwAugc6ZSriL3cRU1bRPTzbd2Rns5VaXObncMdCDLEjR02LxU5QQ1HbzW

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.4 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: approval_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.approval_status AS ENUM (
    'pending',
    'approved',
    'rejected'
);


--
-- Name: billing_period; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.billing_period AS ENUM (
    'monthly',
    'term',
    'yearly'
);


--
-- Name: payer_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payer_type AS ENUM (
    'teacher_subscription',
    'student_subscription'
);


--
-- Name: payment_gateway; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_gateway AS ENUM (
    'paymob',
    'fawry',
    'kashier'
);


--
-- Name: payment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_status AS ENUM (
    'pending',
    'success',
    'failed',
    'refunded'
);


--
-- Name: question_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.question_type AS ENUM (
    'mcq',
    'true_false',
    'essay'
);


--
-- Name: student_grade; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.student_grade AS ENUM (
    'first',
    'second',
    'third'
);


--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_status AS ENUM (
    'active',
    'suspended',
    'expired'
);


--
-- Name: teacher_stage; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.teacher_stage AS ENUM (
    'first',
    'second',
    'third'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'super_admin',
    'teacher',
    'student'
);


--
-- Name: video_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.video_source AS ENUM (
    'youtube',
    'upload'
);


--
-- Name: check_subscription_expiry(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_subscription_expiry() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.expires_at IS NOT NULL AND NEW.expires_at < NOW() AND NEW.status = 'active' THEN
    NEW.status = 'expired';
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: compute_exam_max_score(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.compute_exam_max_score() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.exams
  SET max_score = (
    SELECT COALESCE(SUM(points), 0)
    FROM public.questions
    WHERE exam_id = COALESCE(NEW.exam_id, OLD.exam_id)
  )
  WHERE id = COALESCE(NEW.exam_id, OLD.exam_id);
  RETURN NULL;
END;
$$;


--
-- Name: create_subscription_with_payment(uuid, numeric, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_subscription_with_payment(p_teacher_id uuid, p_amount numeric, p_course_id uuid DEFAULT NULL::uuid, p_gateway text DEFAULT 'paymob'::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Ensure the user profile row exists in public.users
  INSERT INTO public.users (id, email, full_name, phone, role)
  VALUES (
    auth.uid(),
    COALESCE(auth.jwt()->>'email', ''),
    COALESCE(auth.jwt()->'user_metadata'->>'full_name', 'طالب'),
    COALESCE(auth.jwt()->'user_metadata'->>'phone', '01000000000'),
    'student'
  )
  ON CONFLICT (id) DO NOTHING;

  -- Ensure the student profile row exists in public.students
  INSERT INTO public.students (id, grade_level, parent_phone)
  VALUES (auth.uid(), 'first', '')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.subscriptions (
    student_id, teacher_id, status, starts_at, expires_at
  )
  VALUES (
    auth.uid(), p_teacher_id, 'active', NOW(), NOW() + INTERVAL '1 year'
  )
  ON CONFLICT (student_id, teacher_id)
  DO UPDATE SET
    status = 'active',
    expires_at = EXCLUDED.expires_at;

  INSERT INTO public.payments (
    payer_id, payer_type, course_id, amount, payment_gateway,
    gateway_transaction_id, status
  )
  VALUES (
    auth.uid(), 'student_subscription', p_course_id, p_amount, p_gateway,
    'TXN-' || EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT, 'success'
  );

  RETURN jsonb_build_object('ok', true);
END;
$$;


--
-- Name: enforce_exam_attempt_limit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_exam_attempt_limit() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_max INTEGER;
  v_used INTEGER;
BEGIN
  SELECT COALESCE(max_attempts, 3) INTO v_max
  FROM public.exams WHERE id = NEW.exam_id;

  SELECT COUNT(*) INTO v_used
  FROM public.exam_submissions
  WHERE exam_id = NEW.exam_id AND student_id = NEW.student_id;

  IF v_used >= v_max THEN
    RAISE EXCEPTION 'attempt_limit_reached';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: increment_lesson_view(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.increment_lesson_view(p_student_id uuid, p_lesson_id uuid) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_count INTEGER;
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_student_id THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  INSERT INTO public.lesson_progress (student_id, lesson_id, view_count, last_watched_at)
  VALUES (p_student_id, p_lesson_id, 1, NOW())
  ON CONFLICT (student_id, lesson_id)
  DO UPDATE SET
    view_count = public.lesson_progress.view_count + 1,
    last_watched_at = NOW()
  RETURNING view_count INTO v_count;

  RETURN v_count;
END;
$$;


--
-- Name: notify_exam_published(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_exam_published() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  exam_title text;
  teacher_name text;
begin
  if new.is_published = true and coalesce(old.is_published, false) = false then
    select title into exam_title from public.exams where id = new.id;
    select u.full_name into teacher_name
    from public.users u
    where u.id = new.teacher_id;

    insert into public.notifications (user_id, title, body, category)
    select
      s.student_id,
      'امتحان جديد متاح',
      'تم نشر امتحان «' || coalesce(exam_title, '') || '» من المدرس ' || coalesce(teacher_name, '') || '، شارك فيه الآن.',
      'exams'
    from public.subscriptions s
    where s.teacher_id = new.teacher_id
      and s.status = 'active';
  end if;
  return new;
end;
$$;


--
-- Name: notify_students_exam_published(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_students_exam_published() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: notify_students_lesson_added(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_students_lesson_added() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: notify_subscription_activation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_subscription_activation() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  if new.status = 'active' then
    insert into public.notifications (user_id, title, body, category)
    values (new.student_id, 'تم تفعيل اشتراكك', 'تم تفعيل اشتراكك بنجاح، يمكنك الآن متابعة جميع الدروس.', 'system');
  end if;
  return new;
end;
$$;


--
-- Name: notify_teacher_approval(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_teacher_approval() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  if new.approval_status = 'approved'::public.approval_status
     and old.approval_status is distinct from 'approved'::public.approval_status then
    insert into public.notifications (user_id, title, body, category)
    values (new.id, 'تم تفعيل حسابك', 'مرحباً بك في المنصة، تم تفعيل حسابك كمعلم ويمكنك الآن إدارة دوراتك.', 'system');
  end if;
  if new.approval_status = 'rejected'::public.approval_status
     and old.approval_status is distinct from 'rejected'::public.approval_status then
    insert into public.notifications (user_id, title, body, category)
    values (new.id, 'تم رفض طلب الالتحاق', coalesce(new.rejection_reason, 'يرجى مراجعة بياناتك والتقديم مرة أخرى.'), 'system');
  end if;
  return new;
end;
$$;


--
-- Name: redeem_activation_code(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.redeem_activation_code(p_code text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_code public.activation_codes%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  -- Ensure the user profile row exists in public.users
  INSERT INTO public.users (id, email, full_name, phone, role)
  VALUES (
    auth.uid(),
    COALESCE(auth.jwt()->>'email', ''),
    COALESCE(auth.jwt()->'user_metadata'->>'full_name', 'طالب'),
    COALESCE(auth.jwt()->'user_metadata'->>'phone', '01000000000'),
    'student'
  )
  ON CONFLICT (id) DO NOTHING;

  -- Ensure the student profile row exists
  INSERT INTO public.students (id, grade_level, parent_phone)
  VALUES (auth.uid(), 'first', '')
  ON CONFLICT (id) DO NOTHING;

  -- Lock the code row so two students can't redeem it at once
  SELECT * INTO v_code
  FROM public.activation_codes
  WHERE code = p_code
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'code_not_found';
  END IF;

  IF v_code.is_used THEN
    RAISE EXCEPTION 'code_already_used';
  END IF;

  UPDATE public.activation_codes
  SET is_used = true, used_by = auth.uid(), used_at = NOW()
  WHERE id = v_code.id;

  -- Create / renew the student's subscription to the code's teacher
  INSERT INTO public.subscriptions (
    student_id, teacher_id, activation_code_id, status, starts_at, expires_at
  )
  VALUES (
    auth.uid(), v_code.teacher_id, v_code.id, 'active', NOW(), NOW() + INTERVAL '1 year'
  )
  ON CONFLICT (student_id, teacher_id)
  DO UPDATE SET
    status = 'active',
    expires_at = EXCLUDED.expires_at,
    activation_code_id = EXCLUDED.activation_code_id;

  RETURN jsonb_build_object(
    'ok', true,
    'teacher_id', v_code.teacher_id,
    'course_id', v_code.course_id,
    'course_price', (SELECT price FROM public.courses WHERE id = v_code.course_id)
  );
END;
$$;


--
-- Name: send_fcm_push(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.send_fcm_push() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: send_teacher_message(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.send_teacher_message(p_title text, p_body text DEFAULT ''::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activation_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activation_codes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    teacher_id uuid NOT NULL,
    course_id uuid,
    code text NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    used_by uuid,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookmarks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    course_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lesson_id uuid NOT NULL,
    author_id uuid NOT NULL,
    text text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: course_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.course_reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    course_id uuid NOT NULL,
    student_id uuid NOT NULL,
    rating integer NOT NULL,
    text text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT course_reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    teacher_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    cover_image_url text,
    is_published boolean DEFAULT false NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    price numeric(10,2),
    intro_video_url text,
    intro_video_source_type public.video_source DEFAULT 'youtube'::public.video_source NOT NULL
);


--
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    platform text DEFAULT 'android'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: exam_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exam_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    exam_id uuid NOT NULL,
    student_id uuid NOT NULL,
    score integer,
    total_points integer DEFAULT 0 NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    submitted_at timestamp with time zone,
    answers jsonb DEFAULT '{}'::jsonb
);


--
-- Name: exams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exams (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    teacher_id uuid NOT NULL,
    course_id uuid,
    title text NOT NULL,
    duration_minutes integer NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    max_score integer DEFAULT 0 NOT NULL,
    is_published boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    max_attempts integer DEFAULT 3 NOT NULL,
    lesson_id uuid
);


--
-- Name: lesson_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lesson_id uuid NOT NULL,
    title text NOT NULL,
    file_url text NOT NULL,
    file_type text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: lesson_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_progress (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    lesson_id uuid NOT NULL,
    is_completed boolean DEFAULT false NOT NULL,
    watched_seconds integer DEFAULT 0 NOT NULL,
    last_watched_at timestamp with time zone DEFAULT now() NOT NULL,
    view_count integer DEFAULT 0 NOT NULL
);


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lessons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    course_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    video_source_type public.video_source DEFAULT 'youtube'::public.video_source NOT NULL,
    video_url_or_id text NOT NULL,
    duration_seconds integer,
    thumbnail_url text,
    is_free_preview boolean DEFAULT false NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    max_views integer DEFAULT 3 NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title text NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    category text DEFAULT 'system'::text NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_methods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    card_holder text NOT NULL,
    card_last4 text NOT NULL,
    card_brand text,
    expiry_month integer,
    expiry_year integer,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    payer_id uuid NOT NULL,
    payer_type public.payer_type NOT NULL,
    plan_id uuid,
    amount numeric(10,2) NOT NULL,
    payment_gateway public.payment_gateway NOT NULL,
    gateway_transaction_id text,
    status public.payment_status DEFAULT 'pending'::public.payment_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    course_id uuid
);


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    exam_id uuid NOT NULL,
    question_type public.question_type DEFAULT 'mcq'::public.question_type NOT NULL,
    text text NOT NULL,
    options jsonb DEFAULT '[]'::jsonb,
    correct_answer text,
    points integer DEFAULT 1 NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    id uuid NOT NULL,
    grade_level public.student_grade NOT NULL,
    parent_phone text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name_ar text NOT NULL,
    name_en text NOT NULL,
    icon_name text,
    is_active boolean DEFAULT true NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    billing_period public.billing_period NOT NULL,
    price numeric(10,2) NOT NULL,
    max_students integer,
    max_courses integer,
    storage_limit_mb integer,
    is_active boolean DEFAULT true NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    teacher_id uuid NOT NULL,
    status public.subscription_status DEFAULT 'active'::public.subscription_status NOT NULL,
    starts_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    activation_code_id uuid
);


--
-- Name: teachers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teachers (
    id uuid NOT NULL,
    subject_id uuid NOT NULL,
    stage public.teacher_stage NOT NULL,
    bio text,
    approval_status public.approval_status DEFAULT 'pending'::public.approval_status NOT NULL,
    rejection_reason text,
    subscription_plan_id uuid,
    subscription_expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    avatar_url text,
    id_card_front_url text,
    id_card_back_url text,
    teacher_proof_url text,
    teaching_system text,
    governorate text,
    teaching_mode text,
    stages text[] DEFAULT '{}'::text[],
    baccalaureate_tracks text[] DEFAULT '{}'::text[]
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email text NOT NULL,
    full_name text NOT NULL,
    phone text NOT NULL,
    role public.user_role DEFAULT 'student'::public.user_role NOT NULL,
    avatar_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_profiles; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.user_profiles WITH (security_invoker='on') AS
 SELECT id,
    full_name,
    avatar_url
   FROM public.users;


--
-- Data for Name: activation_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.activation_codes (id, teacher_id, course_id, code, is_used, used_by, used_at, created_at) FROM stdin;
4fd0d827-4954-486d-a22a-35ca69e315c0	4d817052-c05d-4927-a54b-7bbd5a128909	\N	TH-QCKQ-DEJX	t	e16b180a-0e82-4cd4-97b2-57eadb181b4a	2026-08-13 03:12:16.639843+00	2026-08-13 03:08:09.150987+00
d8bca3d8-2dbe-451b-841e-06a3d65f3d0d	76bdcafc-7873-4f66-8ffc-caa17bafadc3	\N	TH-BXDN-WHQT	f	\N	\N	2026-08-13 16:19:34.336152+00
71dc18db-5d9c-41c4-a07e-69bac89a2bd5	76bdcafc-7873-4f66-8ffc-caa17bafadc3	\N	TH-EKJ9-BWHD	f	\N	\N	2026-08-13 16:19:34.336152+00
505eae3f-9680-4075-b2ab-a8cabea61b14	76bdcafc-7873-4f66-8ffc-caa17bafadc3	\N	TH-CT2A-EZSB	f	\N	\N	2026-08-13 16:19:34.336152+00
e3657d85-5d8b-435c-8efa-e66aa63ee199	76bdcafc-7873-4f66-8ffc-caa17bafadc3	\N	TH-FQ28-GT8J	f	\N	\N	2026-08-13 16:19:34.336152+00
29158b13-7c75-4381-ba13-9c93444de99d	76bdcafc-7873-4f66-8ffc-caa17bafadc3	\N	TH-SZAT-G34Q	f	\N	\N	2026-08-13 16:19:34.336152+00
\.


--
-- Data for Name: bookmarks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookmarks (id, student_id, course_id, created_at) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, lesson_id, author_id, text, created_at) FROM stdin;
\.


--
-- Data for Name: course_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.course_reviews (id, course_id, student_id, rating, text, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.courses (id, teacher_id, title, description, cover_image_url, is_published, "order", created_at, updated_at, price, intro_video_url, intro_video_source_type) FROM stdin;
b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	4d817052-c05d-4927-a54b-7bbd5a128909	الوحدة الثانية( الأبنية ) للصف الثالث الثانوي	شرح وتدريبات علي المشتقات والمصادر والمقصور والمنقوص والممدود واسما الزمان والمكان	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/covers/1786462514599/1786462514599.png	t	0	2026-08-11 15:35:16.047238+00	2026-08-13 02:33:48.754021+00	150.00	\N	youtube
24a9a7a7-2f6e-4696-8883-35d4984be8e6	4d817052-c05d-4927-a54b-7bbd5a128909	شرح أساسيات البلاغة للصف الأول الثانوي والبكالوريا	شرح أساسيات البلاغة والتدريب عليها	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/covers/1786465111720/1786465111721.png	t	0	2026-08-11 16:18:32.639323+00	2026-08-13 02:33:50.748646+00	150.00	\N	youtube
\.


--
-- Data for Name: device_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.device_tokens (id, user_id, token, platform, created_at, updated_at) FROM stdin;
4dc284b5-b7c3-4e25-b3cb-b6988ee16d4a	fd2e4f8a-030c-4698-b7cc-a39b647ee990	dbwdk8FHSVCOqwzKb76i-_:APA91bHOJPsLUIxQKx4zj1RRoW7jkevx2I2BMLa4Kr60q74yxSo8vD9AnVeGl1lzSTaZyxHWbhbbCjncCZUACx2CKW1gZhOxXyqXpjh-LdOP4w6yVRJPAOk	android	2026-08-12 17:36:13.975239+00	2026-08-12 17:36:11.948575+00
97c53788-19ff-4c2e-ad96-ad518acb111c	ab84b692-8481-494a-a677-a7e671a37a30	d1h4WjoURda7QM7lLhX6Z3:APA91bE2QZDvGpwKtpYGYfNE6v8-ZHKoAtiGdv8WrmGFkgpLNTBNhSXomNK8oKpJb3HmlwconHh1AYC0CxU9MGs2GWuAVQQfO7RtQik38t_c7rGTBBWhuxc	android	2026-08-12 15:39:25.117031+00	2026-08-12 15:39:22.801501+00
e1c47b55-b6a9-4579-982e-ad85362f381b	fdf7ac58-4cc3-4e60-9a17-583f63c6c551	ex4oslVqSRWMD2xLsYbd9y:APA91bHPpF2pEcBHKWUIm188gNfbEC_Ldfcv288x_gqg47PPY1o2__GMf5vSFU-PzRWaE_QOX8JdldbS3EEq0e6BXHHcvxcZI4ZgFULPgPtu74ws3djjhAM	android	2026-08-12 15:43:57.865003+00	2026-08-12 15:43:57.636326+00
6a674adf-ab2c-42cd-9d23-65bc5fe42b8e	2a48c2fb-9ccc-4641-aa8e-3e5a0c2ab606	e5v3W5RuQfCJeHe8nGb0c2:APA91bHTjMnixBdib6mdK_bLvFDZHVnZSVjF81CFfPXJNGPHuKPHacQQTnEhcP6UutaVmNX0xoNnusNVZbFggDIfP46LbA88Em3vAeGr5nBIcewbiSx2V50	android	2026-08-12 15:44:21.506453+00	2026-08-12 15:44:19.154514+00
5fc9e866-0bc2-415c-90bb-6b6f6fe8a89a	10f030a2-883b-49a5-adc7-fe753c42ce5e	f3r5fmofQSOa96gnuTBjL-:APA91bHBI5hWEE84UZ8igocK2RZGJNcQH_VP1e-Gmbzg80rvagbO4A31152E1iDWXqyzft-xRlQen_vw-X00tKkHbM7gWVnW4xTl_6L0cLxn1hgKnQH5YO4	android	2026-08-12 17:37:10.970604+00	2026-08-12 17:37:10.559998+00
8e6ef09e-81ef-4122-aae2-0a8fdd2644c6	12d743a4-bede-4102-8da0-f30b691c6574	dBQYT7NjSsGjJOYsOVVGu1:APA91bHJgb6N91GUqP-lYuFk0hOK5BmHB6uMBZa7Bza_-o2duNsicAaOO1Yn_bqLOzQV60VAygF4CrN6bW3JArJUfghxYMl4eAgvRCLSzkPaNhPU8uKYCVk	android	2026-08-12 17:56:36.361387+00	2026-08-12 18:55:40.975664+00
2f57d34a-6dcb-4f6f-9ed4-380efe6633f0	2b2d5aad-f514-47a2-8912-b04421bf17cb	eRzuXN6KQMmFWlSEN6ypAT:APA91bFKmNRBBn35YCw7CAgG7asaH-P-_ZJFYDVfYpsNx-aapp0q3GXDH53cIfvIZV_82TzIV5jbTGksX-QYrllYHQL3-fOQO-Ub3nY_MfZ7ZYXYhAwp5Go	android	2026-08-12 18:16:41.299388+00	2026-08-12 18:16:40.416574+00
574cd2d9-f906-42c0-ae11-37dd8e1b6add	6c44f50e-cdc6-4de4-8274-1315e51fa09b	fKJ0a2CNR2untsm4OpLtbc:APA91bGe67CBZs7ZN61I8PISCgWFbYnBFLTOpf6zUKLj1bFHno5giiTnYQeWho8kMqNGpMWcG2PCaME1uCLvgfcV3oscs5S39BqhKRSiRmRVfmwNnNl2Dzk	android	2026-08-13 16:22:43.159023+00	2026-08-13 17:22:24.072848+00
0099f004-9da0-40fa-871d-65dc5762c213	fc2362a4-d534-4848-a9bd-497a6abf783e	d4mKcRWTRP-23fdSJ2QR-n:APA91bHShabxzfnpbt1Csbday9hEKUEkzE_w9d8wCcFbkBs6RyykTRqY-5uEqwk35JXdjy9Uh1uQ1_NncFkMBUPOlR2UcHBcg_G0JKLJ9pKY1KmA2WsEros	android	2026-08-12 18:50:59.138441+00	2026-08-12 18:50:58.614816+00
89167b8b-de5f-45cf-9ddf-9a4577c1bca4	c5bd97aa-af9d-4214-a249-f3183d5c08fb	e5Y6usJEQoileTQNt7lxzv:APA91bFNDl_n7TqNgcTHQwJlel6HRKUkGBNbYPbWiXrDHla3yG5A0UmkqkEwfuWOKoysTf3SO7ojJQoOXChppLovsCnQ3sMH3tZUeg2H7pLmLi0CH3sr1W0	android	2026-08-12 19:40:21.715349+00	2026-08-12 19:40:20.634082+00
358dc6eb-c96c-4c81-b603-3c3c8c6d272f	0d9a8081-3732-48e8-9d96-ddd4a2388e52	f5D-64y4RyCHB_ENDGX7g6:APA91bESqrLTeBuNeyfs2BLMDNxe3qRDtJSU_psLOeAnnBgsCCFuQlDW4pzx3HV11msY4GooZTFFpQJa0Q5bGVmky6kTHgi9xYFaBAmWndQV_N_nrfxhcCs	android	2026-08-12 19:46:33.651637+00	2026-08-12 19:46:31.443668+00
d59ac1c4-20c0-4e2d-9b4c-dda3b4cf6d27	026c809c-79ab-4a19-a2e5-302cb224a67f	do4D8a3uTBqUSKnraOpNcc:APA91bHuHnx5x6fXdlutw-h7RmCk7rbIYshfcdhYRGa8UlJ2-bx5uBuojc5mRmGMfm5i16dFUyJfdZLxmHXftdRBOhtnNSZlZFgVC3kQc8_Lay_0o2hJuXw	android	2026-08-12 16:24:05.266619+00	2026-08-12 20:05:33.49389+00
58a2bd9c-005b-4369-b848-80f520e13a8e	4c463009-45b8-43c6-93c1-6e621ed2747f	dQyZ6IH5QGCphFUDtU0bj4:APA91bG9x8cVDe3ogQKJEnZUN1pACBeXK32H3f0cRYfQyOX8vtcYG-XMV8HvJb0DJo9TdwD-ety4U42twzsT5YG-5ozYGhrIXek_PvB7Vk4yy3EsN_hbO8I	android	2026-08-12 22:41:03.676364+00	2026-08-12 22:39:54.788193+00
66cc482f-40fd-4033-ad36-5aca1be527c3	f2836a0a-6e10-44e6-8194-c6d859ae8548	ftFOVMNMQGyLJ1dUWJMyrb:APA91bEeP26bv2Oo3aIGFSLxZF1tJaQCB5MMUtDvvZ2te6GxvtzQ3x0wOwSAVjVLeJsak-QYPSWvl6po3-CdTl_JM-O2KkXGOyZheH2-EwWzPdq44GkLhkg	android	2026-08-13 00:39:51.213677+00	2026-08-13 00:39:50.57988+00
ff9a0bc6-9c29-48f5-910a-424af841893e	bfa781f8-3bc8-4601-8814-73c99cf589a1	dFvNB5LBR1K1YI-AA_xTPH:APA91bEjcesre2MWnu_wPMtDhlthR2QjSILDOOfHSZUj4Z1wn9EVPOwyRuBbzEPnjcyCLOYkjxzSNYtDOnaDlhT4gKRzKdEZz4k-lWghIJqeJQ1WgFYylvg	android	2026-08-12 15:41:46.271203+00	2026-08-13 00:48:57.094132+00
869160e3-6078-48e6-a716-d512a86ccd2a	5bc8b321-dda7-4d6d-888a-b758bc5162cd	eFa_0AecQMWFMybtcSFJ0l:APA91bGS-J-XQyZWV-3srLvBoIGKB8VXEo3WCNdZxbewIwQXUhFfKMDRRLH-vvfJXJPyrzo-pavKCspfL-8taS7hrSlK0StzRWyRj2BzyVBAkC3w5XYCM7A	android	2026-08-12 15:56:03.239759+00	2026-08-13 16:24:37.074+00
1223ea41-7da7-47a8-8568-741b0cf311e7	74e34941-6b14-4c9b-85c4-214494953b6d	cmR2JfV0RduL2Iw7Y_GLU4:APA91bFtGhtNn-vrUmoFg4SUkICzUg883kMol6_0-Hp0vY0xSarHkLztHX1mQkThY8YFpC8K2QQuz8PQA9oy2ltlzTxgSCXxG4oG99n0oCVMCJ4-Y08cKLQ	android	2026-08-13 09:22:00.088056+00	2026-08-13 12:15:24.71978+00
9ca23656-ac9a-473f-99b0-8c8355f25dfa	46e089ae-aaa0-4bf3-add5-b1bf14a3b99b	fc3OULD7Qi6Iic7v7yLvBg:APA91bEhZXIAK9pyYZtcRsoyPRsVOF7Ya4CnBvfI5-FdrnqJGcY_wdvwLQisMiwMVCr6xlOyAQ42EjVt6k5P8fD3XOEDjKBKL-O5iiwVG4ZRC-St_FP01sY	android	2026-08-13 10:38:50.91414+00	2026-08-13 16:01:07.502813+00
a1ec3636-1f51-4d46-859c-4ee20e93d368	4d817052-c05d-4927-a54b-7bbd5a128909	czGRP6JPRmy5MLhFJ4NzxF:APA91bHT9Tm5HhdmGUNASYR8hFmFnxbA6TivZ9WLb-aM9MDdJ4wary7pGhuyXlVbYh-Rj5rWHOYT7HogKf6h91Bl7ZXXzpN7z0nPlSEweGpBb5FXdSD6njM	android	2026-08-10 20:59:31.602061+00	2026-08-13 15:45:04.935047+00
75f2012f-b0df-41b4-aaae-9843bd67737b	fd3b76ea-7205-4859-940b-d9725f5ebc00	d0cmHwJARtq0k9BF6ejHgP:APA91bGmhy8OaDP9QNaUt2LPSU312X2UVuiHlIXpFm17wNrEXTCeZKTPyys8WE9kNoHIz7IflT2s9NlNGmmo2uQp_Uz6ClzokvhvOj-iPkmFmRQmf36tP9E	android	2026-08-12 17:17:22.804671+00	2026-08-13 15:49:45.060046+00
c93dd168-8d89-4f08-895a-e5f6e2f20b69	76bdcafc-7873-4f66-8ffc-caa17bafadc3	d4gPWxdH3076ptNUh2GSKO:APA91bFHzAOk51CD6HFfQc9Pz_f_ONOSogJHQurH7PMp9esovdiInRX3TjjaOx_J4SkQqykLyqlald_D84sP1Os30SXxRi8-Ved2szUUoRKWc-xbArkGiAw	ios	2026-08-13 16:16:46.430536+00	2026-08-13 16:34:01.440185+00
\.


--
-- Data for Name: exam_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exam_submissions (id, exam_id, student_id, score, total_points, started_at, submitted_at, answers) FROM stdin;
\.


--
-- Data for Name: exams; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exams (id, teacher_id, course_id, title, duration_minutes, start_at, end_at, max_score, is_published, created_at, max_attempts, lesson_id) FROM stdin;
ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	4d817052-c05d-4927-a54b-7bbd5a128909	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	اختبار علي المصادر السماعية والقياسية	30	2026-08-12 18:00:17.201342+00	2026-08-19 18:00:17.201345+00	12	t	2026-08-12 15:02:19.296029+00	3	aa8be204-c7d0-4b1a-afc3-6c0bc8431dd7
\.


--
-- Data for Name: lesson_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lesson_documents (id, lesson_id, title, file_url, file_type, created_at) FROM stdin;
\.


--
-- Data for Name: lesson_progress; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lesson_progress (id, student_id, lesson_id, is_completed, watched_seconds, last_watched_at, view_count) FROM stdin;
8c2f061c-3775-4574-8568-962caabfa6b3	e16b180a-0e82-4cd4-97b2-57eadb181b4a	9a641534-3a1c-4004-a16b-e9b8a1f4d180	f	0	2026-08-13 03:12:30.246438+00	1
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lessons (id, course_id, title, description, video_source_type, video_url_or_id, duration_seconds, thumbnail_url, is_free_preview, "order", created_at, updated_at, max_views) FROM stdin;
445b0259-5e81-4e64-82df-a4d7ef27ecec	24a9a7a7-2f6e-4696-8883-35d4984be8e6	الاستعارة وأنواعها	شرح الاستعارة المكنية والتصريحية وكيفية التمييز بينهما	youtube	https://youtu.be/-F0CFaecpCM?si=pI2qGs7IISO14XO1	\N	\N	f	0	2026-08-11 16:41:45.455199+00	2026-08-11 16:41:45.455199+00	3
aa6545c3-7eda-4dd5-b3af-2e7c36355d75	24a9a7a7-2f6e-4696-8883-35d4984be8e6	التشبيه وأنواعه والتدريب عليه	شرح الفرق بين التشبيه المفرد والمركب والتمييز بينهما	youtube	https://youtu.be/2PIatAZOQds?si=EVeBJVWwKiQtrmMp	\N	\N	f	0	2026-08-11 16:29:56.254123+00	2026-08-11 16:42:00.752142+00	3
5a01509e-1631-4e3b-bc8c-45a87f2180af	24a9a7a7-2f6e-4696-8883-35d4984be8e6	تطبيقات علي الاستعارة بأنواعها	بيان كيفية حل الأسئلة الخاصة بالاستعارة	youtube	https://youtu.be/T0xRicCDT2U?si=j2F8ajuLVBtY60Qd	\N	\N	f	0	2026-08-11 16:45:39.906384+00	2026-08-11 16:45:39.906384+00	3
9a641534-3a1c-4004-a16b-e9b8a1f4d180	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	أسلوب التفضيل وحالات اسم التفضيل	أسلوب التفضيل وصياغته وحالات اسم التفضيل وحكم مطابقته مع المفضل	youtube	https://youtu.be/UW7P5XsGrn8?si=S5aZttqMf7ZB2QQy	\N	\N	t	0	2026-08-11 15:37:59.513904+00	2026-08-11 15:38:42.283315+00	3
fbac0173-d456-4fbb-8969-0eb7f291cd90	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	اسم المفعول صياغته وإعماله	شرح صياغة اسم المفعول وكيفية إعماله	youtube	https://youtu.be/RC_A6LyoQEY?si=bG6BcdNO4yHGBzQ1	\N	\N	f	0	2026-08-11 15:43:46.450888+00	2026-08-11 15:43:46.450888+00	3
18854bc6-3dd0-460f-a3aa-9e4a8d264fd0	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	تطبيقات على المشتقات واسم التفضيل	تطبيقات وتدريبات متنوعة علي إعمال المشتقات وأسلوب التفضيل	youtube	https://youtu.be/S26fuTf0obs?si=FOiUO3SvnwcWf_bM	\N	\N	f	0	2026-08-11 15:50:45.004634+00	2026-08-11 15:50:45.004634+00	3
f2a876cd-5bc0-4afa-9f6f-3ce4b387b0c2	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	اسم الفاعل صياغته وإعماله	شرح اسم الفاعل وكيفية صياغته وإعماله والتدريب عليها	youtube	https://youtu.be/DIddTXDGQns?si=WHzRQqfHN_Q6zkjx	\N	\N	f	0	2026-08-11 15:53:53.911155+00	2026-08-11 15:53:53.911155+00	3
201176ba-ab82-4824-8dc3-c2a2fd704e4f	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	صيغ المبالغة كيفية صياغتها وإعمالها	شرح صيغ المبالغة وكيفية صياغتها وإعمالها والتدريب عليها	youtube	https://youtu.be/F-_2CYNmtrI?si=B6cx_lep4TSRANxa	\N	\N	f	0	2026-08-11 16:00:46.491347+00	2026-08-11 16:00:46.491347+00	3
aa8be204-c7d0-4b1a-afc3-6c0bc8431dd7	b0ad61b6-0303-4baa-ad69-4e90d1a3cc32	المصادر الصريحة( السماعي والقياسي )	شرح المصدر الصريح السماعي والقياسي والتدريب عليها	youtube	https://youtu.be/MetvwWkH3pw?si=mJnotV5qbxFI_qTy	\N	\N	f	0	2026-08-11 16:11:48.435+00	2026-08-11 16:11:48.435+00	3
8db68ef3-c4d3-464d-a43e-4140ead18b3c	24a9a7a7-2f6e-4696-8883-35d4984be8e6	التعبير الحقيقي والتعبير المجازي	شرح الفرق بين التعبير الحقيقي والتعبير المجازي والتدريب عليهما	youtube	https://youtu.be/mH7X5qUvJHo?si=SHrVZDONhv1mYxHp	\N	\N	f	0	2026-08-11 16:26:56.91837+00	2026-08-11 16:26:56.91837+00	3
869f5d83-64fa-46da-bd81-2bde4d66b808	24a9a7a7-2f6e-4696-8883-35d4984be8e6	التشبيه المركب والتمييز بينهما	شرح التشبيه المركب التمثيلي والضمني وكيفية التمييز بينهما	youtube	https://youtu.be/Xud_pATLJmg?si=FbW2T-6gAFkmKryF	\N	\N	f	0	2026-08-11 16:34:23.539976+00	2026-08-11 16:34:23.539976+00	3
99e5ab0c-49ea-4c56-b38d-67602693cdf0	24a9a7a7-2f6e-4696-8883-35d4984be8e6	تطبيقات على التشبيه	أمثلة متنوعة وتطبيقات علي التشبيه بأنواعه	youtube	https://youtu.be/7ScbSer4yfQ?si=A_DOOVR-5ldYLRbF	\N	\N	f	0	2026-08-11 16:37:34.62186+00	2026-08-11 16:37:34.62186+00	3
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, title, body, category, is_read, created_at) FROM stdin;
12613a82-a27a-45a3-8db2-4abb3ab8c155	4d817052-c05d-4927-a54b-7bbd5a128909	تم تفعيل حسابك	مرحباً بك في المنصة، تم تفعيل حسابك كمعلم ويمكنك الآن إدارة دوراتك.	system	f	2026-08-11 03:14:23.88925+00
848aa770-8dec-4005-a567-5be166fe046b	16128ef2-796d-47e9-a07e-87a5564eef99	تم تفعيل حسابك	مرحباً بك في المنصة، تم تفعيل حسابك كمعلم ويمكنك الآن إدارة دوراتك.	system	f	2026-08-13 00:49:49.939857+00
827455ef-e65a-4673-90c0-05e31b30a194	2bb7a3ea-da47-4d47-ac23-e35326458c87	تم تفعيل اشتراكك	تم تفعيل اشتراكك بنجاح، يمكنك الآن متابعة جميع الدروس.	system	f	2026-08-13 00:52:22.961484+00
d5b23d5e-f063-4442-9bb8-ab03dc46e361	e16b180a-0e82-4cd4-97b2-57eadb181b4a	تم تفعيل اشتراكك	تم تفعيل اشتراكك بنجاح، يمكنك الآن متابعة جميع الدروس.	system	f	2026-08-13 03:12:16.639843+00
65da7341-5e27-48a9-80ad-0352a995c75d	76bdcafc-7873-4f66-8ffc-caa17bafadc3	تم تفعيل حسابك	مرحباً بك في المنصة، تم تفعيل حسابك كمعلم ويمكنك الآن إدارة دوراتك.	system	t	2026-08-13 16:13:22.408846+00
\.


--
-- Data for Name: payment_methods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_methods (id, student_id, card_holder, card_last4, card_brand, expiry_month, expiry_year, is_default, created_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, payer_id, payer_type, plan_id, amount, payment_gateway, gateway_transaction_id, status, created_at, course_id) FROM stdin;
09d25b12-0a40-4e8f-b6da-18fb662d1909	2bb7a3ea-da47-4d47-ac23-e35326458c87	student_subscription	\N	0.00	fawry	CODE-TH-LNMC-UQJG	success	2026-08-13 00:52:23.068297+00	\N
7d38d4cb-8291-42a1-8b1a-84726faff82f	e16b180a-0e82-4cd4-97b2-57eadb181b4a	student_subscription	\N	0.00	fawry	CODE-TH-QCKQ-DEJX	success	2026-08-13 03:12:16.764394+00	\N
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.questions (id, exam_id, question_type, text, options, correct_answer, points, "order", created_at) FROM stdin;
dfeed1a8-1cc1-4914-aab2-a22668ffe7c4	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	تسعي مصر لإيجاد الحلول من أجل تسوية النزاع وكشف ادعاءات اليهود\nالمصدر الخماسي في العبارة ووزنه	["إيجاد( إفعال)", "تسوية( تفعلة)", "النزاع( الفعال)", "ادعاءات ( افتعالات)"]	د	2	0	2026-08-12 15:07:08.510013+00
cacc9ba4-a766-4976-8ec3-90e31e62e849	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	حدد العبارة التي تضمنت مصدرا سداسيا	["استواء الطرق مفيد في تقليل الحوادث", "استياء الفريق من أنانية الفرد طبيعي", "استيلاء اليهود علي غزة جريمة وعار", "استباق الأحداث وسوء الظن يدمر العلاقة"]	ج	2	0	2026-08-12 15:10:42.456693+00
d2b3f65d-24af-4c3e-b78a-dd37305d34a8	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	الحكيم يتولي المسئولية ٠٠٠٠٠رشيدا ويدير أعماله بغير ٠٠٠٠٠٠٠\nضع مكان النقط مصدر الفعلين( تولي) ( تواني) علي الترتيب	["تول _ تواني", "تولية _ تواني", "توليا _ توان", "تولي _ توان"]	ج	2	0	2026-08-12 15:15:14.126539+00
6683e060-6eab-4021-aa9b-5c3e10d67405	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	استلال الأحقاد وإيلاف القلوب يكون بالتودد والحوار \nبين المصدر ونوعه في المقولة السابقة	["الحوار _ ثلاثي", "استلال _ سداسي", "التودد _ رباعي", "إيلاف _ رباعي"]	د	2	0	2026-08-12 15:17:46.611513+00
1a10e9b2-46d9-40a3-b48e-cbb61ee9e195	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	mcq	لا تسترقوا السمع ولا تسترقوا الناس وقد خلقوا أحرارا \nمصدر الفعلين( تسترقوا ) ( تسترقوا ) علي الترتيب	["استرقاق _ استراق", "استراق _ استرقاق", "إسراق _ تسارق", "استراق _ تسريق"]	ب	2	0	2026-08-12 15:22:32.104009+00
9faab955-91be-4ab9-b83d-114aa2c9235d	ae6a7591-c7d3-4495-b4b2-ab3b3276aad0	essay	هيأني الكتاب للامتحان فتهيأت \nاكتب مصدر الفعلين( هيأني ) والفعل( تهيأت ) علي الترتيب	[]	\N	2	0	2026-08-12 15:27:43.84554+00
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.students (id, grade_level, parent_phone, created_at) FROM stdin;
f2836a0a-6e10-44e6-8194-c6d859ae8548	first	01000000000	2026-08-09 14:16:43.055975+00
56de2f45-5281-48a3-ac7f-8ce0c3300c46	third	01090796360	2026-08-12 15:35:52.10742+00
0d9a8081-3732-48e8-9d96-ddd4a2388e52	second	01117695557	2026-08-12 15:37:22.906704+00
5b876217-bc9e-4f3c-b66f-03f3cfeb2617	third	01004305217	2026-08-12 15:38:09.293603+00
79386e13-3ee0-43e9-ab80-de95d5b2a113	third	01024674984	2026-08-12 15:38:52.720404+00
ab84b692-8481-494a-a677-a7e671a37a30	first	01279183556	2026-08-12 15:39:26.152234+00
bfa781f8-3bc8-4601-8814-73c99cf589a1	second	01012806115	2026-08-12 15:41:46.376059+00
fdf7ac58-4cc3-4e60-9a17-583f63c6c551	second	01032788003	2026-08-12 15:43:29.597667+00
2a48c2fb-9ccc-4641-aa8e-3e5a0c2ab606	second	01061704413	2026-08-12 15:44:21.68021+00
5bc8b321-dda7-4d6d-888a-b758bc5162cd	first	01061260066	2026-08-12 15:53:51.682017+00
6d8e3af7-873c-4303-9efd-45c9a9c6bb5a	second	01553033744	2026-08-12 15:55:32.421776+00
fd3b76ea-7205-4859-940b-d9725f5ebc00	first	01226400941	2026-08-12 16:18:09.845083+00
f445ca66-2e02-414b-b661-483039071177	third	01025204591	2026-08-12 16:18:57.50385+00
10f030a2-883b-49a5-adc7-fe753c42ce5e	first	01000000000	2026-08-12 16:20:37.214511+00
026c809c-79ab-4a19-a2e5-302cb224a67f	third	01007600751	2026-08-12 16:24:05.647211+00
9dfd72f1-514c-468a-befa-67090727970f	first	01062686330	2026-08-12 16:39:25.680841+00
74e34941-6b14-4c9b-85c4-214494953b6d	third	01092528227	2026-08-12 16:41:10.726979+00
0c77846c-9906-4c72-98a0-f15f05b8f9b5	second	01286006824	2026-08-12 16:45:36.351009+00
e2b106d2-7382-4f91-a640-20f948f921ac	third	01098864414	2026-08-12 17:08:36.782292+00
d9101537-bb4c-4b49-aaaf-384c50f0e645	first	01095776440	2026-08-12 17:35:43.32633+00
fd2e4f8a-030c-4698-b7cc-a39b647ee990	second	01068519888	2026-08-12 17:36:14.113904+00
12d743a4-bede-4102-8da0-f30b691c6574	third	01009725990	2026-08-12 17:56:36.554392+00
2b2d5aad-f514-47a2-8912-b04421bf17cb	first	01008488558	2026-08-12 18:16:41.532363+00
c5bd97aa-af9d-4214-a249-f3183d5c08fb	first	01030661951	2026-08-12 18:41:16.722158+00
fc2362a4-d534-4848-a9bd-497a6abf783e	first	01012230257	2026-08-12 18:50:56.968062+00
b795abfe-b02b-4de7-ad96-da7feab8ae24	third	01007365709	2026-08-12 20:12:56.078685+00
23988780-f6e0-4f0c-b62e-585f801a05d0	third	01044843231	2026-08-12 21:20:58.028477+00
4c463009-45b8-43c6-93c1-6e621ed2747f	third	01028516169	2026-08-12 22:41:03.876363+00
86dcafc0-6fe0-4a18-b143-bad5e2ffa428	third	01096462825	2026-08-13 00:41:43.447946+00
2bb7a3ea-da47-4d47-ac23-e35326458c87	third	01096462825	2026-08-13 00:52:17.496961+00
e16b180a-0e82-4cd4-97b2-57eadb181b4a	third	01096462825	2026-08-13 03:12:03.718505+00
a7b5768d-1837-436e-9e00-0cd136db2fd6	third	01095102757	2026-08-13 06:19:04.181411+00
46e089ae-aaa0-4bf3-add5-b1bf14a3b99b	first	01060867176	2026-08-13 10:38:51.078151+00
6c44f50e-cdc6-4de4-8274-1315e51fa09b	first	01024674984	2026-08-13 11:42:12.69602+00
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subjects (id, name_ar, name_en, icon_name, is_active, display_order, created_at) FROM stdin;
2e2fbd71-42dc-4c89-b684-aa3f0adb3b81	رياضيات	Mathematics	calculate	t	1	2026-07-21 02:08:27.435053+00
6ac2422a-f0bc-4513-918c-1772bff1e38b	فيزياء	Physics	science	t	2	2026-07-21 02:08:27.435053+00
fc1a4669-e18b-4ef9-907a-d83ef62d6323	كيمياء	Chemistry	science_outlined	t	3	2026-07-21 02:08:27.435053+00
27d99cbf-cc94-4371-aae0-9df04d498b8a	أحياء	Biology	eco	t	4	2026-07-21 02:08:27.435053+00
5356a563-644a-45e7-b708-55c616b4f095	لغة عربية	Arabic	menu_book	t	5	2026-07-21 02:08:27.435053+00
cf543cd8-4155-488c-a48b-c8ed4778067f	لغة إنجليزية	English	language	t	6	2026-07-21 02:08:27.435053+00
5d735415-fd44-4d65-95be-f78ad4bba565	لغة فرنسية	French	translate	t	7	2026-07-21 02:08:27.435053+00
57e729ca-2c03-41af-b2e1-4b943f309df3	تاريخ	History	history_edu	t	8	2026-07-21 02:08:27.435053+00
50e648b3-69b6-416c-8687-95f4e799e1de	جغرافيا	Geography	public	t	9	2026-07-21 02:08:27.435053+00
23168953-c01e-4e6f-ae43-f85c41d6f6c7	فلسفة	Philosophy	psychology	t	10	2026-07-21 02:08:27.435053+00
\.


--
-- Data for Name: subscription_plans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_plans (id, name, billing_period, price, max_students, max_courses, storage_limit_mb, is_active, display_order, created_at, updated_at) FROM stdin;
25c2b387-8ede-4bbd-a55f-e9822e07207c	الباقة الشهرية	monthly	99.99	\N	\N	\N	t	1	2026-07-21 02:08:27.435053+00	2026-07-21 02:08:27.435053+00
1be2c0a1-9eff-4106-a2c4-c9bdd73efada	باقة الفصل	term	249.99	\N	\N	\N	t	2	2026-07-21 02:08:27.435053+00	2026-07-21 02:08:27.435053+00
c29b59af-98c0-46ee-a58f-a4e19b2eb8e8	باقة السنة	yearly	599.99	\N	\N	\N	t	3	2026-07-21 02:08:27.435053+00	2026-07-21 02:08:27.435053+00
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscriptions (id, student_id, teacher_id, status, starts_at, expires_at, created_at, activation_code_id) FROM stdin;
db13827f-b62f-41f0-943d-0019d677cec5	e16b180a-0e82-4cd4-97b2-57eadb181b4a	4d817052-c05d-4927-a54b-7bbd5a128909	active	2026-08-13 03:12:16.639843+00	2027-08-13 03:12:16.639843+00	2026-08-13 03:12:16.639843+00	4fd0d827-4954-486d-a22a-35ca69e315c0
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.teachers (id, subject_id, stage, bio, approval_status, rejection_reason, subscription_plan_id, subscription_expires_at, created_at, avatar_url, id_card_front_url, id_card_back_url, teacher_proof_url, teaching_system, governorate, teaching_mode, stages, baccalaureate_tracks) FROM stdin;
4d817052-c05d-4927-a54b-7bbd5a128909	5356a563-644a-45e7-b708-55c616b4f095	first	كبير معلمين لغة عربية ث عامة\nليسانس دار العلوم( لغة عربية وعلوم إسلامية )\nمدرسة شبراخيت الثانوية للبنات	approved	\N	\N	\N	2026-08-10 19:31:54.446515+00	\N	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/id_front/1786390310035.jpg	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/id_back/1786390311557.jpg	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/4d817052-c05d-4927-a54b-7bbd5a128909/proof/1786390313155.jpg	general	الإسكندرية	both	{first,second,third}	{}
76bdcafc-7873-4f66-8ffc-caa17bafadc3	5356a563-644a-45e7-b708-55c616b4f095	second	\N	approved	\N	\N	\N	2026-08-13 16:12:54.832481+00	\N	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/76bdcafc-7873-4f66-8ffc-caa17bafadc3/id_front/1786637559080.jpg	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/76bdcafc-7873-4f66-8ffc-caa17bafadc3/id_back/1786637568096.jpg	https://ilimclnfdrksvpacbmji.supabase.co/storage/v1/object/public/teacher-documents/76bdcafc-7873-4f66-8ffc-caa17bafadc3/proof/1786637570962.jpg	general	القاهرة	online	{second,first,third}	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, full_name, phone, role, avatar_url, created_at, updated_at) FROM stdin;
bfa781f8-3bc8-4601-8814-73c99cf589a1	omniaelkohail608@gmail.com	أمنية علاء منصور الكحيل	01012806115	student	\N	2026-08-12 15:41:46.255674+00	2026-08-13 00:49:49.079525+00
2bb7a3ea-da47-4d47-ac23-e35326458c87	me@gmail.com	test	01096462825	student	\N	2026-08-13 00:52:17.36569+00	2026-08-13 00:52:17.36569+00
e16b180a-0e82-4cd4-97b2-57eadb181b4a	dtdg@gmail.com	g	01096462825	student	\N	2026-08-13 03:12:03.280448+00	2026-08-13 03:12:03.280448+00
a7b5768d-1837-436e-9e00-0cd136db2fd6	youmnazidan06@gmail.com	يمني كارم زيدان	01095102757	student	\N	2026-08-13 06:19:04.001813+00	2026-08-13 06:19:04.001813+00
46e089ae-aaa0-4bf3-add5-b1bf14a3b99b	salmamohamed1790@gmail.com	سلمي محمد النجار	01060867176	student	\N	2026-08-13 10:38:50.860921+00	2026-08-13 10:38:50.860921+00
f2836a0a-6e10-44e6-8194-c6d859ae8548	soon@gmail.com	slam	ewqrwqerwe	student	\N	2026-08-09 14:16:42.828186+00	2026-08-09 14:16:42.828186+00
4d817052-c05d-4927-a54b-7bbd5a128909	hasaninelsaid99@gmail.com	حسنين السيد محمد عتمان	01069114924	teacher	\N	2026-08-10 19:31:50.01769+00	2026-08-10 19:31:50.01769+00
56de2f45-5281-48a3-ac7f-8ce0c3300c46	tarekallam749@gmail.com	طارق علام شعبان علام	01090796360	student	\N	2026-08-12 15:35:51.751153+00	2026-08-12 15:35:51.751153+00
0d9a8081-3732-48e8-9d96-ddd4a2388e52	helalzedan2@gmail.com	هلال محمد نعيم مختار زيدان	01117695557	student	\N	2026-08-12 15:37:22.7137+00	2026-08-12 15:37:22.7137+00
5b876217-bc9e-4f3c-b66f-03f3cfeb2617	ahmednagy123543@gmail.com	احمد ناجي محمد عبد الصادق	01004305217	student	\N	2026-08-12 15:38:09.182396+00	2026-08-12 15:38:09.182396+00
79386e13-3ee0-43e9-ab80-de95d5b2a113	kareemmansor815@gmail.com	كريم صبحي محمد عبد الصادق	01024674984	student	\N	2026-08-12 15:38:52.578477+00	2026-08-12 15:38:52.578477+00
ab84b692-8481-494a-a677-a7e671a37a30	menakper@gmail.com	مينا انيس	01279183556	student	\N	2026-08-12 15:39:24.295052+00	2026-08-12 15:39:24.295052+00
fdf7ac58-4cc3-4e60-9a17-583f63c6c551	km3312521@gmail.com	كريم زغلول عبد العزيز	01032788003	student	\N	2026-08-12 15:43:29.455795+00	2026-08-12 15:43:29.455795+00
6c44f50e-cdc6-4de4-8274-1315e51fa09b	mansoryasmin3@gmail.com	ياسمين صبحي محمد عبدالصادق	01024674984	student	\N	2026-08-13 11:42:11.814874+00	2026-08-13 11:42:11.814874+00
76bdcafc-7873-4f66-8ffc-caa17bafadc3	s1@gmail.com	sphinx	01096462825	teacher	\N	2026-08-13 16:12:39.199255+00	2026-08-13 16:12:39.199255+00
2a48c2fb-9ccc-4641-aa8e-3e5a0c2ab606	alizather1@gmail.com	محمد علي محمد فتحى زيتحار	01061704413	student	\N	2026-08-12 15:44:21.37172+00	2026-08-12 15:44:21.37172+00
5bc8b321-dda7-4d6d-888a-b758bc5162cd	ag7298742@gmail.com	احمد جلال بسيوني الخرادلي	01061260066	student	\N	2026-08-12 15:53:51.512377+00	2026-08-12 15:53:51.512377+00
6d8e3af7-873c-4303-9efd-45c9a9c6bb5a	omarelserafy36@gmail.com	عمر محمود الصيرفى	01553033744	student	\N	2026-08-12 15:55:32.246274+00	2026-08-12 15:55:32.246274+00
fd3b76ea-7205-4859-940b-d9725f5ebc00	rewasramzy842@gmail.com	رويس رمزي ذكي جرجس	01226400941	student	\N	2026-08-12 16:18:09.614492+00	2026-08-12 16:18:09.614492+00
f445ca66-2e02-414b-b661-483039071177	amp3456700@gmail.com	أحمد يوسف محبوب	01025204591	student	\N	2026-08-12 16:18:57.30092+00	2026-08-12 16:18:57.30092+00
10f030a2-883b-49a5-adc7-fe753c42ce5e	as2184363@gmail.com	ahmed serag	01096018287	student	\N	2026-08-12 16:20:37.015218+00	2026-08-12 16:20:37.015218+00
026c809c-79ab-4a19-a2e5-302cb224a67f	ryhikkvfdshkncjk@gmail.com	رحمه احمد حموده	01007600751	student	\N	2026-08-12 16:24:05.13615+00	2026-08-12 16:24:05.13615+00
9dfd72f1-514c-468a-befa-67090727970f	liverpooly011@gmail.com	ملك رضوان عباس خليفة	01062686330	student	\N	2026-08-12 16:39:25.534923+00	2026-08-12 16:39:25.534923+00
74e34941-6b14-4c9b-85c4-214494953b6d	olaatman987@gmail.com	علا علاء محمد عبد اللطيف عتمان	01507961250	student	\N	2026-08-12 16:41:10.606654+00	2026-08-12 16:43:47.971865+00
0c77846c-9906-4c72-98a0-f15f05b8f9b5	h9090897@gmail.com	حنين سعيد عبد الشافي	01286006824	student	\N	2026-08-12 16:45:36.189251+00	2026-08-12 16:45:36.189251+00
e2b106d2-7382-4f91-a640-20f948f921ac	zeadelsalamoni@gmail.com	زياد سعيد السلاموني	01098864414	student	\N	2026-08-12 17:08:36.456253+00	2026-08-12 17:08:36.456253+00
d9101537-bb4c-4b49-aaaf-384c50f0e645	heba.essam.elaasar@t2.com	هبه الله عصام السيد الاعصر	01095776440	student	\N	2026-08-12 17:35:43.086556+00	2026-08-12 17:35:43.086556+00
fd2e4f8a-030c-4698-b7cc-a39b647ee990	h01006916607@gmail.com	محمد حسين محمود النجار	01068519888	student	\N	2026-08-12 17:36:13.961024+00	2026-08-12 17:36:13.961024+00
12d743a4-bede-4102-8da0-f30b691c6574	ahmedessamzaied@gmail.com	أحمد عصام محمود زايد	01009725990	student	\N	2026-08-12 17:56:36.280445+00	2026-08-12 17:56:36.280445+00
2b2d5aad-f514-47a2-8912-b04421bf17cb	mlkm2011820@gmail.com	ملك محمود فتحى عواض	01008488558	student	\N	2026-08-12 18:16:41.198961+00	2026-08-12 18:16:41.198961+00
c5bd97aa-af9d-4214-a249-f3183d5c08fb	mhmdteka51@gmail.com	ليلى وليد محمد جاد عتمان	01030661951	student	\N	2026-08-12 18:41:16.546815+00	2026-08-12 18:41:16.546815+00
fc2362a4-d534-4848-a9bd-497a6abf783e	ahmedramadanfathy2010@gmail.com	أحمد رمضان العتر	01012230257	student	\N	2026-08-12 18:50:56.809173+00	2026-08-12 18:50:56.809173+00
b795abfe-b02b-4de7-ad96-da7feab8ae24	rahlam041@gmail.com	أحلام رضا مختار زيدان	01007365709	student	\N	2026-08-12 20:12:55.812934+00	2026-08-12 20:12:55.812934+00
23988780-f6e0-4f0c-b62e-585f801a05d0	arwafawaz27@gmail.com	اروى فتحي فواز	01044843231	student	\N	2026-08-12 21:20:57.829852+00	2026-08-12 21:20:57.829852+00
4c463009-45b8-43c6-93c1-6e621ed2747f	elarabyz141@gmail.com	زياد عبد الحميد عبد المنعم محمد عبد الحميد العربي	01028516169	student	\N	2026-08-12 22:41:03.658017+00	2026-08-12 22:41:03.658017+00
86dcafc0-6fe0-4a18-b143-bad5e2ffa428	son@gmail.com	test	01096462825	student	\N	2026-08-13 00:41:43.325012+00	2026-08-13 00:41:43.325012+00
16128ef2-796d-47e9-a07e-87a5564eef99	fych@gmail.com	test	01096462825	teacher	\N	2026-08-13 00:49:18.562398+00	2026-08-13 00:49:18.562398+00
\.


--
-- Name: activation_codes activation_codes_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activation_codes
    ADD CONSTRAINT activation_codes_code_key UNIQUE (code);


--
-- Name: activation_codes activation_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activation_codes
    ADD CONSTRAINT activation_codes_pkey PRIMARY KEY (id);


--
-- Name: bookmarks bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: bookmarks bookmarks_student_id_course_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_student_id_course_id_key UNIQUE (student_id, course_id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: course_reviews course_reviews_course_id_student_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_reviews
    ADD CONSTRAINT course_reviews_course_id_student_id_key UNIQUE (course_id, student_id);


--
-- Name: course_reviews course_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_reviews
    ADD CONSTRAINT course_reviews_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_token_key UNIQUE (token);


--
-- Name: exam_submissions exam_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_submissions
    ADD CONSTRAINT exam_submissions_pkey PRIMARY KEY (id);


--
-- Name: exams exams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_pkey PRIMARY KEY (id);


--
-- Name: lesson_documents lesson_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_documents
    ADD CONSTRAINT lesson_documents_pkey PRIMARY KEY (id);


--
-- Name: lesson_progress lesson_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_progress
    ADD CONSTRAINT lesson_progress_pkey PRIMARY KEY (id);


--
-- Name: lesson_progress lesson_progress_student_id_lesson_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_progress
    ADD CONSTRAINT lesson_progress_student_id_lesson_id_key UNIQUE (student_id, lesson_id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_student_id_teacher_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_student_id_teacher_id_key UNIQUE (student_id, teacher_id);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_comments_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comments_author ON public.comments USING btree (author_id);


--
-- Name: idx_comments_lesson; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comments_lesson ON public.comments USING btree (lesson_id);


--
-- Name: idx_courses_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_courses_published ON public.courses USING btree (is_published);


--
-- Name: idx_courses_teacher; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_courses_teacher ON public.courses USING btree (teacher_id);


--
-- Name: idx_device_tokens_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_device_tokens_user ON public.device_tokens USING btree (user_id);


--
-- Name: idx_exam_submissions_exam; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exam_submissions_exam ON public.exam_submissions USING btree (exam_id);


--
-- Name: idx_exam_submissions_student; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exam_submissions_student ON public.exam_submissions USING btree (student_id);


--
-- Name: idx_exams_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exams_course ON public.exams USING btree (course_id);


--
-- Name: idx_exams_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exams_dates ON public.exams USING btree (start_at, end_at);


--
-- Name: idx_exams_lesson; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exams_lesson ON public.exams USING btree (lesson_id);


--
-- Name: idx_exams_teacher; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exams_teacher ON public.exams USING btree (teacher_id);


--
-- Name: idx_lesson_documents_lesson; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lesson_documents_lesson ON public.lesson_documents USING btree (lesson_id);


--
-- Name: idx_lesson_progress_lesson; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lesson_progress_lesson ON public.lesson_progress USING btree (lesson_id);


--
-- Name: idx_lesson_progress_student; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lesson_progress_student ON public.lesson_progress USING btree (student_id);


--
-- Name: idx_lessons_course; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lessons_course ON public.lessons USING btree (course_id);


--
-- Name: idx_lessons_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lessons_order ON public.lessons USING btree (course_id, "order");


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id, created_at DESC);


--
-- Name: idx_payments_payer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_payer ON public.payments USING btree (payer_id);


--
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);


--
-- Name: idx_questions_exam; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_questions_exam ON public.questions USING btree (exam_id);


--
-- Name: idx_subscriptions_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscriptions_status ON public.subscriptions USING btree (status);


--
-- Name: idx_subscriptions_student; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscriptions_student ON public.subscriptions USING btree (student_id);


--
-- Name: idx_subscriptions_teacher; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscriptions_teacher ON public.subscriptions USING btree (teacher_id);


--
-- Name: idx_teachers_approval; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teachers_approval ON public.teachers USING btree (approval_status);


--
-- Name: idx_teachers_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teachers_subject ON public.teachers USING btree (subject_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: notifications_user_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_user_created_idx ON public.notifications USING btree (user_id, created_at DESC);


--
-- Name: exams trg_notify_exam_published; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify_exam_published AFTER UPDATE ON public.exams FOR EACH ROW EXECUTE FUNCTION public.notify_exam_published();


--
-- Name: subscriptions trg_notify_subscription_activation; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify_subscription_activation AFTER INSERT ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.notify_subscription_activation();


--
-- Name: teachers trg_notify_teacher_approval; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_notify_teacher_approval AFTER UPDATE OF approval_status ON public.teachers FOR EACH ROW EXECUTE FUNCTION public.notify_teacher_approval();


--
-- Name: courses trigger_courses_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_courses_updated_at BEFORE UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: exam_submissions trigger_exam_attempt_limit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_exam_attempt_limit BEFORE INSERT ON public.exam_submissions FOR EACH ROW EXECUTE FUNCTION public.enforce_exam_attempt_limit();


--
-- Name: lessons trigger_lessons_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_lessons_updated_at BEFORE UPDATE ON public.lessons FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: exams trigger_notify_exam_published; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_notify_exam_published AFTER UPDATE OF is_published ON public.exams FOR EACH ROW WHEN (((new.is_published = true) AND (old.is_published = false))) EXECUTE FUNCTION public.notify_students_exam_published();


--
-- Name: lessons trigger_notify_lesson_added; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_notify_lesson_added AFTER INSERT ON public.lessons FOR EACH ROW EXECUTE FUNCTION public.notify_students_lesson_added();


--
-- Name: subscription_plans trigger_plans_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_plans_updated_at BEFORE UPDATE ON public.subscription_plans FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: questions trigger_questions_score_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_questions_score_update AFTER INSERT OR DELETE OR UPDATE ON public.questions FOR EACH ROW EXECUTE FUNCTION public.compute_exam_max_score();


--
-- Name: notifications trigger_send_fcm_push; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_send_fcm_push AFTER INSERT ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.send_fcm_push();


--
-- Name: subscriptions trigger_subscription_expiry; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_subscription_expiry BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.check_subscription_expiry();


--
-- Name: users trigger_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: activation_codes activation_codes_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activation_codes
    ADD CONSTRAINT activation_codes_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE SET NULL;


--
-- Name: activation_codes activation_codes_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activation_codes
    ADD CONSTRAINT activation_codes_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: activation_codes activation_codes_used_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activation_codes
    ADD CONSTRAINT activation_codes_used_by_fkey FOREIGN KEY (used_by) REFERENCES public.students(id);


--
-- Name: bookmarks bookmarks_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: bookmarks bookmarks_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: comments comments_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: comments comments_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: course_reviews course_reviews_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_reviews
    ADD CONSTRAINT course_reviews_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: course_reviews course_reviews_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_reviews
    ADD CONSTRAINT course_reviews_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: courses courses_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: device_tokens device_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: exam_submissions exam_submissions_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_submissions
    ADD CONSTRAINT exam_submissions_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exams(id) ON DELETE CASCADE;


--
-- Name: exam_submissions exam_submissions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_submissions
    ADD CONSTRAINT exam_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: exams exams_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE SET NULL;


--
-- Name: exams exams_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE SET NULL;


--
-- Name: exams exams_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: lesson_documents lesson_documents_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_documents
    ADD CONSTRAINT lesson_documents_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: lesson_progress lesson_progress_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_progress
    ADD CONSTRAINT lesson_progress_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: lesson_progress lesson_progress_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_progress
    ADD CONSTRAINT lesson_progress_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: lessons lessons_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: payment_methods payment_methods_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: payments payments_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE SET NULL;


--
-- Name: payments payments_payer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payer_id_fkey FOREIGN KEY (payer_id) REFERENCES public.users(id);


--
-- Name: payments payments_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id);


--
-- Name: questions questions_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exams(id) ON DELETE CASCADE;


--
-- Name: students students_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_id_fkey FOREIGN KEY (id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_activation_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_activation_code_id_fkey FOREIGN KEY (activation_code_id) REFERENCES public.activation_codes(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: teachers teachers_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_id_fkey FOREIGN KEY (id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: teachers teachers_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: teachers teachers_subscription_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_subscription_plan_id_fkey FOREIGN KEY (subscription_plan_id) REFERENCES public.subscription_plans(id);


--
-- Name: users users_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: activation_codes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.activation_codes ENABLE ROW LEVEL SECURITY;

--
-- Name: courses admin_all_courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_courses ON public.courses USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: device_tokens admin_all_device_tokens; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_device_tokens ON public.device_tokens USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: exams admin_all_exams; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_exams ON public.exams USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: lessons admin_all_lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_lessons ON public.lessons USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: notifications admin_all_notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_notifications ON public.notifications USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: payments admin_all_payments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_payments ON public.payments USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: subscription_plans admin_all_plans; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_plans ON public.subscription_plans USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: questions admin_all_questions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_questions ON public.questions USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: students admin_all_students; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_students ON public.students USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: subjects admin_all_subjects; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_subjects ON public.subjects USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: exam_submissions admin_all_submissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_submissions ON public.exam_submissions USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: subscriptions admin_all_subscriptions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_subscriptions ON public.subscriptions USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: teachers admin_all_teachers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_teachers ON public.teachers USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: users admin_all_users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY admin_all_users ON public.users USING ((((auth.jwt() -> 'user_metadata'::text) ->> 'role'::text) = 'super_admin'::text));


--
-- Name: bookmarks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

--
-- Name: bookmarks bookmarks_delete_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bookmarks_delete_own ON public.bookmarks FOR DELETE USING ((student_id = auth.uid()));


--
-- Name: bookmarks bookmarks_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bookmarks_insert_own ON public.bookmarks FOR INSERT WITH CHECK ((student_id = auth.uid()));


--
-- Name: bookmarks bookmarks_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bookmarks_select_own ON public.bookmarks FOR SELECT USING ((student_id = auth.uid()));


--
-- Name: comments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

--
-- Name: comments comments_delete_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY comments_delete_own ON public.comments FOR DELETE USING ((author_id = auth.uid()));


--
-- Name: comments comments_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY comments_insert_own ON public.comments FOR INSERT WITH CHECK ((author_id = auth.uid()));


--
-- Name: comments comments_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY comments_select_all ON public.comments FOR SELECT USING (true);


--
-- Name: comments comments_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY comments_update_own ON public.comments FOR UPDATE USING ((author_id = auth.uid()));


--
-- Name: course_reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.course_reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: course_reviews course_reviews_delete_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY course_reviews_delete_own ON public.course_reviews FOR DELETE USING ((student_id = auth.uid()));


--
-- Name: course_reviews course_reviews_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY course_reviews_insert_own ON public.course_reviews FOR INSERT WITH CHECK ((student_id = auth.uid()));


--
-- Name: course_reviews course_reviews_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY course_reviews_select_all ON public.course_reviews FOR SELECT USING (true);


--
-- Name: course_reviews course_reviews_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY course_reviews_update_own ON public.course_reviews FOR UPDATE USING ((student_id = auth.uid()));


--
-- Name: courses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

--
-- Name: device_tokens; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: device_tokens device_tokens_delete_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY device_tokens_delete_own ON public.device_tokens FOR DELETE USING ((user_id = auth.uid()));


--
-- Name: device_tokens device_tokens_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY device_tokens_insert_own ON public.device_tokens FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: device_tokens device_tokens_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY device_tokens_select_own ON public.device_tokens FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: device_tokens device_tokens_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY device_tokens_update_own ON public.device_tokens FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: exam_submissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exam_submissions ENABLE ROW LEVEL SECURITY;

--
-- Name: exams; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: lesson_progress; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

--
-- Name: lessons; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications notifications_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY notifications_select_own ON public.notifications FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: notifications notifications_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY notifications_update_own ON public.notifications FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: payment_methods; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;

--
-- Name: payment_methods payment_methods_delete_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY payment_methods_delete_own ON public.payment_methods FOR DELETE USING ((student_id = auth.uid()));


--
-- Name: payment_methods payment_methods_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY payment_methods_insert_own ON public.payment_methods FOR INSERT WITH CHECK ((student_id = auth.uid()));


--
-- Name: payment_methods payment_methods_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY payment_methods_select_own ON public.payment_methods FOR SELECT USING ((student_id = auth.uid()));


--
-- Name: payment_methods payment_methods_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY payment_methods_update_own ON public.payment_methods FOR UPDATE USING ((student_id = auth.uid()));


--
-- Name: payments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- Name: subscription_plans plans_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY plans_select_all ON public.subscription_plans FOR SELECT USING (true);


--
-- Name: teachers public_select_approved_teachers; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY public_select_approved_teachers ON public.teachers FOR SELECT USING ((approval_status = 'approved'::public.approval_status));


--
-- Name: lessons public_select_lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY public_select_lessons ON public.lessons FOR SELECT USING ((is_free_preview = true));


--
-- Name: courses public_select_published_courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY public_select_published_courses ON public.courses FOR SELECT USING ((is_published = true));


--
-- Name: activation_codes public_select_unused_codes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY public_select_unused_codes ON public.activation_codes FOR SELECT USING ((is_used = false));


--
-- Name: questions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;

--
-- Name: students; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

--
-- Name: students students_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_insert_own ON public.students FOR INSERT WITH CHECK ((id = auth.uid()));


--
-- Name: subscriptions students_insert_own_subscriptions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_insert_own_subscriptions ON public.subscriptions FOR INSERT WITH CHECK ((student_id = auth.uid()));


--
-- Name: lesson_progress students_manage_own_progress; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_manage_own_progress ON public.lesson_progress USING ((student_id = auth.uid()));


--
-- Name: exam_submissions students_manage_own_submissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_manage_own_submissions ON public.exam_submissions USING ((student_id = auth.uid()));


--
-- Name: lessons students_select_lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_select_lessons ON public.lessons FOR SELECT TO authenticated USING (true);


--
-- Name: students students_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_select_own ON public.students FOR SELECT USING ((id = auth.uid()));


--
-- Name: exams students_select_published_exams; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_select_published_exams ON public.exams FOR SELECT TO authenticated USING ((is_published = true));


--
-- Name: questions students_select_questions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_select_questions ON public.questions FOR SELECT TO authenticated USING ((exam_id IN ( SELECT exams.id
   FROM public.exams
  WHERE (exams.is_published = true))));


--
-- Name: students students_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_update_own ON public.students FOR UPDATE USING ((id = auth.uid()));


--
-- Name: subscriptions students_update_own_subscriptions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_update_own_subscriptions ON public.subscriptions FOR UPDATE USING ((student_id = auth.uid()));


--
-- Name: subscriptions students_view_own_subscriptions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY students_view_own_subscriptions ON public.subscriptions FOR SELECT USING ((student_id = auth.uid()));


--
-- Name: subjects; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;

--
-- Name: subjects subjects_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY subjects_select_all ON public.subjects FOR SELECT USING (true);


--
-- Name: subscription_plans; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;

--
-- Name: subscriptions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

--
-- Name: teachers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;

--
-- Name: teachers teachers_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_insert_own ON public.teachers FOR INSERT WITH CHECK ((id = auth.uid()));


--
-- Name: activation_codes teachers_manage_own_codes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_manage_own_codes ON public.activation_codes USING ((teacher_id = auth.uid()));


--
-- Name: courses teachers_manage_own_courses; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_manage_own_courses ON public.courses USING ((teacher_id = auth.uid()));


--
-- Name: exams teachers_manage_own_exams; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_manage_own_exams ON public.exams USING ((teacher_id = auth.uid()));


--
-- Name: lessons teachers_manage_own_lessons; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_manage_own_lessons ON public.lessons USING ((course_id IN ( SELECT courses.id
   FROM public.courses
  WHERE (courses.teacher_id = auth.uid()))));


--
-- Name: questions teachers_manage_own_questions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_manage_own_questions ON public.questions USING ((exam_id IN ( SELECT exams.id
   FROM public.exams
  WHERE (exams.teacher_id = auth.uid()))));


--
-- Name: teachers teachers_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_select_own ON public.teachers FOR SELECT USING ((id = auth.uid()));


--
-- Name: users teachers_select_subscribed_students; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_select_subscribed_students ON public.users FOR SELECT USING ((id IN ( SELECT subscriptions.student_id
   FROM public.subscriptions
  WHERE (subscriptions.teacher_id = auth.uid()))));


--
-- Name: teachers teachers_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_update_own ON public.teachers FOR UPDATE USING ((id = auth.uid()));


--
-- Name: subscriptions teachers_view_own_subscriptions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_view_own_subscriptions ON public.subscriptions FOR SELECT USING ((teacher_id = auth.uid()));


--
-- Name: exam_submissions teachers_view_submissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY teachers_view_submissions ON public.exam_submissions FOR SELECT USING ((exam_id IN ( SELECT exams.id
   FROM public.exams
  WHERE (exams.teacher_id = auth.uid()))));


--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_insert_own ON public.users FOR INSERT WITH CHECK ((id = auth.uid()));


--
-- Name: payments users_insert_own_payments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_insert_own_payments ON public.payments FOR INSERT WITH CHECK ((payer_id = auth.uid()));


--
-- Name: users users_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_select_own ON public.users FOR SELECT USING ((id = auth.uid()));


--
-- Name: users users_select_teacher_profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_select_teacher_profiles ON public.users FOR SELECT TO authenticated, anon USING ((id IN ( SELECT teachers.id
   FROM public.teachers
  WHERE (teachers.approval_status = 'approved'::public.approval_status))));


--
-- Name: users users_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_update_own ON public.users FOR UPDATE USING ((id = auth.uid()));


--
-- Name: payments users_view_own_payments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_view_own_payments ON public.payments FOR SELECT USING ((payer_id = auth.uid()));


--
-- PostgreSQL database dump complete
--

\unrestrict z2S8u9GwAugc6ZSriL3cRU1bRPTzbd2Rns5VaXObncMdCDLEjR02LxU5QQ1HbzW

