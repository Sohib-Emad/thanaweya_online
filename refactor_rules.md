# تعليمات الريفاكتور (Refactor Guidelines)

## القواعد الأساسية اللي طلبتها

1. **حد أقصى 150 سطر لكل ملف** داخل أي فيتشر (Feature). لو أي ملف عدى 150 سطر، لازم يتقسم لملفات أصغر.
2. **كل ويدجت في الشاشة تتفصل في ملف لوحدها**. يعني مفيش `Widget` مكتوب جوه ملف الشاشة نفسه (لا كـ method زي `_buildHeader()` ولا كـ class داخلي)، كل ويدجت له ملف مستقل باسمه.

---

## قواعد إضافية مقترحة (زودتها عشان الريفاكتور يبقى منظم فعلاً)

### 1. هيكلة الفولدرات لكل فيتشر
```
lib/features/feature_name/
├── presentation/
│   ├── screens/
│   │   └── feature_screen.dart
│   ├── widgets/
│   │   ├── feature_header.dart
│   │   ├── feature_card.dart
│   │   └── ...
│   ├── controllers/ (أو cubit/bloc/provider)
│   └── state/
├── domain/
│   ├── entities/
│   └── usecases/
└── data/
    ├── models/
    └── repositories/
```

### 2. تسمية الملفات والكلاسات
- اسم الملف = `snake_case`، اسم الكلاس = `PascalCase`، ولازم يتطابقوا منطقيًا (مثلاً `product_card.dart` → `class ProductCard`).
- كل ملف يحتوي **كلاس واحد رئيسي بس** (Single Responsibility).
- ممنوع أكتر من `class` عام واحد في نفس الملف إلا لو ملف صغير جدًا لموديلات مرتبطة ببعض بشكل وثيق.

### 3. فصل المنطق عن الشكل (UI vs Logic)
- ممنوع أي `API call` أو `business logic` جوه الـ Widget مباشرة. لازم تكون في Controller/Cubit/Bloc/Provider.
- الـ Widget يستقبل الداتا جاهزة (State) ويعرضها بس.

### 4. الـ Barrel Files
- كل فولدر `widgets/` يبقى له ملف `widgets.dart` بيعمل export لكل الويدجتس اللي جواه، عشان الاستيراد يبقى نضيف:
  ```dart
  export 'feature_header.dart';
  export 'feature_card.dart';
  ```

### 5. الحد من التداخل (Nesting)
- ممنوع أي `build()` method يتعدى مستوى تداخل (nesting) معين (مثلاً أكتر من 4-5 مستويات) — لو حصل كده، ده إشارة إن الجزء ده لازم يبقى Widget مستقل.

### 6. الثوابت والقيم الجاهزة
- ممنوع "Magic Numbers" أو "Magic Strings" جوه الويدجتس. كل القيم (padding, sizes, durations, texts) تتحط في ملفات `constants/` أو `app_theme.dart`.
- الألوان والخطوط تُستخدم من `Theme.of(context)` مش Hardcoded.

### 7. إعادة استخدام الكود (Reusability)
- أي جزء UI اتكرر في أكتر من مكان (زرار، كارت، تكست فيلد) يتحول لـ Shared/Common Widget في فولدر `core/widgets/` مش يتكرر في كل فيتشر.

### 8. التعليقات والتوثيق
- كل ويدجت أو كلاس عام لازم يكون فوقه `///` doc comment قصير يشرح وظيفته.

### 9. الاستيرادات (Imports)
- ترتيب الاستيرادات: Dart/Flutter core → Packages خارجية → ملفات المشروع (Relative).
- ممنوع Unused imports.

### 10. الاختبارات
- كل ويدجت جديدة (خصوصًا اللي فيها Logic بسيط زي conditions) يفضل يكون ليها Widget Test في `test/features/feature_name/`.

### 11. حجم الفنكشنز (Methods)
- أي method (مش بس ملفات) تتعدى 30-40 سطر تتراجع وتتقسم لـ methods أصغر بأسماء واضحة.

### 12. الـ Immutability
- استخدام `const` constructors لأي Widget مفيهاش state متغير، لتحسين الأداء.

---

## خطوات تنفيذ الريفاكتور (مقترحة)
1. اعمل جرد (Inventory) لكل الملفات اللي عدت 150 سطر.
2. حدد كل الويدجتس المدمجة جوه الشاشات (سواء كـ private methods أو classes).
3. افصل كل ويدجت في ملف مستقل مع الحفاظ على نفس الـ props والـ behavior.
4. تأكد إن كل فيتشر بقى متبع نفس هيكلة الفولدرات (presentation/domain/data).
5. شغل الـ Analyzer (`flutter analyze`) بعد كل تعديل للتأكد إن مفيش أخطاء.
6. اعمل Test للتأكد إن الـ UI شغال زي قبل الريفاكتور بالظبط.
