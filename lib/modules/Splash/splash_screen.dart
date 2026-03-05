import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vaxguide/core/styles/colors.dart';

/// Splash screen with animated shield, rings, orbiting particles, and app branding.
/// After the animation completes it navigates to [destinationScreen].
class SplashScreen extends StatefulWidget {
  final Widget destinationScreen;

  const SplashScreen({super.key, required this.destinationScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _orbitsCtrl;
  late final AnimationController _shimmerCtrl;

  // Staggered entrance animations
  late final Animation<double> _bgFade;
  late final Animation<double> _ringScale1;
  late final Animation<double> _ringScale2;
  late final Animation<double> _ringScale3;
  late final Animation<double> _shieldScale;
  late final Animation<double> _shieldFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _dotsScale;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _orbitsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _bgFade = _curve(0.00, 0.25, Curves.easeOut);
    _ringScale1 = _curve(0.10, 0.45, Curves.elasticOut);
    _ringScale2 = _curve(0.20, 0.55, Curves.elasticOut);
    _ringScale3 = _curve(0.30, 0.65, Curves.elasticOut);
    _shieldScale = _curve(0.35, 0.70, Curves.elasticOut);
    _shieldFade = _curve(0.35, 0.60, Curves.easeOut);
    _titleSlide = _slideIn(0.55, 0.78);
    _titleFade = _curve(0.55, 0.75, Curves.easeOut);
    _subtitleSlide = _slideIn(0.65, 0.85);
    _subtitleFade = _curve(0.65, 0.82, Curves.easeOut);
    _taglineFade = _curve(0.75, 0.95, Curves.easeOut);
    _dotsScale = _curve(0.80, 1.00, Curves.elasticOut);

    _masterCtrl.forward();

    // Navigate after animation + a short pause
    Future.delayed(const Duration(milliseconds: 5000), _navigate);
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.destinationScreen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Animation<double> _curve(double begin, double end, Curve curve) =>
      CurvedAnimation(
        parent: _masterCtrl,
        curve: Interval(begin, end, curve: curve),
      );

  Animation<Offset> _slideIn(double begin, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _masterCtrl,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ),
      );

  @override
  void dispose() {
    _masterCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitsCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _masterCtrl,
          _pulseCtrl,
          _orbitsCtrl,
          _shimmerCtrl,
        ]),
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fischerBlue900, fischerBlue700, fischerBlue500],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Mesh background blobs
                Opacity(
                  opacity: _bgFade.value * 0.35,
                  child: Stack(
                    children: [
                      _blob(
                        size,
                        const Alignment(-0.8, -0.7),
                        260,
                        fischerBlue300,
                      ),
                      _blob(
                        size,
                        const Alignment(0.9, 0.8),
                        220,
                        fischerBlue500,
                      ),
                      _blob(
                        size,
                        const Alignment(0.5, -0.9),
                        160,
                        fischerBlue100,
                      ),
                    ],
                  ),
                ),

                // ── Orbiting particles
                Opacity(
                  opacity: _bgFade.value,
                  child: CustomPaint(
                    size: size,
                    painter: _OrbitPainter(_orbitsCtrl.value),
                  ),
                ),

                // ── Concentric ripple rings
                _ring(180, _ringScale3.value, 0.06),
                _ring(140, _ringScale2.value, 0.10),
                _ring(100, _ringScale1.value, 0.15),

                // ── Pulse glow behind shield
                Opacity(
                  opacity: 0.18 + _pulseCtrl.value * 0.18,
                  child: Transform.scale(
                    scale: 0.90 + _pulseCtrl.value * 0.12,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: fischerBlue100,
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Shield icon
                Opacity(
                  opacity: _shieldFade.value,
                  child: Transform.scale(
                    scale: _shieldScale.value,
                    child: _ShieldWidget(shimmer: _shimmerCtrl.value),
                  ),
                ),

                // ── Text content
                Positioned(
                  bottom: size.height * 0.22,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Title
                      SlideTransition(
                        position: _titleSlide,
                        child: Opacity(
                          opacity: _titleFade.value,
                          child: const Text(
                            'VACCIGUIDE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle
                      SlideTransition(
                        position: _subtitleSlide,
                        child: Opacity(
                          opacity: _subtitleFade.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                fischerBlue100,
                                Colors.white,
                                fischerBlue100,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'دليلك الموثوق للتطعيمات',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tagline
                      Opacity(
                        opacity: _taglineFade.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 1,
                              color: fischerBlue100.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'حماية · تتبع · تذكير',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                color: fischerBlue100,
                                fontSize: 11,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 40,
                              height: 1,
                              color: fischerBlue100.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Loading dots
                Positioned(
                  bottom: size.height * 0.09,
                  child: Transform.scale(
                    scale: _dotsScale.value,
                    child: _LoadingDots(pulse: _pulseCtrl.value),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _blob(Size size, Alignment align, double radius, Color color) {
    return Align(
      alignment: align,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  Widget _ring(double diameter, double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: opacity),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Shield Widget ─────────────────────────────────────────────────────────────
class _ShieldWidget extends StatelessWidget {
  final double shimmer;
  const _ShieldWidget({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: CustomPaint(painter: _ShieldPainter(shimmer)),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final double shimmer;
  _ShieldPainter(this.shimmer);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield path
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.55)
      ..quadraticBezierTo(w, h * 0.85, w * 0.5, h)
      ..quadraticBezierTo(0, h * 0.85, 0, h * 0.55)
      ..lineTo(0, h * 0.25)
      ..close();

    // Shield fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          fischerBlue500.withValues(alpha: 0.9),
          fischerBlue700.withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, fillPaint);

    // Shimmer sweep
    final shimmerAngle = shimmer * math.pi * 2;
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(math.cos(shimmerAngle), math.sin(shimmerAngle)),
        end: Alignment(-math.cos(shimmerAngle), -math.sin(shimmerAngle)),
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, shimmerPaint);

    // Shield border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [fischerBlue100, fischerBlue300],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, borderPaint);

    // Cross icon inside shield
    _drawCross(canvas, size);
  }

  void _drawCross(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 4;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const arm = 14.0;
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), paint);
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), paint);

    // Small syringe needle on top
    final needlePaint = Paint()
      ..color = fischerBlue100
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy - arm),
      Offset(cx, cy - arm - 10),
      needlePaint,
    );

    // Needle tip dot
    canvas.drawCircle(
      Offset(cx, cy - arm - 10),
      2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter oldDelegate) =>
      oldDelegate.shimmer != shimmer;
}

// ── Orbiting Particles ────────────────────────────────────────────────────────
class _OrbitPainter extends CustomPainter {
  final double t;
  _OrbitPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final particles = [
      (220.0, 0.0, 8.0, fischerBlue100, 0.55),
      (220.0, 0.33, 5.0, fischerBlue300, 0.40),
      (220.0, 0.66, 6.0, fischerBlue50, 0.50),
      (160.0, 0.15, 4.0, fischerBlue100, 0.35),
      (160.0, 0.55, 7.0, fischerBlue300, 0.45),
      (290.0, 0.42, 5.5, fischerBlue50, 0.30),
      (290.0, 0.78, 4.0, fischerBlue100, 0.25),
    ];

    for (final (r, phase, radius, color, opacity) in particles) {
      final angle = (t + phase) * math.pi * 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle) * 0.35;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t;
}

// ── Loading Dots ──────────────────────────────────────────────────────────────
class _LoadingDots extends StatelessWidget {
  final double pulse;
  const _LoadingDots({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final phase = (pulse + i * 0.33) % 1.0;
        final scale = 0.6 + 0.4 * math.sin(phase * math.pi);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fischerBlue100.withValues(alpha: 0.5 + 0.5 * scale),
              ),
            ),
          ),
        );
      }),
    );
  }
}
