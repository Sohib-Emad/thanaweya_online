import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// PDF generator tailored for printing activation voucher cards on standard A4 paper.
/// Uses deterministic row-by-row layout (8 cards per page: 2 columns x 4 rows)
/// to guarantee zero row clipping and full visibility on all printers.
class AdminPdfCardsGenerator {
  AdminPdfCardsGenerator._();

  /// Number of cards per A4 sheet (2 columns x 4 rows)
  static const int cardsPerPage = 8;
  static const int columnsCount = 2;
  static const int rowsPerPage = 4;

  /// Prints a single card formatted on A4.
  static Future<void> printSingleCard({
    required Map<String, dynamic> card,
  }) async {
    await printCards(cards: [card], docTitle: 'كارت شحن - ${card['code'] ?? ''}');
  }

  /// Generates the raw pw.Document containing all cards laid out deterministically.
  static Future<pw.Document> generatePdfDocument({
    required List<Map<String, dynamic>> cards,
    String docTitle = 'كروت شحن ثانوية أونلاين',
    bool tenCardsPerPage = false,
  }) async {
    final doc = pw.Document(title: docTitle, author: 'منصة ثانوية أونلاين');

    // Load Arabic fonts via printing package
    final fontRegular = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final int perPage = tenCardsPerPage ? 10 : 8;
    final int rowsCount = tenCardsPerPage ? 5 : 4;
    final double cardHeight = tenCardsPerPage ? 138.0 : 172.0;
    final double rowSpacing = tenCardsPerPage ? 8.0 : 10.0;

    for (int i = 0; i < cards.length; i += perPage) {
      final pageCards = cards.skip(i).take(perPage).toList();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(
            base: fontRegular,
            bold: fontBold,
            fontFallback: [fontRegular, fontBold],
          ),
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                for (int r = 0; r < rowsCount; r++) ...[
                  () {
                    final firstIndex = r * 2;
                    final secondIndex = firstIndex + 1;

                    final hasFirst = firstIndex < pageCards.length;
                    final hasSecond = secondIndex < pageCards.length;

                    if (!hasFirst) return pw.SizedBox();

                    final firstCard = pageCards[firstIndex];
                    final secondCard = hasSecond ? pageCards[secondIndex] : null;

                    return pw.Container(
                      height: cardHeight,
                      margin: pw.EdgeInsets.only(bottom: r < rowsCount - 1 ? rowSpacing : 0),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Expanded(
                            child: _buildCardWidget(firstCard, fontBold, fontRegular, isCompact: tenCardsPerPage),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: secondCard != null
                                ? _buildCardWidget(secondCard, fontBold, fontRegular, isCompact: tenCardsPerPage)
                                : pw.Opacity(
                                    opacity: 0.0,
                                    child: _buildCardWidget(firstCard, fontBold, fontRegular, isCompact: tenCardsPerPage),
                                  ),
                          ),
                        ],
                      ),
                    );
                  }(),
                ],
              ],
            );
          },
        ),
      );
    }

    return doc;
  }

  /// Prints multiple cards laid out in a clean 2-column grid on standard A4 sheets.
  static Future<void> printCards({
    required List<Map<String, dynamic>> cards,
    String docTitle = 'كروت شحن ثانوية أونلاين',
    bool tenCardsPerPage = false,
  }) async {
    if (cards.isEmpty) return;

    try {
      final doc = await generatePdfDocument(
        cards: cards,
        docTitle: docTitle,
        tenCardsPerPage: tenCardsPerPage,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: '${docTitle.replaceAll(' ', '_')}.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      debugPrint('[AdminPdfCardsGenerator] printCards error: $e');
      rethrow;
    }
  }

  static pw.Widget _buildCardWidget(
    Map<String, dynamic> card,
    pw.Font fontBold,
    pw.Font fontRegular, {
    bool isCompact = false,
  }) {
    final code = card['code'] as String? ?? '';
    final teacher = card['teachers'] as Map<String, dynamic>? ?? {};
    final teacherUsers = teacher['users'] as Map<String, dynamic>? ?? {};
    final teacherName = teacherUsers['full_name'] as String? ?? 'معلم المنصة';
    final subject = (teacher['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '';
    final course = card['courses'] as Map<String, dynamic>? ?? {};
    final courseTitle = course['title'] as String? ?? 'كود شحن رصيد واشتراك عام';

    final price = (card['price'] as num?)?.toDouble() ??
        ((course['price'] as num?)?.toDouble() ?? 0.0);

    final double qrSize = isCompact ? 46.0 : 56.0;
    final double pad = isCompact ? 6.0 : 8.0;

    pw.TextStyle boldStyle(double size, {PdfColor? color, double? letterSpacing}) {
      return pw.TextStyle(
        font: fontBold,
        fontFallback: [fontRegular],
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
      );
    }

    pw.TextStyle regStyle(double size, {PdfColor? color}) {
      return pw.TextStyle(
        font: fontRegular,
        fontFallback: [fontBold],
        fontSize: size,
        color: color,
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.indigo900, width: 1.2),
      ),
      padding: pw.EdgeInsets.all(pad),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // 1. Header (Brand name + Price badge)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'منصة ثانوية أونلاين',
                    style: boldStyle(isCompact ? 10.0 : 11.0, color: PdfColors.indigo900),
                  ),
                  pw.Text(
                    'كارت تفعيل وشحن معتمد',
                    style: regStyle(isCompact ? 6.5 : 7.2, color: PdfColors.grey700),
                  ),
                ],
              ),
              // Price Badge
              pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: isCompact ? 5 : 7, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: price > 0 ? PdfColors.amber100 : PdfColors.blueGrey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(
                    color: price > 0 ? PdfColors.amber800 : PdfColors.blueGrey500,
                    width: 1,
                  ),
                ),
                child: pw.Text(
                  price > 0 ? '${price.toStringAsFixed(0)} ج.م' : 'كود عام',
                  style: boldStyle(isCompact ? 8.5 : 9.5, color: price > 0 ? PdfColors.amber900 : PdfColors.blueGrey900),
                ),
              ),
            ],
          ),

          pw.Divider(color: PdfColors.grey300, thickness: 0.6, height: isCompact ? 4 : 6),

          // 2. Middle Row: QR Code + Details + Code
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // QR Code
              pw.Container(
                padding: const pw.EdgeInsets.all(2.5),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: code,
                      width: qrSize,
                      height: qrSize,
                      color: PdfColors.black,
                      drawText: false,
                    ),
                    pw.SizedBox(height: 1.5),
                    pw.Text(
                      'امسح بالهاتف',
                      style: boldStyle(5.5, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(width: 7),

              // Details & Prominent Code
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      subject.isNotEmpty ? 'المعلم: $teacherName ($subject)' : 'المعلم: $teacherName',
                      style: boldStyle(isCompact ? 7.8 : 8.8, color: PdfColors.black),
                      maxLines: 1,
                    ),
                    pw.SizedBox(height: 1.5),
                    pw.Text(
                      'الكورس: $courseTitle',
                      style: regStyle(isCompact ? 7.0 : 7.8, color: PdfColors.grey800),
                      maxLines: 1,
                    ),
                    pw.SizedBox(height: isCompact ? 3.5 : 4.5),

                    // Monospace Code Container
                    pw.Container(
                      width: double.infinity,
                      padding: pw.EdgeInsets.symmetric(vertical: isCompact ? 2.5 : 3.5, horizontal: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        border: pw.Border.all(color: PdfColors.indigo700, width: 0.8),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          code,
                          style: boldStyle(
                            isCompact ? 9.5 : 10.8,
                            color: PdfColors.indigo900,
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

          // 3. Footer: Instructions & Support
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'طريقة الشحن: التطبيق > الخزنة > شحن بالكود',
                  style: regStyle(5.8, color: PdfColors.grey800),
                ),
                pw.Text(
                  'الدعم: 01096462825',
                  style: boldStyle(5.8, color: PdfColors.indigo900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
