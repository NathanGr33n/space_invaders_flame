import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../components/player.dart';
import '../components/enemy_fleet.dart';
import '../components/hud.dart';
import '../components/shield.dart';
import '../components/mystery_ship.dart';

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
  int highScore = 0;
  int currentWave = 1;
  GameState gameState = GameState.start;
  
  double _mysteryShipTimer = 0;
  static const double mysteryShipInterval = 15.0; // Every 15 seconds
  final Random _random = Random();
  bool _isTransitioningWave = false;

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load high score
    await _loadHighScore();
    
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
    // Don't pause engine - just use gameState to control behavior
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

    // Check wave completion
    if (gameState == GameState.playing && 
        enemyFleet.children.isEmpty && 
        !_isTransitioningWave) {
      _startNextWave();
    }

    // Mystery ship spawning
    if (gameState == GameState.playing) {
      _mysteryShipTimer += dt;
      if (_mysteryShipTimer >= mysteryShipInterval) {
        _spawnMysteryShip();
        _mysteryShipTimer = 0;
      }
    }
  }

  void _spawnMysteryShip() {
    final fromRight = _random.nextBool();
    final startX = fromRight ? gameWidth + 25 : -25;
    
    final mysteryShip = MysteryShip(
      position: Vector2(startX, 50),
      movingRight: !fromRight,
    );
    add(mysteryShip);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    print('Game onKeyEvent - State: $gameState, Event: ${event.runtimeType}, Keys: $keysPressed');
    
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
    
    // During gameplay, forward keyboard events to player
    if (gameState == GameState.playing) {
      final result = player.onKeyEvent(event, keysPressed);
      if (result) {
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
    } else {
      // Respawn player
      player.respawn();
    }
  }

  void addScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
      _saveHighScore();
    }
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', highScore);
  }

  void startGame() {
    print('Starting game - changing state to playing');
    gameState = GameState.playing;
    overlays.remove('start');
    print('Game state is now: $gameState');
  }

  void pauseGame() {
    gameState = GameState.paused;
    overlays.add('paused');
  }

  void resumeGame() {
    gameState = GameState.playing;
    overlays.remove('paused');
  }

  void resetGame() {
    // Remove all overlays
    overlays.clear();
    
    // Reset game state
    lives = maxLives;
    score = 0;
    currentWave = 1;
    gameState = GameState.playing;
    _isTransitioningWave = false;
    
    // Remove all enemies
    enemyFleet.removeFromParent();
    
    // Create new fleet
    enemyFleet = EnemyFleet();
    add(enemyFleet);
    
    // Reset player
    player.respawn();
  }

  void _startNextWave() {
    _isTransitioningWave = true;
    currentWave++;
    
    // Show wave transition (brief delay)
    Future.delayed(const Duration(seconds: 2), () {
      if (gameState == GameState.playing) {
        // Remove old fleet
        enemyFleet.removeFromParent();
        
        // Create new fleet with increased difficulty
        enemyFleet = EnemyFleet(waveMultiplier: currentWave.toDouble());
        add(enemyFleet);
        
        _isTransitioningWave = false;
      }
    });
  }
}
