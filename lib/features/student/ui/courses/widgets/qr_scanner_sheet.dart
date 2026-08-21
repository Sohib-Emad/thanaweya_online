import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

/// Interactive camera bottom sheet to scan printed activation QR codes using native scanner.
class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({super.key});

  static Future<String?> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QrScannerSheet(),
    );
  }

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _hasScanned = false;
  bool _isFlashOn = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_hasScanned) return;
      final String? rawValue = scanData.code;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        _hasScanned = true;
        HapticFeedback.heavyImpact();

        // Extract code if it's formatted as URL or direct code
        String code = rawValue.trim();
        if (code.contains('code=')) {
          final uri = Uri.tryParse(code);
          if (uri != null && uri.queryParameters.containsKey('code')) {
            code = uri.queryParameters['code']!;
          }
        }

        if (mounted) {
          Navigator.of(context).pop(code.toUpperCase());
        }
      }
    });
  }

  Future<void> _toggleFlash() async {
    await _controller?.toggleFlash();
    final flashStatus = await _controller?.getFlashStatus();
    setState(() {
      _isFlashOn = flashStatus ?? !_isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 0.78.sh,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            // Handle Bar
            Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 14.h),

            // Top Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withAlpha(30),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF38BDF8),
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مسح كود QR من الكارت',
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'وجّه الكاميرا نحو كود الـ QR المطبوع على كارت الشحن',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Camera Viewfinder Box
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: const Color(0xFF38BDF8),
                    borderRadius: 16,
                    borderLength: 30,
                    borderWidth: 5,
                    cutOutSize: 220.r,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Controls (Torch Toggle)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: _isFlashOn ? const Color(0xFFFBBF24) : Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      _isFlashOn ? 'إطفاء الكشاف' : 'تشغيل الكشاف',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
