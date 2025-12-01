import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Explosion extends Component {
  final Vector2 position;
  final Color color;
  final List<_Particle> _particles = [];
  static const double lifetime = 0.6;
  double _age = 0;

  Explosion({
    required this.position,
    this.color = Colors.orange,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create particles
    final random = Random();
    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 50 + random.nextDouble() * 100;
      final velocity = Vector2(
        cos(angle) * speed,
        sin(angle) * speed,
      );
      
      _particles.add(_Particle(
        position: position.clone(),
        velocity: velocity,
        size: 2 + random.nextDouble() * 3,
        color: _randomExplosionColor(random),
      ));
    }
  }

  Color _randomExplosionColor(Random random) {
    final colors = [
      Colors.orange,
      Colors.yellow,
      Colors.red,
      Colors.white,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _age += dt;
    
    // Update particles
    for (final particle in _particles) {
      particle.update(dt);
    }
    
    // Remove when done
    if (_age >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final opacity = (1.0 - _age / lifetime).clamp(0.0, 1.0);
    
    for (final particle in _particles) {
      particle.render(canvas, opacity);
    }
  }
}

class _Particle {
  Vector2 position;
  final Vector2 velocity;
  final double size;
  final Color color;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });

  void update(double dt) {
    position += velocity * dt;
    // Apply gravity
    velocity.y += 200 * dt;
  }

  void render(Canvas canvas, double opacity) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(position.x, position.y),
      size,
      paint,
    );
  }
}
