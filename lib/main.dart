import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:thanaweya_online/core/services/connectivity_service.dart';
import 'package:thanaweya_online/features/shared/ui/no_internet_screen.dart';

import 'features/student/data/repos/exam_sync_service.dart';
import 'core/firebase/push_notification_service.dart';
import 'core/l10n/locale_controller.dart';
import 'l10n/l10n.dart';
import 'features/auth/data/repos/auth_repo.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'core/router/app_router.dart';
import 'core/router/route_observer.dart';
import 'core/supabase/secure_local_storage.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Crashlytics only)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Catch Flutter framework errors
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Catch errors outside the Flutter framework (e.g. async errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Don't send crash reports while developing locally
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with credentials from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );

  // Firebase Cloud Messaging: permissions, token registration, foreground
  // display and tap handling.
  await PushNotificationService.instance.initialize();

  // Background exam submission sync when internet reconnects
  ExamSyncService.init();

  // Global network connectivity listener
  ConnectivityService.instance.initialize();

  // Restore the saved app language (defaults to Arabic)
  await LocaleController.instance.load();

  // Enable edge-to-edge mode for Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
          child: BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepo: AuthRepo()),
            child: ListenableBuilder(
              listenable: LocaleController.instance,
              builder: (context, _) {
                return MaterialApp(
                  title: 'ثانوية أونلاين',
                  debugShowCheckedModeBanner: false,
                  navigatorKey: PushNotificationService.instance.navigatorKey,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeMode.light,
                  locale: LocaleController.instance.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  initialRoute: AppRouter.splash,
                  onGenerateRoute: AppRouter.onGenerateRoute,
                  navigatorObservers: [appRouteObserver],
                  builder: (context, child) {
                    return ValueListenableBuilder<bool>(
                      valueListenable:
                          ConnectivityService.instance.isConnectedNotifier,
                      builder: (context, isConnected, _) {
                        return Stack(
                          children: [
                            ?child,
                            if (!isConnected)
                              const Positioned.fill(child: NoInternetScreen()),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
