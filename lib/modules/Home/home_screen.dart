import 'package:flutter/material.dart';

import '../../core/styles/themeScaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(child: Text('HOME')),
    );
  }
}
