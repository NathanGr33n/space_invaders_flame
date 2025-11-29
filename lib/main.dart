import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/space_invaders_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Invaders',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: GameWidget(
        game: SpaceInvadersGame(),
      ),
    );
  }
}
