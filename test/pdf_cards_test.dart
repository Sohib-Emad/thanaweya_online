import 'package:flutter_test/flutter_test.dart';
import 'package:thanaweya_online/features/admin/ui/codes/services/admin_pdf_cards_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminPdfCardsGenerator Tests', () {
    final sampleCards = List.generate(
      16,
      (i) => {
        'id': 'card-$i',
        'code': 'TH-TEST-00$i',
        'price': 150.0,
        'teachers': {
          'users': {'full_name': 'أ. أحمد حسام'},
          'subjects': {'name_ar': 'لغة عربية'},
        },
        'courses': {
          'title': 'كورس البلاغة والنحو الشامل للثانوية العامة',
          'price': 150.0,
        },
      },
    );

    test('generatePdfDocument with 8 cards/page generates exactly 2 pages for 16 cards', () async {
      final doc = await AdminPdfCardsGenerator.generatePdfDocument(
        cards: sampleCards,
        tenCardsPerPage: false,
      );

      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
      expect(doc.document.pdfPageList.pages.length, 2);
    });

    test('generatePdfDocument with 10 cards/page generates exactly 2 pages for 16 cards', () async {
      final doc = await AdminPdfCardsGenerator.generatePdfDocument(
        cards: sampleCards,
        tenCardsPerPage: true,
      );

      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
      expect(doc.document.pdfPageList.pages.length, 2);
    });

    test('Single card generation produces 1 page without errors', () async {
      final doc = await AdminPdfCardsGenerator.generatePdfDocument(
        cards: [sampleCards.first],
        tenCardsPerPage: false,
      );

      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
      expect(doc.document.pdfPageList.pages.length, 1);
    });
  });
}
