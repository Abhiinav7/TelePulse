import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Slowly drifting neon gradient blobs over a deep-space backdrop.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0420), AppTheme.deepSpace, Color(0xFF020208)],
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) => CustomPaint(painter: _AuroraPainter(_c.value)),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  _AuroraPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    void blob(Color color, double phase, double rx, double ry, double r, double a) {
      final ang = (t + phase) * 2 * math.pi;
      final c = Offset(
        size.width * (0.5 + rx * math.cos(ang)),
        size.height * (0.5 + ry * math.sin(ang * 0.8)),
      );
      final radius = size.shortestSide * r;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: a), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: radius));
      canvas.drawCircle(c, radius, paint);
    }

    blob(AppTheme.violet, 0.0, 0.35, 0.30, 0.9, 0.30);
    blob(AppTheme.primary, 0.35, 0.40, 0.35, 0.8, 0.20);
    blob(AppTheme.cyan, 0.65, 0.35, 0.40, 0.7, 0.16);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}

/// Text filled with a gradient.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppTheme.neonGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => gradient.createShader(r),
      child: Text(text, style: (style ?? const TextStyle()).copyWith(color: Colors.white)),
    );
  }
}

/// Section header with a glowing gradient accent bar.
class SectionTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  const SectionTitle(this.title, {super.key, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: fontSize + 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.cyan, AppTheme.magenta],
            ),
            boxShadow: [
              BoxShadow(color: AppTheme.magenta.withValues(alpha: 0.6), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: fontSize,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fades + slides its child up on first build. Use `index` to stagger.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final ms = 450 + math.min(index, 8) * 70;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

/// Neon-bordered glass tile decoration used by cards.
BoxDecoration glassTile({required bool active, double radius = 14}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: active
          ? [const Color(0xFF241A4D), const Color(0xFF1A0F33)]
          : [const Color(0xFF15183A), const Color(0xFF0C0E22)],
    ),
    border: Border.all(
      color: active ? AppTheme.cyan.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.08),
      width: active ? 1.6 : 1,
    ),
    boxShadow: active
        ? [
            BoxShadow(color: AppTheme.cyan.withValues(alpha: 0.35), blurRadius: 18, spreadRadius: 1),
            BoxShadow(color: AppTheme.magenta.withValues(alpha: 0.30), blurRadius: 28, offset: const Offset(0, 8)),
          ]
        : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
          ],
  );
}
