import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium animated background with subtle floating gradient orbs,
/// glowing reticles, and fine HUD grid overlay for a futuristic automotive telemetry feel.
class AnimatedAppBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;
  final bool animate;

  const AnimatedAppBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.animate = true,
  });

  @override
  State<AnimatedAppBackground> createState() => _AnimatedAppBackgroundState();
}

class _AnimatedAppBackgroundState extends State<AnimatedAppBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 1.3,
              colors: [
                Color(0xFF0F1B33), // Subtle illuminated center
                Color(0xFF090E1D), // Dark cockpit navy
                Color(0xFF050811), // Deep space obsidian
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _BackgroundPainter(
              animationValue: _controller.value,
              showGrid: widget.showGrid,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool showGrid;

  // Predefined deterministic pseudo-random particle seeds
  static final List<Offset> _particles = List.generate(24, (i) {
    final x = (math.sin(i * 123.456) * 0.5 + 0.5);
    final y = (math.cos(i * 789.012) * 0.5 + 0.5);
    return Offset(x, y);
  });

  _BackgroundPainter({
    required this.animationValue,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowOrbs(canvas, size);
    if (showGrid) {
      _drawGridPattern(canvas, size);
    }
    _drawParticles(canvas, size);
    _drawScanBeam(canvas, size);
  }

  void _drawGlowOrbs(Canvas canvas, Size size) {
    final double t = animationValue * 2 * math.pi;

    // Orb 1 — Neon Cyan (Top-Right drifting)
    final orb1X = size.width * (0.78 + 0.10 * math.sin(t));
    final orb1Y = size.height * (0.15 + 0.08 * math.cos(t * 0.8));
    final orb1Radius = size.width * 0.55;
    final orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withValues(alpha: 0.12),
          const Color(0xFF00D4FF).withValues(alpha: 0.04),
          const Color(0xFF00D4FF).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(orb1X, orb1Y), radius: orb1Radius));
    canvas.drawCircle(Offset(orb1X, orb1Y), orb1Radius, orb1Paint);

    // Orb 2 — Cyber Violet / Purple (Bottom-Left floating)
    final orb2X = size.width * (0.22 + 0.12 * math.cos(t * 0.6));
    final orb2Y = size.height * (0.78 + 0.09 * math.sin(t * 0.7));
    final orb2Radius = size.width * 0.50;
    final orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7B61FF).withValues(alpha: 0.10),
          const Color(0xFF7B61FF).withValues(alpha: 0.03),
          const Color(0xFF7B61FF).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(orb2X, orb2Y), radius: orb2Radius));
    canvas.drawCircle(Offset(orb2X, orb2Y), orb2Radius, orb2Paint);

    // Orb 3 — Tech Emerald / Mint (Center-Right subtle ambient accent)
    final orb3X = size.width * (0.65 + 0.15 * math.sin(t * 0.4 + 2.0));
    final orb3Y = size.height * (0.50 + 0.12 * math.cos(t * 0.5 + 1.0));
    final orb3Radius = size.width * 0.40;
    final orb3Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E676).withValues(alpha: 0.05),
          const Color(0xFF00E676).withValues(alpha: 0.015),
          const Color(0xFF00E676).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(orb3X, orb3Y), radius: orb3Radius));
    canvas.drawCircle(Offset(orb3X, orb3Y), orb3Radius, orb3Paint);
  }

  void _drawGridPattern(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.025)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    const spacing = 52.0;

    // Vertical grid lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal grid lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Precise alignment crosshairs at periodic intersections
    final crosshairPaint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.06)
      ..strokeWidth = 1.0;

    for (double x = spacing; x < size.width; x += spacing * 2) {
      for (double y = spacing; y < size.height; y += spacing * 2) {
        canvas.drawLine(Offset(x - 3, y), Offset(x + 3, y), crosshairPaint);
        canvas.drawLine(Offset(x, y - 3), Offset(x, y + 3), crosshairPaint);
      }
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _particles.length; i++) {
      final base = _particles[i];
      final phase = (animationValue * 2 * math.pi + i * 0.8);
      final alpha = (0.15 + 0.15 * math.sin(phase)).clamp(0.02, 0.35);
      final px = (base.dx * size.width + 12 * math.cos(phase)) % size.width;
      final py = (base.dy * size.height + 12 * math.sin(phase)) % size.height;

      particlePaint.color = (i % 2 == 0 ? const Color(0xFF00D4FF) : const Color(0xFF7B61FF))
          .withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), (i % 3 == 0) ? 1.6 : 1.0, particlePaint);
    }
  }

  void _drawScanBeam(Canvas canvas, Size size) {
    final scanY = size.height * ((animationValue * 1.2) % 1.0);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF00D4FF).withValues(alpha: 0.0),
          const Color(0xFF00D4FF).withValues(alpha: 0.045),
          const Color(0xFF7B61FF).withValues(alpha: 0.035),
          const Color(0xFF00D4FF).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, scanY - 1.5, size.width, 3));
    canvas.drawRect(Rect.fromLTWH(0, scanY - 1.5, size.width, 3), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// A simpler static gradient background for lower-end contexts.
class StaticAppBackground extends StatelessWidget {
  final Widget child;

  const StaticAppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.3,
          colors: [
            Color(0xFF0F1B33),
            Color(0xFF090E1D),
            Color(0xFF050811),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}
