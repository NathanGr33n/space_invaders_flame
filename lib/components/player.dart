import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';
import 'bullet.dart';

class Player extends PositionComponent
    with HasGameRef<SpaceInvadersGame>, KeyboardHandler, CollisionCallbacks {
  static const double speed = 300.0;
  static const double playerWidth = 40.0;
  static const double playerHeight = 30.0;
  static const double shootCooldown = 0.3;
  static const double invulnerabilityDuration = 2.0;

  late Vector2 _velocity;
  final Vector2 _startPosition;
  double _timeSinceLastShot = 0;
  bool isInvulnerable = false;
  double _invulnerabilityTimer = 0;

  Player({required Vector2 position})
      : _startPosition = position.clone(),
        super(
          position: position,
          size: Vector2(playerWidth, playerHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _velocity = Vector2.zero();
    _timeSinceLastShot = shootCooldown;
    add(RectangleHitbox());
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

    // Update shoot cooldown
    _timeSinceLastShot += dt;

    // Update invulnerability
    if (isInvulnerable) {
      _invulnerabilityTimer += dt;
      if (_invulnerabilityTimer >= invulnerabilityDuration) {
        isInvulnerable = false;
        _invulnerabilityTimer = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Flicker during invulnerability
    if (isInvulnerable && (_invulnerabilityTimer * 10).toInt() % 2 == 0) {
      return;
    }
    
    // Draw simple player ship shape
    final paint = Paint()..color = Colors.green;
    
    final path = Path()
      ..moveTo(size.x / 2, 0) // Top center
      ..lineTo(size.x, size.y) // Bottom right
      ..lineTo(0, size.y) // Bottom left
      ..close();

    canvas.drawPath(path, paint);
  }

  void shoot() {
    if (_timeSinceLastShot >= shootCooldown) {
      final bullet = Bullet(
        position: Vector2(position.x, position.y - playerHeight / 2),
        isPlayerBullet: true,
      );
      gameRef.add(bullet);
      _timeSinceLastShot = 0;
    }
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

    // Shoot with Space or W/Up Arrow
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyW ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        shoot();
      }
    }

    return true;
  }

  void respawn() {
    position = _startPosition.clone();
    isInvulnerable = true;
    _invulnerabilityTimer = 0;
  }

  void takeDamage() {
    if (!isInvulnerable) {
      gameRef.playerHit();
    }
  }
}
