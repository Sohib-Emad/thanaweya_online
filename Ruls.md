# قواعد تنفيذ الميزات (Feature Implementation Rules)

> هذا الملف يحدد القواعد والإرشادات الإلزامية لتنفيذ أي ميزة في منصة ثانوية أونلاين.
> يجب مراجعة هذه القواعد قبل البدء في تنفيذ أي مهمة.

---

## 1. قواعد البنية (Architecture Rules)

### 1.1 هيكل المشروع

```
lib/
├── main.dart                           # نقطة الدخول
├── core/                               # البنية التحتية المشتركة
│   ├── auth/                           # المصادقة
│   ├── constants/                      # الثوابت (الألوان، النصوص، الخطوط)
│   ├── network/                        # الشبكة ومعالجة الأخطاء
│   ├── router/                         # المسارات
│   ├── supabase/                       # Supabase (schema, SQL, client)
│   ├── theme/                          # الثيم (فاتح/داكن)
│   ├── l10n/                           # التوطين (العربية)
│   └── utils/                          # أدوات مساعدة
├── features/                           # الميزات
│   ├── auth/                           # المصادقة
│   ├── splash/                         # شاشة البداية
│   ├── onboarding/                     # الترحيب
│   ├── teacher/                        # المعلم
│   │   ├── data/repos/                 # مستودعات البيانات
│   │   ├── logic/                      # منطق الأعمال (Cubits)
│   │   └── ui/                         # واجهات المستخدم
│   ├── student/                        # الطالب
│   │   ├── data/repos/
│   │   ├── logic/
│   │   └── ui/
│   ├── admin/                          # المدير
│   │   ├── data/repos/
│   │   ├── logic/
│   │   └── ui/
│   └── shared/                         # مشترك
│       ├── models/                     # نماذج البيانات
│       ├── widgets/                    # ويدجت قابلة لإعادة الاستخدام
│       └── ui/                         # شاشات مشتركة
├── theme/                              # الثيم
└── l10n/                               # التوطين
```

### 1.2 نمط العمارة: Feature-First + Repository Pattern

- **UI Layer**: شاشات Flutter + Widgets (لا تحتوي على منطق أعمال)
- **Logic Layer**: Cubits (منطق الأعمال وإدارة الحالة)
- **Data Layer**: Repos (التواصل مع Supabase API)
- **Model Layer**: Freezed models (نماذج بيانات غير قابلة للتغيير)

### 1.3 تدفق البيانات

```
Screen ←→ Cubit ←→ Repo ←→ Supabase Client
   ↓                        ↓
  Widgets                API Results
```

- الـ Screen يرسل الأحداث إلى Cubit
- الـ Cubit يستدعي Repo
- الـ Repo يتواصل مع Supabase
- الـ Repo يُرجع `ApiResult<T>` (نجاح أو فشل)
- الـ Cubit يُحدّث الحالة
- الـ Screen يعيد بناء نفسه بناءً على الحالة الجديدة

### 1.4 إدارة الحالة: Bloc/Cubit

- استخدام `flutter_bloc` مع Cubit لكل ميزة
- كل Cubit له State منفصل
- الحالات: `initial`, `loading`, `success`, `error`

```dart
class StudentsCubit extends Cubit<StudentsState> {
  final TeacherStudentsRepo repo;
  
  Future<void> loadStudents() async {
    emit(state.copyWith(status: StudentsStatus.loading));
    final result = await repo.getStudents(teacherId);
    result.when(
      success: (data) => emit(state.copyWith(
        status: StudentsStatus.success,
        students: data,
      )),
      failure: (msg, _) => emit(state.copyWith(
        status: StudentsStatus.error,
        errorMessage: msg,
      )),
    );
  }
}
```

---

## 2. قواعد Supabase (Database Rules)

### 2.1 تهيئة الاتصال

