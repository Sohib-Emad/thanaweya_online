import '../../domain/entities/faq_item_entity.dart';
import '../../domain/entities/chatbot_message_entity.dart';

abstract class ChatbotLocalDataSource {
  List<String> getCategories();
  List<FaqItemEntity> getQuestionsByCategory(String category);
  ChatbotMessageEntity answerQuestion(String question);
  ChatbotMessageEntity getWelcomeMessage();
}

class ChatbotLocalDataSourceImpl implements ChatbotLocalDataSource {
  static const String catWallet = '💳 المحفظة والشحن';
  static const String catCourses = '📚 الكورسات والدروس';
  static const String catExams = '📝 الامتحانات والواجبات';
  static const String catSettings = '⚙️ الحساب والتقنيات';

  final List<FaqItemEntity> _faqBank = [
    // 💳 المحفظة والشحن
    const FaqItemEntity(
      id: 'w1',
      category: catWallet,
      question: 'كيف أشحن رصيد الخزنة بكارت سنتر؟',
      answer: 'يمكنك شحن رصيدك بسهولة عن طريق شراء كارت الشحن من السنتر أو المكتبة المعتمدة، ثم فتح شاشة "خزنة الطالب" وإدخال كود الكارت المطبوع المكون من حروف وأرقام، أو لصقه، أو مسح رمز الـ QR مباشرة، وسيضاف الرصيد لحسابك فوراً.',
      actionLabel: 'فتح الخزنة الآن 💳',
      actionRoute: 'wallet',
      followUps: [
        'كيف أشتري كورس من رصيد الخزنة؟',
        'ماذا أفعل إذا ظهر كود غير صحيح أو مستخدم؟',
        'هل تنتهي صلاحية رصيد الخزنة؟',
      ],
    ),
    const FaqItemEntity(
      id: 'w2',
      category: catWallet,
      question: 'كيف أشتري كورس من رصيد الخزنة؟',
      answer: 'عند الدخول لصفحة أي كورس ترغب في الاشتراك به، اضغط على "اشترك الآن" واختر وسيلة "الدفع من رصيد الخزنة". إذا كان رصيدك كافياً سيتم خصم سعر الكورس وتفعيله فوراً دون انتظار أي موافقة يدوية.',
      actionLabel: 'تصفح الكورسات 📚',
      actionRoute: 'courses',
      followUps: [
        'كيف أشحن رصيد الخزنة بكارت سنتر؟',
        'أين أجد سجل العمليات والمصروفات؟',
      ],
    ),
    const FaqItemEntity(
      id: 'w3',
      category: catWallet,
      question: 'ماذا أفعل إذا ظهر كود غير صحيح أو مستخدم؟',
      answer: 'تأكد أولاً من كتابة الحروف الإنجليزية بالترتيب وبدون مسافات إضافية. إذا استمرت المشكلة وكنت قد اشتريت الكارت حديثاً، يرجى تصوير الكارت والتواصل مع الدعم الفني لمراجعته وتفعيله لك فوراً.',
      actionLabel: 'تواصل مع الدعم الفني 💬',
      actionRoute: 'support',
      followUps: [
        'كيف أشحن رصيد الخزنة بكارت سنتر؟',
      ],
    ),
    const FaqItemEntity(
      id: 'w4',
      category: catWallet,
      question: 'هل تنتهي صلاحية رصيد الخزنة؟',
      answer: 'لا، رصيدك المشحون في الخزنة يظل محفوظاً في حسابك طوال العام الدراسي ويمكنك استخدامه في أي وقت لشراء أي كورس أو مراجعة نهائية.',
      followUps: [
        'كيف أشحن رصيد الخزنة بكارت سنتر؟',
        'كيف أشتري كورس من رصيد الخزنة؟',
      ],
    ),
    const FaqItemEntity(
      id: 'w5',
      category: catWallet,
      question: 'أين أجد سجل العمليات والمصروفات؟',
      answer: 'في شاشة الخزنة أسفل بطاقة الرصيد ستجد "سجل العمليات المالية"، يوضح بالتفصيل كل عملية شحن أو خصم مع التاريخ والساعة ونوع الحركة بدقة.',
      actionLabel: 'عرض الخزنة 💳',
      actionRoute: 'wallet',
      followUps: [
        'كيف أشحن رصيد الخزنة بكارت سنتر؟',
      ],
    ),

    // 📚 الكورسات والدروس
    const FaqItemEntity(
      id: 'c1',
      category: catCourses,
      question: 'كيف أصل إلى الكورسات المشترك بها؟',
      answer: 'من خلال شريط التنقل السفلي في الصفحة الرئيسية، اضغط على تبويب "كورساتي"، ستجد كافة الكورسات المفعلة بحسابك ونسبة إنجازك في كل كورس.',
      actionLabel: 'الذهاب إلى كورساتي 🎓',
      actionRoute: 'courses',
      followUps: [
        'هل يمكن تحميل الفيديوهات بدون إنترنت؟',
        'كيف أطرح سؤالاً للمدرس في الدرس؟',
      ],
    ),
    const FaqItemEntity(
      id: 'c2',
      category: catCourses,
      question: 'هل يمكن تحميل الفيديوهات بدون إنترنت؟',
      answer: 'لحماية حقوق المدرسين والمحتوى الفكري، تتوفر الفيديوهات للمشاهدة المشفرة المباشرة داخل التطبيق، ويدعم مشغل الفيديو جودات متعددة لتقليل استهلاك باقة الإنترنت.',
      followUps: [
        'كيف أصل إلى الكورسات المشترك بها؟',
        'الفيديو لا يعمل بشكل سلس، ما الحل؟',
      ],
    ),
    const FaqItemEntity(
      id: 'c3',
      category: catCourses,
      question: 'كيف أطرح سؤالاً للمدرس في الدرس؟',
      answer: 'في صفحة تشغيل الدرس أسفل الفيديو، ستجد قسم "التعليقات والأسئلة"، يمكنك كتابة سؤالك وسيقوم المدرس أو فريق المساعدين بالرد عليك وإشعارك.',
      followUps: [
        'كيف أصل إلى الكورسات المشترك بها؟',
      ],
    ),
    const FaqItemEntity(
      id: 'c4',
      category: catCourses,
      question: 'كيف أحصل على شهادة إتمام الكورس؟',
      answer: 'بمجرد إكمال مشاهدة جميع الحصص بنسبة 100% واجتياز الاختبارات المقررة، يتم إصدار شهادة إتمام إلكترونية معتمدة تظهر في صفحة الكورس ويمكنك تحميلها أو مشاركتها.',
      followUps: [
        'كيف أصل إلى الكورسات المشترك بها؟',
      ],
    ),

    // 📝 الامتحانات والواجبات
    const FaqItemEntity(
      id: 'e1',
      category: catExams,
      question: 'كم عدد المحاولات المتاحة للاختبار؟',
      answer: 'يحدد المدرس عدد المحاولات لكل اختبار (عادة من 1 إلى 3 محاولات). يمكنك معرفة عدد المحاولات المتبقية لك في بطاقة الامتحان قبل البدء.',
      followUps: [
        'ماذا يحدث إذا انقطع الإنترنت أثناء الامتحان؟',
        'أين أجد درجاتي في الامتحانات السابقة؟',
      ],
    ),
    const FaqItemEntity(
      id: 'e2',
      category: catExams,
      question: 'ماذا يحدث إذا انقطع الإنترنت أثناء الامتحان؟',
      answer: 'يقوم النظام بحفظ إجاباتك تلقائياً لحظة بلحظة. إذا انقطع الاتصال، أعد فتح التطبيق واستأنف الامتحان خلال الوقت الزمني المتبقي ولن تضيع إجاباتك السابقة.',
      followUps: [
        'أين أجد درجاتي في الامتحانات السابقة؟',
        'تواصل مع الدعم الفني 💬',
      ],
    ),
    const FaqItemEntity(
      id: 'e3',
      category: catExams,
      question: 'أين أجد درجاتي في الامتحانات السابقة؟',
      answer: 'من تبويب "الامتحانات" في الشريط السفلي، يمكنك التبديل إلى "سجل الاختبارات" أو "تاريخ الدرجات" لمراجعة درجاتك السابقة والاطلاع على الإجابات النموذجية.',
      followUps: [
        'كم عدد المحاولات المتاحة للاختبار؟',
      ],
    ),

    // ⚙️ الحساب والتقنيات
    const FaqItemEntity(
      id: 's1',
      category: catSettings,
      question: 'نسيت كلمة المرور، كيف أسترجع حسابي؟',
      answer: 'من شاشة تسجيل الدخول اضغط على "نسيت كلمة المرور"، ثم أدخل رقم هاتفك المسجل لاستلام رمز التحقق وإعادة تعيين كلمة مرور جديدة، أو تواصل مع إدارة المنصة للمساعدة الفورية.',
      actionLabel: 'مساعدة الدعم الفني 💬',
      actionRoute: 'support',
      followUps: [
        'كيف أغير رقم هاتفي أو بياناتي الشخصية؟',
      ],
    ),
    const FaqItemEntity(
      id: 's2',
      category: catSettings,
      question: 'كيف أغير رقم هاتفي أو بياناتي الشخصية؟',
      answer: 'توجه إلى تبويب "حسابي" ثم اضغط على "تعديل الملف الشخصي". يمكنك هناك تحديث اسمك، المحافظة، والشعبة الدراسية.',
      followUps: [
        'نسيت كلمة المرور، كيف أسترجع حسابي؟',
      ],
    ),
    const FaqItemEntity(
      id: 's3',
      category: catSettings,
      question: 'الفيديو لا يعمل بشكل سلس، ما الحل؟',
      answer: 'تأكد من استقرار اتصال الإنترنت لديك. يمكنك أيضاً الضغط على أيقونة الترس داخل مشغل الفيديو واختيار جودة أقل (مثل 360p أو 480p) لتشغيل سلس بدون تقطيع.',
      followUps: [
        'هل يمكن تحميل الفيديوهات بدون إنترنت؟',
      ],
    ),
    const FaqItemEntity(
      id: 's4',
      category: catSettings,
      question: 'كيف أتحدث مع خدمة العملاء أو الدعم الفني؟',
      answer: 'فريق الدعم الفني لمنصة ثانوية أونلاين متاح لمساعدتك يومياً عبر تطبيق WhatsApp. اضغط على الزر أدناه لبدء المحادثة مباشرة.',
      actionLabel: 'محادثة الدعم عبر واتساب 💬',
      actionRoute: 'support',
      followUps: [
        'كيف أشحن رصيد الخزنة بكارت سنتر؟',
      ],
    ),
  ];

