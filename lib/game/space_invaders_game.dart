import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SpaceInvadersGame extends FlameGame {
  static const double gameWidth = 600;
  static const double gameHeight = 800;

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Game initialized with fixed boundaries
  }
}
