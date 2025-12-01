import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';

class MysteryShip extends PositionComponent
    with HasGameRef<SpaceInvadersGame>, CollisionCallbacks {
  static const double shipWidth = 50.0;
  static const double shipHeight = 25.0;
  static const double speed = 120.0;
  static const int bonusPoints = 100;

  final bool movingRight;

  MysteryShip({required Vector2 position, this.movingRight = true})
      : super(
          position: position,
          size: Vector2(shipWidth, shipHeight),
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

    // Only update during gameplay
    if (gameRef.gameState != GameState.playing) return;

    // Move horizontally
    position.x += (movingRight ? speed : -speed) * dt;

    // Remove when off screen
    if (position.x < -shipWidth || position.x > SpaceInvadersGame.gameWidth + shipWidth) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw UFO-style mystery ship
    final paint = Paint()..color = Colors.purple;

    // Dome
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.2, 0, size.x * 0.6, size.y * 0.5),
      paint,
    );

    // Base
    canvas.drawOval(
      Rect.fromLTWH(0, size.y * 0.35, size.x, size.y * 0.4),
      paint,
    );

    // Lights
    final lightPaint = Paint()..color = Colors.yellow;
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.x * (0.2 + i * 0.2), size.y * 0.6),
        2,
        lightPaint,
      );
    }
  }

  void destroy() {
    gameRef.addScore(bonusPoints);
    removeFromParent();
  }
}
