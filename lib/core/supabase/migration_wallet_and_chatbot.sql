-- ==============================================================================
-- ميزتا: خزنة الطالب (المحفظة) والمساعد الذكي (الشات بوت)
-- Migration: Wallet, Recharge Cards, and Transactions
-- ==============================================================================

-- 1. إضافة عمود رصيد الخزنة لجدول الطلاب إن لم يكن موجوداً
ALTER TABLE students ADD COLUMN IF NOT EXISTS wallet_balance NUMERIC(10, 2) DEFAULT 0.00;

-- 2. جدول كروت الشحن مسبقة الدفع (Recharge Cards)
CREATE TABLE IF NOT EXISTS recharge_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,             -- كود الكارت بعد التطهير (مثلاً: RSLN-8492-9102)
    value NUMERIC(10, 2) NOT NULL,                -- قيمة الرصيد بالجنيه (مثلاً: 100.00)
    is_used BOOLEAN DEFAULT FALSE,                -- هل تم استخدامه؟
    used_by UUID REFERENCES students(id) ON DELETE SET NULL, -- الطالب الذي شحن الكارت
    used_at TIMESTAMP WITH TIME ZONE,             -- تاريخ وتوقيت الشحن
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE           -- تاريخ انتهاء الصلاحية
);

-- فهرس لتسريع البحث عن كود الكارت
CREATE INDEX IF NOT EXISTS idx_recharge_cards_code ON recharge_cards(code);
CREATE INDEX IF NOT EXISTS idx_recharge_cards_is_used ON recharge_cards(is_used);

-- 3. جدول حركات الخزنة (Wallet Transactions)
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES students(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,                  -- عنوان الحركة (مثال: شحن كارت سنتر / شراء كورس)
    subtitle VARCHAR(255),                        -- تفاصيل إضافية (مثال: كود الكارت أو اسم الكورس)
    amount NUMERIC(10, 2) NOT NULL,               -- المبلغ
    type VARCHAR(20) NOT NULL CHECK (type IN ('credit', 'debit')), -- إيداع (credit) أو خصم (debit)
    status VARCHAR(20) DEFAULT 'completed',       -- completed / pending / failed
    reference_id VARCHAR(100),                    -- معرف الكورس أو كود الكارت
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- فهرس لتسريع استعراض حركات الطالب مرتبة زمنياً
CREATE INDEX IF NOT EXISTS idx_wallet_tx_user_id ON wallet_transactions(user_id, created_at DESC);

-- تفعيل RLS للجداول الجديدة
ALTER TABLE recharge_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;

-- سياسات RLS لكروت الشحن:
-- القراءة والتحقق من الكارت لجميع المستخدمين المسجلين
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'recharge_cards' AND policyname = 'recharge_cards_select') THEN
        CREATE POLICY recharge_cards_select ON recharge_cards FOR SELECT TO authenticated USING (true);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'recharge_cards' AND policyname = 'recharge_cards_update') THEN
        CREATE POLICY recharge_cards_update ON recharge_cards FOR UPDATE TO authenticated USING (true);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'recharge_cards' AND policyname = 'recharge_cards_insert') THEN
        CREATE POLICY recharge_cards_insert ON recharge_cards FOR INSERT TO authenticated WITH CHECK (true);
    END IF;
END $$;

-- سياسات RLS لحركات الخزنة:
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'wallet_transactions' AND policyname = 'wallet_tx_select_own') THEN
        CREATE POLICY wallet_tx_select_own ON wallet_transactions FOR SELECT TO authenticated USING (user_id = auth.uid());
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'wallet_transactions' AND policyname = 'wallet_tx_insert_own') THEN
        CREATE POLICY wallet_tx_insert_own ON wallet_transactions FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
    END IF;

    -- السماح للطلاب بتحديث حالة أكواد التفعيل غير المستخدمة عند الشحن
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'activation_codes' AND policyname = 'students_redeem_activation_codes') THEN
        CREATE POLICY students_redeem_activation_codes ON public.activation_codes FOR UPDATE TO authenticated USING (is_used = false) WITH CHECK (is_used = true);
    END IF;
END $$;

