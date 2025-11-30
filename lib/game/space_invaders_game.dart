import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/enemy_fleet.dart';

class SpaceInvadersGame extends FlameGame {
  static const double gameWidth = 600;
  static const double gameHeight = 800;

  late Player player;
  late EnemyFleet enemyFleet;

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
}
