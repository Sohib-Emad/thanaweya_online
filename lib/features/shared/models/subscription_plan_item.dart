import 'package:flutter/material.dart';

class SubscriptionPlanItem {
  final String id;
  final String name;
  final String billingPeriod;
  final double price;
  final String? originalPrice;
  final String? badge;
  final List<String> features;
  final bool isActive;
  final int displayOrder;

  const SubscriptionPlanItem({
    required this.id,
    required this.name,
    required this.billingPeriod,
    required this.price,
    this.originalPrice,
    this.badge,
    required this.features,
    this.isActive = true,
    this.displayOrder = 0,
  });

  String get formattedPrice => '${price.toInt()} ج.م';

  String get periodLabel => switch (billingPeriod) {
        'monthly' => '/ شهرياً',
        'term' => '/ للترم (5 أشهر)',
        'yearly' => '/ سنوياً (12 شهر)',
        _ => '/ $billingPeriod',
      };

  IconData get icon => switch (billingPeriod) {
        'monthly' => Icons.calendar_month_outlined,
        'term' => Icons.school_outlined,
        'yearly' => Icons.workspace_premium_outlined,
        _ => Icons.card_membership_outlined,
      };

  factory SubscriptionPlanItem.fromMap(Map<String, dynamic> map, int index) {
    final period = map['billing_period'] as String? ?? 'monthly';
    final price = (map['price'] is num)
        ? (map['price'] as num).toDouble()
        : (double.tryParse(map['price']?.toString() ?? '') ?? 1000.0);

    List<String> feats = [];
    if (map['features'] is List) {
      feats = (map['features'] as List).map((e) => e.toString()).toList();
    } else {
      if (period == 'yearly') {
        feats = const [
          'خصم شهرين كاملين (ادفع 10 شهور فقط واحصل على سنة كاملة)',
          'عدد غير محدود من الطلاب والكورسات والدروس',
          'امتحانات إلكترونية وبنوك أسئلة متكاملة',
          'إشعارات وتقارير أولياء الأمور عبر الواتساب',
          'كروت وتفعيل غير محدود مع توثيق مميز للمدرس',
          'أولوية مطلقة ودعم VIP على مدار الساعة',
        ];
      } else if (period == 'term') {
        feats = const [
          'عدد غير محدود من الكورسات والدروس للترم',
          'حتى 500 طالب مشترك',
          'امتحانات واختبارات وبنوك أسئلة غير محدودة',
          'تقارير أولياء الأمور عبر الواتساب',
          'تحليلات وإحصائيات متقدمة للأداء',
          'دعم فني مخصص وسريع',
        ];
      } else {
        feats = const [
          'كورس دراسي ومتابعة دورية',
          'حتى 100 طالب مشترك',
          'اختبارات إلكترونية ومتابعة الواجبات',
          'التقارير والإحصائيات الأساسية',
          'دعم فني خلال أوقات العمل',
        ];
      }
    }

    String? originalPrice;
    String? badge;
    if (period == 'yearly') {
      originalPrice = '${(price * 1.2).toInt()} ج.م';
      badge = 'وفر شهرين 🎁';
    } else if (period == 'term') {
      badge = 'الأكثر طلباً';
    }

    return SubscriptionPlanItem(
      id: map['id']?.toString() ?? '$index',
      name: map['name'] as String? ??
          (period == 'yearly'
              ? 'الباقة السنوية الشاملة'
              : (period == 'term' ? 'باقة الترم الدراسي' : 'الباقة الشهرية')),
      billingPeriod: period,
      price: price,
      originalPrice: originalPrice,
      badge: badge,
      features: feats,
      isActive: map['is_active'] == true,
      displayOrder: map['display_order'] as int? ?? index,
    );
  }

  static List<SubscriptionPlanItem> get defaultPlans => const [
        SubscriptionPlanItem(
          id: 'monthly',
          name: 'الباقة الشهرية',
          billingPeriod: 'monthly',
          price: 1000.0,
          features: [
            'كورس دراسي ومتابعة دورية',
            'حتى 100 طالب مشترك',
            'اختبارات إلكترونية ومتابعة الواجبات',
            'التقارير والإحصائيات الأساسية',
            'دعم فني خلال أوقات العمل',
          ],
          displayOrder: 1,
        ),
        SubscriptionPlanItem(
          id: 'term',
          name: 'باقة الترم الدراسي',
          billingPeriod: 'term',
          price: 5000.0,
          badge: 'الأكثر طلباً',
          features: [
            'عدد غير محدود من الكورسات والدروس للترم',
            'حتى 500 طالب مشترك',
            'امتحانات واختبارات وبنوك أسئلة غير محدودة',
            'تقارير أولياء الأمور عبر الواتساب',
            'تحليلات وإحصائيات متقدمة للأداء',
            'دعم فني مخصص وسريع',
          ],
          displayOrder: 2,
        ),
        SubscriptionPlanItem(
          id: 'yearly',
          name: 'الباقة السنوية الشاملة',
          billingPeriod: 'yearly',
          price: 10000.0,
          originalPrice: '12,000 ج.م',
          badge: 'وفر شهرين 🎁',
          features: [
            'خصم شهرين كاملين (ادفع 10 شهور فقط واحصل على سنة كاملة)',
            'عدد غير محدود من الطلاب والكورسات والدروس',
            'امتحانات إلكترونية وبنوك أسئلة متكاملة',
            'إشعارات وتقارير أولياء الأمور عبر الواتساب',
            'كروت وتفعيل غير محدود مع توثيق مميز للمدرس',
            'أولوية مطلقة ودعم VIP على مدار الساعة',
          ],
          displayOrder: 3,
        ),
      ];
}
