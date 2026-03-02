import 'package:flutter/material.dart';
import 'package:vaxguide/core/constants/strings.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        navHistory,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'Alexandria',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
