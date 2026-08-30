import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

/// Full-screen high-performance camera scanner to scan printed voucher QR codes.
/// Uses fixed full-screen viewport to prevent Android surface-resize camera drops.
class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({super.key});

  /// Opens the scanner as a dedicated full-screen page for maximum camera stability.
  static Future<String?> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerSheet(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _hasScanned = false;
  bool _isFlashOn = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.resumeCamera();

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

  Future<void> _refocus() async {
    HapticFeedback.selectionClick();
    await _controller?.pauseCamera();
    await _controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final scanSize = 250.r;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Native Camera Preview (Full Screen)
          GestureDetector(
            onTap: _refocus,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              formatsAllowed: const [
                BarcodeFormat.qrcode,
                BarcodeFormat.code128,
                BarcodeFormat.code39,
              ],
            ),
          ),

          // 2. Dark Vignette / Overlay outside cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(180),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: scanSize,
                      height: scanSize,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Viewfinder Reticle with glowing corners
          Center(
            child: SizedBox(
              width: scanSize,
              height: scanSize,
              child: Stack(
                children: [
                  // Animated Scanning Laser Line
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Positioned(
                        top: _animController.value * (scanSize - 20),
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF38BDF8),
                                Color(0xFF0284C7),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withAlpha(180),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Corner Accents
                  _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                  _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                  _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                  _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),
                ],
              ),
            ),
          ),

          // 4. Top App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'مسح كود كارت الشحن',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isFlashOn ? const Color(0xFFFBBF24) : Colors.white,
                  ),
                  onPressed: _toggleFlash,
                ),
              ],
            ),
          ),

          // 5. Bottom Instructions & Manual Entry Button
          Positioned(
            bottom: 40.h,
            left: 24.w,
            right: 24.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withAlpha(220),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 8.w),
                      Text(
                        'ضع كود الـ QR داخل الإطار للمسح الفوري',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.keyboard_rounded, color: Colors.white70, size: 18),
                  label: Text(
                    'كتابة الكود يدوياً',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black.withAlpha(120),
                    side: const BorderSide(color: Color(0xFF475569), width: 1.2),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Color(0xFF38BDF8), width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Color(0xFF38BDF8), width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Color(0xFF38BDF8), width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Color(0xFF38BDF8), width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? Radius.circular(20.r) : Radius.zero,
            topRight: isTop && !isLeft ? Radius.circular(20.r) : Radius.zero,
            bottomLeft: !isTop && isLeft ? Radius.circular(20.r) : Radius.zero,
            bottomRight: !isTop && !isLeft ? Radius.circular(20.r) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
