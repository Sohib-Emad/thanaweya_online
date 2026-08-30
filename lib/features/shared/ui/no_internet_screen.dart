import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:thanaweya_online/core/services/connectivity_service.dart';

/// Full-screen white UI displayed when device loses internet connection.
class NoInternetScreen extends StatefulWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({super.key, this.onRetry});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    if (_isChecking) return;
    HapticFeedback.mediumImpact();
    setState(() => _isChecking = true);

    final online = await ConnectivityService.instance.checkConnectivity();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (online) {
      widget.onRetry?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استعادة الاتصال بالإنترنت بنجاح ✅'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ما زال لا يوجد اتصال بالإنترنت، يرجى المحاولة بعد قليل ⚠️'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent bypassing when offline
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 32.h) > 0 ? (constraints.maxHeight - 32.h) : 0,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),

                          // 1. Lottie Animation
                          Center(
                            child: SizedBox(
                              width: 240.r,
                              height: 240.r,
                              child: Lottie.asset(
                                'assets/json/No Connection.json',
                                fit: BoxFit.contain,
                                repeat: true,
                              ),
                            ),
                          ),

                          SizedBox(height: 14.h),

                          // 2. Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: const Color(0xFFFECDD3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.wifi_off_rounded, size: 16.r, color: const Color(0xFFE11D48)),
                                SizedBox(width: 6.w),
                                Text(
                                  'لا يوجد اتصال بالإنترنت',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12.h),

                          Text(
                            'انقطع الاتصال بالشبكة 📡',
                            style: GoogleFonts.cairo(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            child: Text(
                              'يرجى التأكد من اتصالك بشبكة الواي فاي أو بيانات الهاتف المحمول للمتابعة والوصول للمحتوى الدراسي.',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                color: const Color(0xFF64748B),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const Spacer(),

                          SizedBox(height: 20.h),

                          // 3. Retry Button
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton.icon(
                              onPressed: _isChecking ? null : _handleRetry,
                              icon: _isChecking
                                  ? SizedBox(
                                      width: 18.r,
                                      height: 18.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                              label: Text(
                                _isChecking ? 'جاري فحص الاتصال...' : 'إعادة المحاولة 🔄',
                                style: GoogleFonts.cairo(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: Colors.black.withValues(alpha: 0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // 4. Auto-reconnect notice
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bolt_rounded, size: 16.r, color: const Color(0xFF16A34A)),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  'سيتم استئناف التطبيق تلقائياً فور عودة الاتصال',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF16A34A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
