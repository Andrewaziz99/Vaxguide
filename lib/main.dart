import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vaxguide/core/constants/auth_constants.dart';
import 'package:vaxguide/core/network/local/cache_helper.dart';
import 'package:vaxguide/core/network/notification_service.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/theme.dart';
import 'package:vaxguide/layout/layout.dart';
import 'package:vaxguide/modules/Auth/complete_profile_screen.dart';
import 'package:vaxguide/modules/Auth/login_screen.dart';
import 'package:vaxguide/modules/Splash/splash_screen.dart';
import 'package:vaxguide/shared/bloc_observer.dart';
import 'package:vaxguide/shared/web_utils/web_utils.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize push notifications (web uses a different flow; avoid blocking startup)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    try {
      await NotificationService.instance.init().timeout(
        const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Notification init skipped: $e');
    }
  }

  // Check if user is already logged in and session is still valid
  final bool isLoggedIn =
      CacheHelper.getData(key: AuthConstants.cacheKeyIsLoggedIn) ?? false;
  final String? sessionExpiry = CacheHelper.getData(
    key: AuthConstants.cacheKeySessionExpiry,
  );

  bool sessionValid = false;
  if (isLoggedIn && sessionExpiry != null) {
    try {
      final expiryDate = DateTime.parse(sessionExpiry);
      sessionValid = DateTime.now().isBefore(expiryDate);
    } catch (_) {
      sessionValid = false;
    }
  }

  Widget startScreen;
  if (isLoggedIn && sessionValid) {
    // Check if user still needs to complete profile
    final uid =
        CacheHelper.getData(key: AuthConstants.cacheKeyUserId) as String?;
    if (uid != null) {
      try {
        final userRepo = UserRepo();
        final user = await userRepo
            .getUserById(uid)
            .timeout(const Duration(seconds: 8));
        if (user != null && user.firstLogin) {
          final email =
              CacheHelper.getData(key: AuthConstants.cacheKeyEmail) ?? '';
          startScreen = CompleteProfileScreen(
            uid: uid,
            email: email,
            displayName: user.fullName,
          );
        } else {
          startScreen = const AppLayout();
        }
      } catch (_) {
        startScreen = const AppLayout();
      }
    } else {
      startScreen = const LoginScreen();
    }
  } else {
    startScreen = const LoginScreen();
  }

  runApp(MyApp(startScreen: SplashScreen(destinationScreen: startScreen)));

  // Remove the HTML loading screen on web after Flutter has started.
  if (kIsWeb) {
    removeWebLoadingScreen();
  }
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('ar')],
      title: 'VACCIGUIDE',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: startScreen,
    );
  }
}
