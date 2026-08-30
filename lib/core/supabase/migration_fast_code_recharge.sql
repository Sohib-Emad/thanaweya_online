-- ==============================================================================
-- Migration: High Performance Atomic Wallet Recharge by Code (Fix PGRST203)
-- ==============================================================================

-- 1. الفهارس لتسريع البحث الفوري عن الأكواد حتى لو أزال الطالب الشُرط (-) أو المسافات
CREATE INDEX IF NOT EXISTS idx_activation_codes_clean_upper 
  ON public.activation_codes ((upper(replace(replace(code, '-', ''), ' ', ''))));

CREATE INDEX IF NOT EXISTS idx_activation_codes_is_used 
  ON public.activation_codes (is_used);

CREATE INDEX IF NOT EXISTS idx_students_id_balance 
  ON public.students (id, wallet_balance);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_user_id 
  ON public.wallet_transactions (user_id, created_at DESC);

-- 2. إزالة أي دوال قديمة متعارضة لمنع خطأ PostgREST 203 (Multiple Choices)
DROP FUNCTION IF EXISTS public.recharge_wallet_with_card(UUID, VARCHAR);
DROP FUNCTION IF EXISTS public.recharge_wallet_with_card(UUID, CHARACTER VARYING);
DROP FUNCTION IF EXISTS public.recharge_wallet_with_card(UUID, TEXT);
DROP FUNCTION IF EXISTS public.recharge_wallet_with_card;
DROP FUNCTION IF EXISTS public.redeem_code_atomic(UUID, TEXT);
DROP FUNCTION IF EXISTS public.redeem_code_atomic;

-- 3. دالة الشحن الفوري الرئيسية فائقة السرعة
CREATE OR REPLACE FUNCTION public.redeem_code_atomic(
  p_student_id UUID,
  p_card_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_clean TEXT;
  v_raw TEXT;
  v_code_id UUID;
  v_code_val NUMERIC(10, 2) := 0.0;
  v_is_used BOOLEAN := false;
  v_course_id UUID;
  v_teacher_id UUID;
  v_actual_code TEXT;
  v_old_bal NUMERIC(10, 2) := 0.0;
  v_new_bal NUMERIC(10, 2) := 0.0;
  v_course_title TEXT := '';
BEGIN
  v_raw := trim(p_card_code);
  -- إزالة المسافات والشرطات وتوحيد الحروف الكبيرة للبحث الفوري
  v_clean := upper(replace(replace(v_raw, '-', ''), ' ', ''));

  IF v_clean = '' THEN
    RETURN jsonb_build_object('success', false, 'error', 'يرجى إدخال كود الكارت أولاً');
  END IF;

  -- أولاً: البحث في جدول أكواد التفعيل activation_codes مع قفل الصف فوراً لمنع التكرار
  SELECT 
    ac.id, ac.code, ac.is_used, COALESCE(ac.price, 0.0), ac.course_id, ac.teacher_id,
    COALESCE(c.title, '')
  INTO 
    v_code_id, v_actual_code, v_is_used, v_code_val, v_course_id, v_teacher_id,
    v_course_title
  FROM public.activation_codes ac
  LEFT JOIN public.courses c ON c.id = ac.course_id
  WHERE upper(replace(replace(ac.code, '-', ''), ' ', '')) = v_clean
     OR ac.code = v_raw
  ORDER BY ac.created_at DESC
  LIMIT 1
  FOR UPDATE OF ac;

  -- ثانياً: إذا لم يوجد في activation_codes، البحث في recharge_cards كبديل
  IF v_code_id IS NULL THEN
    SELECT 
      rc.id, rc.code, rc.is_used, COALESCE(rc.value, 100.0), NULL, NULL, ''
    INTO 
      v_code_id, v_actual_code, v_is_used, v_code_val, v_course_id, v_teacher_id,
      v_course_title
    FROM public.recharge_cards rc
    WHERE upper(replace(replace(rc.code, '-', ''), ' ', '')) = v_clean
       OR rc.code = v_raw
    LIMIT 1
    FOR UPDATE OF rc;
    
    IF v_code_id IS NOT NULL THEN
      IF v_is_used THEN
        RETURN jsonb_build_object('success', false, 'error', 'تم استخدام هذا الكارت مسبقاً');
      END IF;
      
      UPDATE public.recharge_cards
      SET is_used = true, used_by = p_student_id, used_at = now()
      WHERE id = v_code_id;
    END IF;
  ELSE
    -- كود من activation_codes
    IF v_is_used THEN
      RETURN jsonb_build_object('success', false, 'error', 'تم استخدام هذا الكود مسبقاً');
    END IF;

    -- إذا كان السعر 0، يتم أخذ سعر الكورس كافتراضي
    IF v_code_val <= 0 AND v_course_id IS NOT NULL THEN
      SELECT COALESCE(price, 100.0) INTO v_code_val FROM public.courses WHERE id = v_course_id;
    END IF;
    IF v_code_val <= 0 THEN
      v_code_val := 100.0;
    END IF;

    -- تحديث كود التفعيل كمستخدم فوراً
    UPDATE public.activation_codes
    SET is_used = true, used_by = p_student_id, used_at = now()
    WHERE id = v_code_id;

    -- تفعيل اشتراك الكورس إن وُجد
    IF v_course_id IS NOT NULL THEN
      INSERT INTO public.subscriptions (
        student_id, teacher_id, course_id, status, starts_at, expires_at
      ) VALUES (
        p_student_id, v_teacher_id, v_course_id, 'active', now(), now() + interval '365 days'
      )
      ON CONFLICT (student_id, course_id)
      DO UPDATE SET status = 'active', starts_at = now(), expires_at = now() + interval '365 days';
    END IF;
  END IF;

  -- إذا لم يتم العثور على الكود إطلاقاً
  IF v_code_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'كود الكارت غير صحيح أو غير مسجل بالنظام');
  END IF;

  -- ثالثاً: تحديث رصيد الخزنة في جدول students بشكل ذري وفوري
  SELECT COALESCE(wallet_balance, 0.0) INTO v_old_bal
  FROM public.students WHERE id = p_student_id FOR UPDATE;

  v_new_bal := v_old_bal + v_code_val;

  UPDATE public.students
  SET wallet_balance = v_new_bal
  WHERE id = p_student_id;

  IF NOT FOUND THEN
    INSERT INTO public.students (id, grade_level, wallet_balance)
    VALUES (p_student_id, '1', v_new_bal);
  END IF;

  -- رابعاً: تسجيل حركة إيداع في سجل الخزنة
  INSERT INTO public.wallet_transactions (
    user_id, title, subtitle, amount, type, status, reference_id, created_at
  ) VALUES (
    p_student_id, 'شحن رصيد بكارت', 'كود: ' || v_actual_code, v_code_val, 'credit', 'completed', v_code_id::text, now()
  );

  -- إرجاع النتيجة الفورية
  RETURN jsonb_build_object(
    'success', true,
    'amount', v_code_val,
    'new_balance', v_new_bal,
    'code', v_actual_code,
    'course_title', v_course_title
  );
END;
$$;

-- أيضاً إنشاء recharge_wallet_with_card لربطها بنفس الدالة
CREATE OR REPLACE FUNCTION public.recharge_wallet_with_card(
  p_student_id UUID,
  p_card_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN public.redeem_code_atomic(p_student_id, p_card_code);
END;
$$;

-- منح الصلاحيات
GRANT EXECUTE ON FUNCTION public.redeem_code_atomic(UUID, TEXT) TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION public.recharge_wallet_with_card(UUID, TEXT) TO authenticated, anon, service_role;
