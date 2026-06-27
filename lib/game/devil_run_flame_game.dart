import 'dart:ui';

import 'package:flame/game.dart';

import '../models/level_definition.dart';
import '../services/audio_service.dart';
import 'game_input.dart';
import 'game_painter.dart';
import 'game_world.dart';

class DevilRunFlameGame extends FlameGame {
  DevilRunFlameGame({
    required LevelDefinition level,
    required this.input,
    required AudioService audioService,
    required this.onLevelComplete,
    required this.onStateChanged,
  }) : gameWorld = GameWorld(level: level, audioService: audioService);

  final GameInput input;
  final GameWorld gameWorld;
  final VoidCallback onLevelComplete;
  final VoidCallback onStateChanged;
  PlayState? _lastState;
  bool _completeHandled = false;

  @override
  Color backgroundColor() => const Color(0xff080b0d);

  @override
  void update(double dt) {
    super.update(dt);
    final before = gameWorld.state;
    gameWorld.update(dt, input, Size(size.x, size.y));
    if (before != gameWorld.state || _lastState != gameWorld.state) {
      _lastState = gameWorld.state;
      onStateChanged();
    }
    if (gameWorld.state == PlayState.complete && !_completeHandled) {
      _completeHandled = true;
      onLevelComplete();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    GamePainter(gameWorld).paint(canvas, Size(size.x, size.y));
  }

  void restartLevel() {
    _completeHandled = false;
    input.reset();
    gameWorld.restart(resetDeaths: true);
    onStateChanged();
  }

  void togglePause() {
    gameWorld.togglePause();
    onStateChanged();
  }
}