-- دالة شحن الكارت الذرية (Postgres Function / RPC) لمنع التضارب
CREATE OR REPLACE FUNCTION recharge_wallet_with_card(
    p_student_id UUID,
    p_card_code VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_card_id UUID;
    v_card_code VARCHAR;
    v_is_used BOOLEAN := FALSE;
    v_expires_at TIMESTAMPTZ;
    v_card_value NUMERIC(10, 2) := 100.00;
    v_course_id UUID;
    v_teacher_id UUID;
    v_current_balance NUMERIC(10, 2);
    v_clean_code VARCHAR;
    v_is_activation BOOLEAN := FALSE;
    v_found BOOLEAN := FALSE;
BEGIN
    -- تنظيف الكود من الفواصل والمسافات وتحويله لأحرف كبيرة
    v_clean_code := UPPER(REPLACE(REPLACE(p_card_code, '-', ''), ' ', ''));

    -- 1. البحث في جدول كروت الشحن recharge_cards
    SELECT id, code, value, is_used, expires_at
    INTO v_card_id, v_card_code, v_card_value, v_is_used, v_expires_at
    FROM recharge_cards
    WHERE UPPER(REPLACE(REPLACE(code, '-', ''), ' ', '')) = v_clean_code
    FOR UPDATE;

    IF FOUND THEN
        v_found := TRUE;
    ELSE
        -- 2. إذا لم يوجد، البحث في جدول أكواد التفعيل activation_codes
        SELECT id, code, is_used, course_id, teacher_id
        INTO v_card_id, v_card_code, v_is_used, v_course_id, v_teacher_id
        FROM activation_codes
        WHERE UPPER(REPLACE(REPLACE(code, '-', ''), ' ', '')) = v_clean_code
        FOR UPDATE;

        IF FOUND THEN
            v_found := TRUE;
            v_is_activation := TRUE;
            v_expires_at := NULL;
            
            -- جلب سعر الكورس إذا كان الكود مرتبطاً بكورس
            IF v_course_id IS NOT NULL THEN
                SELECT COALESCE(price, 100.00) INTO v_card_value
                FROM courses
                WHERE id = v_course_id;
            ELSE
                v_card_value := 100.00;
            END IF;
        END IF;
    END IF;

    IF NOT v_found THEN
        RETURN jsonb_build_object('success', false, 'error', 'كود الكارت غير صحيح أو غير مسجل بالنظام');
    END IF;

    IF v_is_used THEN
        RETURN jsonb_build_object('success', false, 'error', 'تم استخدام هذا الكود مسبقاً');
    END IF;

    IF v_expires_at IS NOT NULL AND v_expires_at < NOW() THEN
        RETURN jsonb_build_object('success', false, 'error', 'انتهت صلاحية هذا الكارت');
    END IF;

    -- 3. تحديث حالة الكود
    IF v_is_activation THEN
        UPDATE activation_codes
        SET is_used = TRUE,
            used_by = p_student_id,
            used_at = NOW()
        WHERE id = v_card_id;

        -- تفعيل الكورس للطالب إذا كان الكود خاصاً بكورس
        IF v_course_id IS NOT NULL THEN
            INSERT INTO subscriptions (
                student_id,
                teacher_id,
                course_id,
                status,
                starts_at,
                expires_at
            ) VALUES (
                p_student_id,
                v_teacher_id,
                v_course_id,
                'active',
                NOW(),
                NOW() + INTERVAL '1 year'
            )
            ON CONFLICT (student_id, course_id) DO UPDATE
            SET status = 'active',
                expires_at = NOW() + INTERVAL '1 year';
        END IF;
    ELSE
        UPDATE recharge_cards
        SET is_used = TRUE,
            used_by = p_student_id,
            used_at = NOW()
        WHERE id = v_card_id;
    END IF;

    -- 4. تحديث رصيد الطالب في students
    UPDATE students
    SET wallet_balance = COALESCE(wallet_balance, 0) + v_card_value
    WHERE id = p_student_id
    RETURNING wallet_balance INTO v_current_balance;

    -- في حال لم يكن الطالب مسجلاً بعد في جدول students نقوم بإدراجه
    IF NOT FOUND THEN
        INSERT INTO students (id, wallet_balance)
        VALUES (p_student_id, v_card_value)
        RETURNING wallet_balance INTO v_current_balance;
    END IF;

    -- 5. تسجيل حركة الخزنة
    INSERT INTO wallet_transactions (
        user_id,
        title,
        subtitle,
        amount,
        type,
        status,
        reference_id
    ) VALUES (
        p_student_id,
        'شحن رصيد بكارت سنتر',
        'كود: ' || v_card_code,
        v_card_value,
        'credit',
        'completed',
        v_card_id::TEXT
    );

    RETURN jsonb_build_object(
        'success', true,
        'amount', v_card_value,
        'new_balance', v_current_balance,
        'message', 'تم شحن ' || v_card_value || ' ج.م إلى خزنتك بنجاح'
    );
END;
$$;

-- إدراج كروت شحن تجريبية جاهزة للاستخدام
INSERT INTO recharge_cards (code, value) VALUES
    ('CARD-100-TEST', 100.00),
    ('CARD-50-TEST', 50.00),
    ('CARD-200-TEST', 200.00),
    ('TH-WALLET-100', 100.00)
ON CONFLICT (code) DO NOTHING;
