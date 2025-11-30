import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/player.dart';
import '../components/enemy_fleet.dart';
import '../components/hud.dart';
import '../components/shield.dart';

enum GameState { start, playing, paused, gameOver, victory }

class SpaceInvadersGame extends FlameGame with HasCollisionDetection, KeyboardEvents {
  static const double gameWidth = 600;
  static const double gameHeight = 800;
  static const int maxLives = 3;
  static const int enemyPoints = 10;

  late Player player;
  late EnemyFleet enemyFleet;
  late HUD hud;
  int lives = maxLives;
  int score = 0;
  GameState gameState = GameState.start;

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

    // Add HUD
    hud = HUD();
    await add(hud);

    // Add shields
    _addShields();

    overlays.add('start');
    pauseEngine();
  }

  void _addShields() {
    const shieldY = gameHeight - 200;
    const spacing = gameWidth / 5;
    
    for (int i = 1; i <= 4; i++) {
      final shield = Shield(
        position: Vector2(spacing * i, shieldY),
      );
      add(shield);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check victory condition
    if (gameState == GameState.playing && 
        enemyFleet.children.isEmpty) {
      gameState = GameState.victory;
      overlays.add('victory');
      pauseEngine();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      // Start game
      if (gameState == GameState.start && 
          event.logicalKey == LogicalKeyboardKey.enter) {
        startGame();
        return KeyEventResult.handled;
      }
      
      // Pause/unpause
      if (gameState == GameState.playing && 
          event.logicalKey == LogicalKeyboardKey.escape) {
        pauseGame();
        return KeyEventResult.handled;
      }
      
      if (gameState == GameState.paused && 
          event.logicalKey == LogicalKeyboardKey.escape) {
        resumeGame();
        return KeyEventResult.handled;
      }

      // Restart after game over or victory
      if ((gameState == GameState.gameOver || gameState == GameState.victory) &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        resetGame();
        return KeyEventResult.handled;
      }
    }
    
    return KeyEventResult.ignored;
  }

  void playerHit() {
    if (gameState != GameState.playing) return;

    lives--;
    
    if (lives <= 0) {
      gameState = GameState.gameOver;
      overlays.add('gameOver');
      pauseEngine();
    } else {
      // Respawn player
      player.respawn();
    }
  }

  void addScore(int points) {
    score += points;
  }

  void startGame() {
    gameState = GameState.playing;
    overlays.remove('start');
    resumeEngine();
  }

  void pauseGame() {
    gameState = GameState.paused;
    overlays.add('paused');
    pauseEngine();
  }

  void resumeGame() {
    gameState = GameState.playing;
    overlays.remove('paused');
    resumeEngine();
  }

  void resetGame() {
    // Remove all overlays
    overlays.clear();
    
    // Reset game state
    lives = maxLives;
    score = 0;
    gameState = GameState.playing;
    
    // Remove all enemies
    enemyFleet.removeFromParent();
    
    // Create new fleet
    enemyFleet = EnemyFleet();
    add(enemyFleet);
    
    // Reset player
    player.respawn();
    
    resumeEngine();
  }
}
