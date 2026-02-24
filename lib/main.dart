import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vaxguide/core/styles/theme.dart';
import 'package:vaxguide/modules/Auth/login_screen.dart';

import 'firebase_options.dart';

void main() async {
  runApp(const MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: LoginScreen(),
    );
  }
}
