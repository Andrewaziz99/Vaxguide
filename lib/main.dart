import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vaxguide/core/constants/auth_constants.dart';
import 'package:vaxguide/core/network/local/cache_helper.dart';
import 'package:vaxguide/core/styles/theme.dart';
import 'package:vaxguide/modules/Auth/login_screen.dart';
import 'package:vaxguide/modules/Home/home_screen.dart';
import 'package:vaxguide/shared/bloc_observer.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  final Widget startScreen = (isLoggedIn && sessionValid)
      ? const HomeScreen()
      : const LoginScreen();

  runApp(MyApp(startScreen: startScreen));
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
      title: 'VaxGuide',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: startScreen,
    );
  }
}
