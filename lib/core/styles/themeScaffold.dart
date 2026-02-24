import 'package:flutter/material.dart';

import 'colors.dart';

// Default background image (used as fallback)
const String _kDefaultBackgroundImage = 'assets/images/bg.png';

class ThemedScaffold extends StatelessWidget {
  final Widget? body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final String backgroundImagePath;

  const ThemedScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonAnimator,
    this.floatingActionButtonLocation,
    this.drawer,
    this.backgroundImagePath = _kDefaultBackgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Background Image
        Positioned.fill(
          child: Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to default background if image fails to load
              return Image.asset(
                _kDefaultBackgroundImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // If even the default fails, show a colored background
                  return Container(color: fischerBlue900);
                },
              );
            },
          ),
        ),

        // 2. The Actual Scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar as PreferredSizeWidget?,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonAnimator: floatingActionButtonAnimator,
          floatingActionButtonLocation: floatingActionButtonLocation,
          drawer: drawer,
        ),
      ],
    );
  }
}
