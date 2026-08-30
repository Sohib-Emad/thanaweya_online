import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/services/connectivity_service.dart';
import 'package:thanaweya_online/features/shared/ui/no_internet_screen.dart';

void main() {
  test('ConnectivityService singleton and initial notifier state', () {
    final service = ConnectivityService.instance;
    expect(service.isConnected, true);
  });

  testWidgets('NoInternetScreen renders properly with Arabic text and retry button', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: NoInternetScreen(),
        ),
      ),
    );

    expect(find.text('انقطع الاتصال بالشبكة 📡'), findsOneWidget);
    expect(find.text('لا يوجد اتصال بالإنترنت'), findsOneWidget);
    expect(find.text('إعادة المحاولة 🔄'), findsOneWidget);
  });
}
