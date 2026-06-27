import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/devil_run_flame_game.dart';
import '../game/game_input.dart';
import '../game/game_world.dart';
import '../levels/level_catalog.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../widgets/game_button.dart';
import '../widgets/touch_controls.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.levelIndex,
    required this.saveService,
    required this.audioService,
    super.key,
  });

  final int levelIndex;
  final SaveService saveService;
  final AudioService audioService;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  DevilRunFlameGame? _game;
  int? _levelIndex;
  final GameInput _input = GameInput();
  final FocusNode _focusNode = FocusNode();
  PlayState? _lastFeedbackState;

  @override
  void initState() {
    super.initState();
    final levelIndex = LevelCatalog.clampIndex(widget.levelIndex);
    if (levelIndex == null) return;
    final level = LevelCatalog.at(levelIndex);
    if (level == null) return;
    final safeLevelIndex = levelIndex;
    _levelIndex = safeLevelIndex;
    _game = DevilRunFlameGame(
      level: level,
      input: _input,
      audioService: widget.audioService,
      onLevelComplete: () {
        widget.saveService.unlockThroughIndex(safeLevelIndex);
        if (mounted) setState(() {});
      },
      onStateChanged: _handleGameStateChanged,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _restart() {
    widget.audioService.play(GameSound.click);
    _lastFeedbackState = null;
    _game?.restartLevel();
  }

  void _handleGameStateChanged() {
    final game = _game;
    if (game == null) return;
    final state = game.gameWorld.state;
    if (widget.saveService.progress.vibrationEnabled &&
        state != _lastFeedbackState) {
      if (state == PlayState.dead) {
        HapticFeedback.heavyImpact();
      } else if (state == PlayState.complete) {
        HapticFeedback.lightImpact();
      }
    }
    _lastFeedbackState = state;
    if (mounted) setState(() {});
  }

  void _nextLevel() {
    widget.audioService.play(GameSound.click);
    final next = LevelCatalog.nextIndexAfter(_levelIndex ?? widget.levelIndex);
    if (next == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LevelSelectScreen(
            saveService: widget.saveService,
            audioService: widget.audioService,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelIndex: next,
          saveService: widget.saveService,
          audioService: widget.audioService,
        ),
      ),
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final down = event is KeyDownEvent || event is KeyRepeatEvent;
    final up = event is KeyUpEvent;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft) {
      _input.left = down
          ? true
          : up
          ? false
          : _input.left;
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyD ||
        key == LogicalKeyboardKey.arrowRight) {
      _input.right = down
          ? true
          : up
          ? false
          : _input.right;
      return KeyEventResult.handled;
    }
    if (down &&
        (key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.arrowUp ||
            key == LogicalKeyboardKey.keyW)) {
      _input.queueJump();
      return KeyEventResult.handled;
    }
    if (down && key == LogicalKeyboardKey.escape) {
      _game?.togglePause();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final levelIndex = _levelIndex;
    final level = levelIndex == null ? null : LevelCatalog.at(levelIndex);
    if (game == null || levelIndex == null || level == null) {
      return Scaffold(
        backgroundColor: const Color(0xff0f172a),
        body: Center(
          child: GameButton(
            label: 'Levels',
            icon: Icons.grid_view_rounded,
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LevelSelectScreen(
                  saveService: widget.saveService,
                  audioService: widget.audioService,
                ),
              ),
            ),
          ),
        ),
      );
    }
    final world = game.gameWorld;
    final isLastLevel = LevelCatalog.isLastIndex(levelIndex);
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xff0f172a),
        body: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: game)),
            Positioned(
              left: 18,
              top: 14,
              child: _HudPill(
                icon: Icons.flag_rounded,
                text: 'Level ${levelIndex + 1}: ${level.name}',
              ),
            ),
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: _HudPill(
                  icon: Icons.dangerous_rounded,
                  text: '${world.deaths}',
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 14,
              child: Row(
                children: [
                  if (world.controlsReversed)
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: _HudPill(
                        icon: Icons.swap_horiz_rounded,
                        text: 'Reversed',
                      ),
                    ),
                  IconButton.filled(
                    onPressed: () {
                      widget.audioService.play(GameSound.click);
                      game.togglePause();
                    },
                    icon: Icon(
                      world.state == PlayState.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                    ),
                  ),
                ],
              ),
            ),
            if (world.state == PlayState.playing ||
                world.state == PlayState.fakeVictory)
              TouchControls(
                onLeftChanged: (value) => _input.left = value,
                onRightChanged: (value) => _input.right = value,
                onJump: _input.queueJump,
              ),
            if (world.state == PlayState.paused)
              _GameOverlay(
                title: 'Paused',
                subtitle: 'The traps are politely waiting.',
                actions: [
                  GameButton(
                    label: 'Resume',
                    icon: Icons.play_arrow_rounded,
                    onPressed: game.togglePause,
                  ),
                  GameButton(
                    label: 'Restart',
                    icon: Icons.refresh_rounded,
                    onPressed: _restart,
                  ),
                  GameButton(
                    label: 'Levels',
                    icon: Icons.grid_view_rounded,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LevelSelectScreen(
                          saveService: widget.saveService,
                          audioService: widget.audioService,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (world.state == PlayState.complete)
              _GameOverlay(
                title: isLastLevel ? 'You Beat It' : 'Level Complete',
                subtitle: isLastLevel
                    ? 'All current traps survived.'
                    : 'Somehow, that was the real door.',
                actions: [
                  GameButton(
                    label: 'Restart',
                    icon: Icons.refresh_rounded,
                    onPressed: _restart,
                  ),
                  GameButton(
                    label: isLastLevel ? 'Levels' : 'Next Level',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _nextLevel,
                  ),
                ],
              ),
            if (world.state == PlayState.fakeVictory)
              IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff0f172a).withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LEVEL COMPLETE! ...almost',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff0f172a).withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _GameOverlay extends StatelessWidget {
  const _GameOverlay({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.54),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xff111827),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: actions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
