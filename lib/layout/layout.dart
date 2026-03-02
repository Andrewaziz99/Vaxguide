import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';
import 'package:vaxguide/modules/History/history_screen.dart';
import 'package:vaxguide/modules/Home/drawer.dart';
import 'package:vaxguide/modules/Home/home_screen.dart';
import 'package:vaxguide/modules/VaccineSearch/vaccine_search_screen.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 1; // Home is in the center
  late final PageController _pageController;

  final List<Widget> _screens = const [
    HistoryScreen(),
    HomeScreen(),
    VaccineSearchScreen(),
  ];

  final List<String> _titles = const [navHistory, appName, navVaccineSearch];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundImagePath: 'assets/images/bg2.png',
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(),
      body: PageView(
        reverse: true,
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.ltr,
        child: CircleNavBar(
          activeIndex: _currentIndex,
          onTap: _onTabChanged,
          activeIcons: const [
            Icon(Icons.history_rounded, color: fischerBlue900, size: 28),
            Icon(Icons.home_rounded, color: fischerBlue900, size: 28),
            Icon(Icons.vaccines_rounded, color: fischerBlue900, size: 28),
          ],
          inactiveIcons: const [
            Text(
              navHistory,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Alexandria',
              ),
            ),
            Text(
              navHome,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Alexandria',
              ),
            ),
            Text(
              navVaccineSearch,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Alexandria',
              ),
            ),
          ],
          height: 70,
          circleWidth: 55,
          color: fischerBlue900,
          circleColor: fischerBlue100,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          elevation: 10,
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
          cornerRadius: const BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }
}
