import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/enemy_fleet.dart';

class SpaceInvadersGame extends FlameGame with HasCollisionDetection {
  static const double gameWidth = 600;
  static const double gameHeight = 800;
  static const int maxLives = 3;

  late Player player;
  late EnemyFleet enemyFleet;
  int lives = maxLives;
  bool isGameOver = false;

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add player at bottom center
    player = Player(
      position: Vector2(gameWidth / 2, gameHeight - 50),
    );
    await add(player);

    // Add enemy fleet
    enemyFleet = EnemyFleet();
    await add(enemyFleet);
  }

  void playerHit() {
    if (isGameOver) return;

    lives--;
    
    if (lives <= 0) {
      isGameOver = true;
      // Game over will be handled by game states feature
    } else {
      // Respawn player
      player.respawn();
    }
  }
}
