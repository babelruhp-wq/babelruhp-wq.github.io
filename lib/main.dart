import 'package:babel_final_project/core/constants/constants.dart';
import 'package:babel_final_project/screens/home_screen/home_screen.dart';
import 'package:babel_final_project/screens/login_screen/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/auth/auth_service.dart';
import 'core/auth/token_storage.dart';
import 'core/lang/app_language.dart';
import 'core/scroll/custom_scroll_behavior.dart';

// ✅ NEW
import 'core/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      minimumSize: Size(1100, 700),
      center: true,
      title: 'Babel App',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguage()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(baseUrl: mainUrl),
            storage: TokenStorage(),
          )..restoreSession(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguage>(
      builder: (context, lang, _) {
        return MaterialApp(
          locale: lang.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          scrollBehavior: CustomScrollBehavior(),
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isLoggedIn) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
