import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/space_invaders_game.dart';

class HUD extends PositionComponent with HasGameRef<SpaceInvadersGame> {
  late TextComponent _scoreText;
  late TextComponent _livesText;
  late TextComponent _highScoreText;
  late TextComponent _waveText;

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

    _highScoreText = TextComponent(
      text: 'HIGH: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 20,
          fontFamily: 'monospace',
        ),
      ),
      position: Vector2(SpaceInvadersGame.gameWidth / 2 - 60, 10),
    );
    add(_highScoreText);

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

    _waveText = TextComponent(
      text: 'WAVE: 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 20,
          fontFamily: 'monospace',
        ),
      ),
      position: Vector2(10, 40),
    );
    add(_waveText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scoreText.text = 'SCORE: ${gameRef.score}';
    _highScoreText.text = 'HIGH: ${gameRef.highScore}';
    _livesText.text = 'LIVES: ${gameRef.lives}';
    _waveText.text = 'WAVE: ${gameRef.currentWave}';
  }
}