- استدعاء `Supabase.initialize()` في `main.dart` قبل `runApp()`
- استخدام `flutter_dotenv` لقراءة `SUPABASE_URL` و `SUPABASE_ANON_KEY`
- كائن المساعد: `SupabaseClientHelper` للوصول السريع

### 2.2 مخطط قاعدة البيانات

يتم تعريف الجداول في `lib/core/supabase/schema.sql` ويتم تشغيلها في محرر SQL الخاص بـ Supabase.

الجداول الرئيسية:
- `users` - المستخدمون (يمتد `auth.users`)
- `teachers` - المعلمون
- `students` - الطلاب
- `subjects` - المواد الدراسية
- `courses` - الدورات
- `lessons` - الدروس
- `exams` - الامتحانات
- `questions` - الأسئلة
- `subscriptions` - الاشتراكات
- `activation_codes` - أكواد التفعيل
- `lesson_progress` - تقدم الدروس
- `exam_submissions` - إجابات الامتحانات
- `comments` - التعليقات
- `subscription_plans` - باقات الاشتراك
- `payments` - المدفوعات

### 2.3 سياسات RLS (Row Level Security)

- استخدام JWT metadata (`auth.jwt()->'user_metadata'->>'role'`) للتحقق من الدور
- تجنب الاستعلامات المتداخلة (subqueries) في سياسات Admin لمنع التكرار اللانهائي
- لكل جدول: سياسات للقراءة والكتابة حسب الدور

### 2.4 المفتاح بعد تشغيل SQL

بعد إنشاء حساب Supabase جديد، قم بتشغيل:
```
lib/core/supabase/fix_complete.sql
```
في محرر SQL الخاص بـ Supabase (وليس `schema.sql` لأنه قد يسبب أخطاء تكرار).

---

## 3. قواعد الترميز (Coding Standards)

### 3.1 التسمية

- **الملفات**: `snake_case` (مثال: `teacher_form_screen.dart`)
- **الدوال**: `camelCase` (مثال: `loadStudents()`)
- **الثوابت**: `UpperCamelCase` أو `snake_case` حسب السياق
- **الألوان**: `UpperCamelCase` (مثال: `AppColors.studentPrimary`)
- **النصوص**: `camelCase` (مثال: `AppStrings.studentRegistration`)

### 3.2 المسارات

- تعريف جميع المسارات كثوابت ثابتة في `AppRouter`
- استخدام `onGenerateRoute` مع `PageRouteBuilder` للانتقالات السلسة

### 3.3 معالجة الأخطاء

- استخدام `ApiResult` لتوحيد التعامل مع النجاح والفشل
- استخدام `ApiErrorHandler` لتحويل أخطاء Supabase إلى رسائل عربية
- تسجيل الأخطاء باستخدام `debugPrint()` أثناء التطوير

```dart
return result.when(
  success: (data) => ApiResult.success(data),
  failure: (message, _) => ApiResult.failure(message),
);
```

### 3.4 الثيم

- استخدام `AppColors` لجميع الألوان (لا ألوان حرفية في الشاشات)
- استخدام `AppTextStyles` أو `GoogleFonts.cairo()` للنصوص العربية
- استخدام `EdgeInsetsDirectional` بدلاً من `EdgeInsets` لدعم RTL
- يجب أن تدعم جميع الشاشات الوضع الفاتح والداكن

---

## 4. قواعد اللغة (Localization Rules)

### 4.1 اللغة الأساسية: العربية (RTL)

- اللغة الافتراضية للتطبيق هي العربية (RTL)
- جميع النصوص في `AppStrings` بالعربية
- استخدام `Localizations` لدعم لغات إضافية مستقبلاً

### 4.2 النصوص

- لا تكتب نصوصاً حرفية مباشرة في الشاشات
- استخدم `AppStrings.xxx` للنصوص الثابتة
- استخدم `AppLocalizations.of(context).xxx` للنصوص الديناميكية

---

## 5. قواعد التنفيذ (Implementation Process)

### 5.1 استخدام Speckit

