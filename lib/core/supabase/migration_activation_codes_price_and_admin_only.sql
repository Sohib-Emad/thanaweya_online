-- ==============================================================================
-- Migration: Add Price to Activation Codes & Restrict Generation to Super Admin
-- ==============================================================================

-- 1. إضافة عمود السعر إلى جدول أكواد التفعيل
ALTER TABLE IF EXISTS public.activation_codes
  ADD COLUMN IF NOT EXISTS price NUMERIC(10, 2) DEFAULT 0.0;

-- 2. تحديث RLS: إلغاء صلاحية توليد الأكواد من حساب المعلم، وحصرها بالأدمن فقط
DROP POLICY IF EXISTS "teachers_manage_own_codes" ON public.activation_codes;
DROP POLICY IF EXISTS "teachers_insert_codes" ON public.activation_codes;
DROP POLICY IF EXISTS "teachers_delete_codes" ON public.activation_codes;

-- السماح للمعلم فقط بقراءة الأكواد التابعة له كتقرير إذا لزم، دون إمكانية التوليد أو الحذف
CREATE POLICY "teachers_select_own_codes" ON public.activation_codes
  FOR SELECT
  TO authenticated
  USING (
    teacher_id IN (
      SELECT id FROM public.teachers WHERE id = auth.uid()
    )
  );

-- تمكين الأدمن من الإدارة الكاملة (إنشاء، تعديل، حذف، قراءة)
DROP POLICY IF EXISTS "admin_manage_activation_codes" ON public.activation_codes;
CREATE POLICY "admin_manage_activation_codes" ON public.activation_codes
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  );

-- فهرس لتسريع البحث عن الأكواد واستردادها
CREATE INDEX IF NOT EXISTS idx_activation_codes_code_unaccent ON public.activation_codes(code);
CREATE INDEX IF NOT EXISTS idx_activation_codes_price ON public.activation_codes(price);