  @override
  List<String> getCategories() {
    return [catWallet, catCourses, catExams, catSettings];
  }

  @override
  List<FaqItemEntity> getQuestionsByCategory(String category) {
    return _faqBank.where((item) => item.category == category).toList();
  }

  @override
  ChatbotMessageEntity getWelcomeMessage() {
    return ChatbotMessageEntity(
      id: 'msg_welcome',
      text: 'مرحباً بك يا بطل في المساعد الذكي لمنصة ثانوية أونلاين! 👋\nأنا هنا لمساعدتك على مدار الساعة في أي استفسار يخص الخزنة، الكورسات، أو الامتحانات. اختر من الأسئلة المقترحة أدناه أو اكتب سؤالك مباشرة.',
      isUser: false,
      timestamp: DateTime.now(),
      followUpQuestions: const [
        'كيف أشحن رصيد الخزنة بكارت سنتر؟',
        'كيف أشتري كورس من رصيد الخزنة؟',
        'كيف أصل إلى الكورسات المشترك بها؟',
        'كيف أتحدث مع خدمة العملاء أو الدعم الفني؟',
      ],
    );
  }

  @override
  ChatbotMessageEntity answerQuestion(String question) {
    final cleanQ = question.trim().toLowerCase();

    // 1. تطابق دقيق
    for (final item in _faqBank) {
      if (item.question.trim().toLowerCase() == cleanQ) {
        return ChatbotMessageEntity(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          text: item.answer,
          isUser: false,
          timestamp: DateTime.now(),
          actionLabel: item.actionLabel,
          actionRoute: item.actionRoute,
          followUpQuestions: item.followUps,
        );
      }
    }

    // 2. تطابق بالكلمات المفتاحية
    for (final item in _faqBank) {
      final qKeywords = item.question.toLowerCase().split(' ');
      int matches = 0;
      for (final kw in qKeywords) {
        if (kw.length > 3 && cleanQ.contains(kw)) {
          matches++;
        }
      }
      if (matches >= 2) {
        return ChatbotMessageEntity(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          text: item.answer,
          isUser: false,
          timestamp: DateTime.now(),
          actionLabel: item.actionLabel,
          actionRoute: item.actionRoute,
          followUpQuestions: item.followUps,
        );
      }
    }

    // 3. مطابقة الكلمات الدلالية الخاصة (Intent keywords)
    if (cleanQ.contains('شحن') || cleanQ.contains('كارت') || cleanQ.contains('محفظ') || cleanQ.contains('خزن') || cleanQ.contains('فلوس') || cleanQ.contains('رصيد')) {
      final item = _faqBank.firstWhere((e) => e.id == 'w1');
      return ChatbotMessageEntity(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        text: 'بخصوص الشحن والخزنة:\n${item.answer}',
        isUser: false,
        timestamp: DateTime.now(),
        actionLabel: item.actionLabel,
        actionRoute: item.actionRoute,
        followUpQuestions: item.followUps,
      );
    }

    if (cleanQ.contains('دعم') || cleanQ.contains('مشكل') || cleanQ.contains('واتس') || cleanQ.contains('تواصل') || cleanQ.contains('خدمة')) {
      return ChatbotMessageEntity(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        text: 'يسعدنا مساعدتك دائماً! يمكنك التحدث مباشرة مع فريق الدعم الفني عبر واتساب وسيقومون بحل مشكلتك فوراً.',
        isUser: false,
        timestamp: DateTime.now(),
        actionLabel: 'تواصل عبر واتساب الآن 💬',
        actionRoute: 'support',
        followUpQuestions: [
          'كيف أشحن رصيد الخزنة بكارت سنتر؟',
          'كيف أصل إلى الكورسات المشترك بها؟',
        ],
      );
    }

    // رد افتراضي في حال لم يتم التعرف على السؤال
    return ChatbotMessageEntity(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      text: 'عذراً، لم أستطع العثور على إجابة دقيقة لسؤالك المحدد. هل تود اختيار أحد المواضيع المقترحة بالأسفل، أو التواصل مباشرة مع فريق الدعم الفني البشري؟',
      isUser: false,
      timestamp: DateTime.now(),
      actionLabel: 'تواصل مع الدعم الفني 💬',
      actionRoute: 'support',
      followUpQuestions: [
        'كيف أشحن رصيد الخزنة بكارت سنتر؟',
        'كيف أشتري كورس من رصيد الخزنة؟',
        'أين أجد درجاتي في الامتحانات السابقة؟',
      ],
    );
  }
}