- استخدام speckit لإدارة الميزات:
  - `/speckit.specify` - لإنشاء مواصفات الميزة
  - `/speckit.plan` - لإنشاء خطة التنفيذ
  - `/speckit.tasks` - لإنشاء قائمة المهام
  - `/speckit.implement` - لتنفيذ المهام

### 5.2 هيكل الميزة

كل ميزة يتم تعريفها في `specs/NNN-feature-name/`:
```
specs/NNN-feature-name/
├── spec.md          # مواصفات الميزة
├── plan.md          # خطة التنفيذ
├── tasks.md         # قائمة المهام
├── research.md      # البحث التقني
├── data-model.md    # نموذج البيانات
├── quickstart.md    # دليل البدء السريع
├── contracts/       # العقود (اختياري)
└── checklists/      # قوائم التحقق
    └── requirements.md
```

### 5.3 ترتيب التنفيذ

1. **Setup**: البنية التحتية (الألوان، الثيم، Supabase)
2. **Foundational**: المصادقة، المسارات، النماذج المشتركة
3. **MVP**: تدفق المعلم (التسجيل ← الموافقة ← إنشاء الدورات)
4. **Student**: تدفق الطالب (الاشتراك ← مشاهدة الدروس)
5. **Exams**: نظام الامتحانات
6. **Management**: إدارة الطلاب وأكواد التفعيل
7. **Admin**: لوحة تحكم المدير
8. **Polish**: التحسينات النهائية

### 5.4 Git Workflow

- الفرع الرئيسي: `main`
- فروع الميزات: `NNN-feature-name`
- يتم إنشاء فرع لكل ميزة باستخدام speckit

---

## 6. قواعد الأمان (Security Rules)

### 6.1 المصادقة

- استخدام Supabase Auth للمصادقة
- تخزين الأدوار في `user_metadata` لتجنب الاستعلامات المتكررة
- استخدام JWT للتحقق من الهوية في سياسات RLS

### 6.2 حماية المحتوى

- استخدام Supabase RLS لمنع الوصول غير المصرح به
- استخدام `is_free_preview` للدروس المجانية
- استخدام `subscriptions` للوصول إلى المحتوى المدفوع
- استخدام أكواد التفعيل للتحكم في الاشتراكات

### 6.3 المتغيرات البيئية

- عدم تخزين المفاتيح السرية في الكود المصدري
- استخدام `.env` للمفاتيح (مضاف إلى `.gitignore`)
- استخدام `.env.example` كقالب للمفاتيح المطلوبة

---

## 7. قواعد التصميم (UI/UX Rules)

### 7.1 RTL (من اليمين إلى اليسار)

- جميع الشاشات تدعم الاتجاه RTL
- استخدام `EdgeInsetsDirectional` و `AlignmentDirectional`
- استخدام `Start` و `End` بدلاً من `Left` و `Right`

### 7.2 التجاوب

- استخدام `flutter_screenutil` للتكيف مع أحجام الشاشات المختلفة
- استخدام `.w` و `.h` و `.sp` للأبعاد والخطوط
- دعم وضعي portrait و landscape

### 7.3 الحالات

- كل شاشة تدعم: `loading` (شاشة تحميل)، `empty` (لا توجد بيانات)، `error` (خطأ)، `data` (عرض البيانات)
- استخدام `Skeleton` للتحميل، `OfflineScreen` لانقطاع الإنترنت

### 7.4 الخط العربي

- استخدام خط `Cairo` من Google Fonts
- دعم التشكيل والحركات العربية

---

## 8. قواعد الاختبار (Testing Rules)

- كتابة اختبارات الوحدة للـ Cubits والـ Repos
- استخدام `flutter_test` للاختبارات
- اختبار التدفقات الرئيسية لكل ميزة قبل اعتبارها مكتملة
- اختبار معالجة الأخطاء وحالات الحافة

---

*آخر تحديث: 2026-07-26*
