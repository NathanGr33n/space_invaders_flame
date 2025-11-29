import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';

class Player extends PositionComponent
    with HasGameRef<SpaceInvadersGame>, KeyboardHandler {
  static const double speed = 300.0;
  static const double playerWidth = 40.0;
  static const double playerHeight = 30.0;

  late Vector2 _velocity;

  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2(playerWidth, playerHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _velocity = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply velocity
    position += _velocity * dt;

    // Keep player within bounds
    final halfWidth = size.x / 2;
    if (position.x < halfWidth) {
      position.x = halfWidth;
    } else if (position.x > SpaceInvadersGame.gameWidth - halfWidth) {
      position.x = SpaceInvadersGame.gameWidth - halfWidth;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw simple player ship shape
    final paint = Paint()..color = Colors.green;
    
    final path = Path()
      ..moveTo(size.x / 2, 0) // Top center
      ..lineTo(size.x, size.y) // Bottom right
      ..lineTo(0, size.y) // Bottom left
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _velocity.x = 0;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _velocity.x = -speed;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _velocity.x = speed;
    }

    return true;
  }
}
