import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';

class Enemy extends PositionComponent
    with HasGameRef<SpaceInvadersGame>, CollisionCallbacks {
  static const double enemyWidth = 35.0;
  static const double enemyHeight = 25.0;

  Enemy({required Vector2 position})
      : super(
          position: position,
          size: Vector2(enemyWidth, enemyHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw simple enemy shape
    final paint = Paint()..color = Colors.red;

    // Body
    canvas.drawRect(
      Rect.fromLTWH(5, 10, size.x - 10, size.y - 10),
      paint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.5), 3, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.5), 3, eyePaint);

    // Antennae
    canvas.drawLine(
      Offset(size.x * 0.25, 10),
      Offset(size.x * 0.25, 0),
      paint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(size.x * 0.75, 10),
      Offset(size.x * 0.75, 0),
      paint..strokeWidth = 2,
    );
  }
}
