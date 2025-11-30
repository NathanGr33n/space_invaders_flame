import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';

class HUD extends PositionComponent with HasGameRef<SpaceInvadersGame> {
  late TextComponent _scoreText;
  late TextComponent _livesText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _scoreText = TextComponent(
      text: 'SCORE: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontFamily: 'monospace',
        ),
      ),
      position: Vector2(10, 10),
    );
    add(_scoreText);

    _livesText = TextComponent(
      text: 'LIVES: 3',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontFamily: 'monospace',
        ),
      ),
      position: Vector2(SpaceInvadersGame.gameWidth - 120, 10),
    );
    add(_livesText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scoreText.text = 'SCORE: ${gameRef.score}';
    _livesText.text = 'LIVES: ${gameRef.lives}';
  }
}
