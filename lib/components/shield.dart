import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';
import 'bullet.dart';

class Shield extends PositionComponent
    with HasGameRef<SpaceInvadersGame>, CollisionCallbacks {
  static const double shieldWidth = 60.0;
  static const double shieldHeight = 40.0;
  static const int maxHealth = 3;

  int health = maxHealth;

  Shield({required Vector2 position})
      : super(
          position: position,
          size: Vector2(shieldWidth, shieldHeight),
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

    // Change color based on health
    Color shieldColor;
    if (health == 3) {
      shieldColor = Colors.cyan;
    } else if (health == 2) {
      shieldColor = Colors.cyan.withOpacity(0.6);
    } else {
      shieldColor = Colors.cyan.withOpacity(0.3);
    }

    final paint = Paint()..color = shieldColor;

    // Draw shield shape
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      takeDamage();
      other.removeFromParent();
    }
  }

  void takeDamage() {
    health--;
    if (health <= 0) {
      removeFromParent();
    }
  }
}
