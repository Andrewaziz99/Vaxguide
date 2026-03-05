import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundImagePath: 'assets/images/bg2.png',
      appBar: AppBar(
        title: const Text(
          drawerAbout,
          style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── App Logo & Name ──
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    fischerBlue300.withValues(alpha: 0.25),
                    fischerBlue500.withValues(alpha: 0.15),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: fischerBlue100.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.vaccines_rounded,
                size: 64,
                color: fischerBlue100,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              appName,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: fischerBlue500.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: fischerBlue300.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$aboutVersion $appVersion',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 12,
                  color: fischerBlue300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Brief Description ──
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.info_outline_rounded,
                    title: aboutWhatIs,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    aboutDescription,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Features List ──
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.star_rounded,
                    title: aboutFeatures,
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.search_rounded,
                    title: aboutFeatureSearch,
                    subtitle: aboutFeatureSearchDesc,
                  ),
                  _FeatureItem(
                    icon: Icons.history_rounded,
                    title: aboutFeatureHistory,
                    subtitle: aboutFeatureHistoryDesc,
                  ),
                  _FeatureItem(
                    icon: Icons.notifications_active_rounded,
                    title: aboutFeatureReminders,
                    subtitle: aboutFeatureRemindersDesc,
                  ),
                  _FeatureItem(
                    icon: Icons.campaign_rounded,
                    title: aboutFeatureAlerts,
                    subtitle: aboutFeatureAlertsDesc,
                  ),
                  _FeatureItem(
                    icon: Icons.article_rounded,
                    title: aboutFeatureArticles,
                    subtitle: aboutFeatureArticlesDesc,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Developer ──
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.person_rounded,
                    title: aboutDeveloper,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    aboutDeveloperName,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aboutDeveloperDesc,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer ──
            Text(
              aboutCopyright,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: fischerBlue100, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: fischerBlue100,
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: fischerBlue500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: fischerBlue300, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
