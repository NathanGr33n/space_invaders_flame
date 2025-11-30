import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';
import 'enemy.dart';
import 'player.dart';

class Bullet extends PositionComponent
    with HasGameRef<SpaceInvadersGame>, CollisionCallbacks {
  static const double speed = 400.0;
  static const double bulletWidth = 4.0;
  static const double bulletHeight = 12.0;

  final bool isPlayerBullet;

  Bullet({
    required Vector2 position,
    this.isPlayerBullet = true,
  }) : super(
          position: position,
          size: Vector2(bulletWidth, bulletHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move bullet up or down depending on who shot it
    if (isPlayerBullet) {
      position.y -= speed * dt;
    } else {
      position.y += speed * dt;
    }

    // Remove bullet if it goes off screen
    if (position.y < -bulletHeight ||
        position.y > SpaceInvadersGame.gameHeight + bulletHeight) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = isPlayerBullet ? Colors.yellow : Colors.red;

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

    if (isPlayerBullet && other is Enemy) {
      // Player bullet hit enemy
      removeFromParent();
      other.removeFromParent();
    } else if (!isPlayerBullet && other is Player) {
      // Enemy bullet hit player
      removeFromParent();
      // Player damage will be handled later with lives system
    }
  }
}
