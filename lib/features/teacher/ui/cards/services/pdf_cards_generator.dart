import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// PDF Generator that arranges multiple printable voucher cards on A4 sheets for printing.
class PdfCardsGenerator {
  PdfCardsGenerator._();

  static Future<void> printSingleCard({
    required String code,
    required String courseTitle,
    required String teacherName,
  }) async {
    final pdf = await _generateDocument(
      cards: [
        {
          'code': code,
          'courseTitle': courseTitle,
          'teacherName': teacherName,
        }
      ],
      docTitle: 'كارت شحن - $code',
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'كارت_شحن_$code.pdf',
    );
  }

  static Future<void> printAllCards({
    required List<Map<String, dynamic>> cards,
    required String defaultTeacherName,
  }) async {
    final formattedCards = cards.map((c) {
      final code = c['code'] as String? ?? '';
      final courseMap = c['courses'] as Map<String, dynamic>?;
      final courseTitle = courseMap?['title'] as String? ?? 'جميع كورسات المدرس';
      return <String, String>{
        'code': code,
        'courseTitle': courseTitle,
        'teacherName': defaultTeacherName,
      };
    }).toList();

    final pdf = await _generateDocument(
      cards: formattedCards,
      docTitle: 'كروت شحن منصة ثانوية أونلاين',
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'كروت_شحن_ثانوية_أونلاين.pdf',
    );
  }

  static Future<pw.Document> _generateDocument({
    required List<Map<String, String>> cards,
    required String docTitle,
  }) async {
    final doc = pw.Document(title: docTitle, author: 'منصة ثانوية أونلاين');

    // Load Arabic Font via printing package
    final fontRegular = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    // 8 cards per page (2 columns x 4 rows)
    const int cardsPerPage = 8;
    for (int i = 0; i < cards.length; i += cardsPerPage) {
      final chunk = cards.skip(i).take(cardsPerPage).toList();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(
            base: fontRegular,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return pw.GridView(
              crossAxisCount: 2,
              childAspectRatio: 1.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: chunk.map((card) {
                return _buildPdfCard(
                  code: card['code'] ?? '',
                  courseTitle: card['courseTitle'] ?? '',
                  teacherName: card['teacherName'] ?? 'المعلم',
                  fontBold: fontBold,
                  fontRegular: fontRegular,
                );
              }).toList(),
            );
          },
        ),
      );
    }

    return doc;
  }

  static pw.Widget _buildPdfCard({
    required String code,
    required String courseTitle,
    required String teacherName,
    required pw.Font fontBold,
    required pw.Font fontRegular,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.amber800, width: 1.5),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Header: Brand & Auth Badge
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'منصة ثانوية أونلاين',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 11,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    'كارت شحن واشتراك رسمي',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 7.5,
                      color: PdfColors.blue700,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.amber800),
                ),
                child: pw.Text(
                  'كارت أصلي',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 7.5,
                    color: PdfColors.amber900,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // Main Body: Info & QR Code
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // QR Code
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.amber700, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: code,
                      width: 50,
                      height: 50,
                      color: PdfColors.black,
                    ),
                    pw.Text(
                      'امسح بالكاميرا',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),

              // Teacher, Course, and Code
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'المعلم: $teacherName',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 9.5,
                        color: PdfColors.black,
                      ),
                      maxLines: 1,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'الكورس: $courseTitle',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 8.5,
                        color: PdfColors.grey800,
                      ),
                      maxLines: 1,
                    ),
                    pw.SizedBox(height: 5),

                    // Code Box
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        border: pw.Border.all(color: PdfColors.blue800, width: 1),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          code,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 11,
                            color: PdfColors.blue900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),

          // Footer: URL and Phone
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'thanaweya-online.com',
                  style: pw.TextStyle(font: fontBold, fontSize: 6.5, color: PdfColors.blue900),
                ),
                pw.Text(
                  'الدعم: 01096462825',
                  style: pw.TextStyle(font: fontBold, fontSize: 6.5, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
