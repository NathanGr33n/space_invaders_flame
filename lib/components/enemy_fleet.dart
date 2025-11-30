import 'package:flame/components.dart';
import '../game/space_invaders_game.dart';
import 'enemy.dart';

class EnemyFleet extends Component with HasGameRef<SpaceInvadersGame> {
  static const int rows = 5;
  static const int columns = 11;
  static const double horizontalSpacing = 45.0;
  static const double verticalSpacing = 40.0;
  static const double speed = 30.0;
  static const double downwardStep = 20.0;

  double _direction = 1; // 1 for right, -1 for left
  double _leftBound = 0;
  double _rightBound = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _createFleet();
  }

  void _createFleet() {
    const startX = (SpaceInvadersGame.gameWidth - 
        (columns - 1) * horizontalSpacing) / 2;
    const startY = 80.0;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final enemy = Enemy(
          position: Vector2(
            startX + col * horizontalSpacing,
            startY + row * verticalSpacing,
          ),
        );
        add(enemy);
      }
    }

    _updateBounds();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (children.isEmpty) return;

    // Move all enemies horizontally
    for (final child in children) {
      if (child is Enemy) {
        child.position.x += speed * _direction * dt;
      }
    }

    _updateBounds();

    // Check if any enemy hit the edge
    if ((_direction > 0 && _rightBound >= SpaceInvadersGame.gameWidth - 20) ||
        (_direction < 0 && _leftBound <= 20)) {
      _moveDown();
      _direction *= -1; // Reverse direction
    }
  }

  void _updateBounds() {
    if (children.isEmpty) return;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;

    for (final child in children) {
      if (child is Enemy) {
        final leftEdge = child.position.x - child.size.x / 2;
        final rightEdge = child.position.x + child.size.x / 2;
        
        if (leftEdge < minX) minX = leftEdge;
        if (rightEdge > maxX) maxX = rightEdge;
      }
    }

    _leftBound = minX;
    _rightBound = maxX;
  }

  void _moveDown() {
    for (final child in children) {
      if (child is Enemy) {
        child.position.y += downwardStep;
      }
    }
  }
}
