import 'package:flutter/material.dart';

import 'colors.dart';

// Default background image (used as fallback)
const String _kDefaultBackgroundImage = 'assets/images/bg1.png';

class ThemedScaffold extends StatelessWidget {
  final Widget? body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final String backgroundImagePath;
  final double backgroundOpacity;

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
    this.backgroundOpacity = 1.0,
  }) : assert(
         backgroundOpacity >= 0.0 && backgroundOpacity <= 1.0,
         'backgroundOpacity must be between 0.0 and 1.0',
       );

  @override
  Widget build(BuildContext context) {
    final clampedOpacity = backgroundOpacity.clamp(0.0, 1.0);

    return Stack(
      children: [
        // 1. Background Image
        Positioned.fill(
          child: Opacity(
            opacity: clampedOpacity,
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
