import 'package:flutter/material.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(child: Text('LOGIN')),
    );
  }
}
