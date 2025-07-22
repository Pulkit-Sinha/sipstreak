import 'package:flutter/material.dart';
import 'dart:math';

class ConfettiEffect extends StatefulWidget {
  @override
  _ConfettiEffectState createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> particles = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Create confetti particles
    for (int i = 0; i < 30; i++) {
      particles.add(ConfettiParticle(random));
    }

    _controller.forward();
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
        return CustomPaint(
          painter: ConfettiPainter(particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;

  ConfettiParticle(Random random) {
    x = random.nextDouble();
    y = -0.1;
    vx = (random.nextDouble() - 0.5) * 0.5;
    vy = random.nextDouble() * 0.3 + 0.2;
    size = random.nextDouble() * 6 + 3;
    rotation = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
    
    // Colorful confetti
    final colors = [
      Colors.red.shade400,
      Colors.yellow.shade400,
      Colors.green.shade400,
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update(double progress) {
    y += vy * progress;
    x += vx * progress;
    rotation += rotationSpeed;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationProgress;

  ConfettiPainter(this.particles, this.animationProgress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(animationProgress);
      
      // Only draw particles that are within bounds
      if (particle.y <= 1.2) {
        final paint = Paint()
          ..color = particle.color
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(
          particle.x * size.width,
          particle.y * size.height,
        );
        canvas.rotate(particle.rotation);

        // Draw different shapes for variety
        final shapeType = particle.size % 3;
        if (shapeType < 1) {
          // Rectangle
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size),
            paint,
          );
        } else if (shapeType < 2) {
          // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
        } else {
          // Triangle
          final path = Path();
          path.moveTo(0, -particle.size / 2);
          path.lineTo(-particle.size / 2, particle.size / 2);
          path.lineTo(particle.size / 2, particle.size / 2);
          path.close();
          canvas.drawPath(path, paint);
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}