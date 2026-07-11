import 'dart:ui';

import 'package:devil_run/game/game_input.dart';
import 'package:devil_run/game/game_world.dart';
import 'package:devil_run/models/level_definition.dart';
import 'package:devil_run/services/audio_service.dart';
import 'package:devil_run/services/save_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SaveService saves;
  late _SilentAudio audio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'sound_enabled': false,
      'music_enabled': false,
    });
    saves = SaveService();
    await saves.load();
    audio = _SilentAudio();
  });

  test('pause freezes play and toggles back to playing', () {
    final world = GameWorld(level: _basicLevel(), audioService: audio);
    final input = GameInput()..right = true;

    world.togglePause();
    world.update(1 / 60, input, const Size(800, 450));

    expect(world.state, PlayState.paused);
    expect(world.player.position, const Offset(20, 40));
    world.togglePause();
    expect(world.state, PlayState.playing);
  });

  test('jump input applies upward velocity and supports a double jump', () {
    final world = GameWorld(level: _basicLevel(), audioService: audio);
    final input = GameInput()..queueJump();

    world.update(1 / 60, input, const Size(800, 450));
    expect(world.player.velocity.dy, lessThan(0));
    expect(world.player.jumpsUsed, 1);

    input.queueJump();
    world.update(1 / 60, input, const Size(800, 450));
    expect(world.player.jumpsUsed, 2);
  });

  test('hazard kills player and respawns while preserving death count', () {
    final world = GameWorld(
      level: _basicLevel(
        extra: const [
          EntityDefinition(
            id: 'spike',
            kind: EntityKind.spike,
            rect: Rect.fromLTWH(20, 40, 50, 54),
          ),
        ],
      ),
      audioService: audio,
    );

    world.update(1 / 60, GameInput(), const Size(800, 450));
    expect(world.state, PlayState.dead);
    expect(world.deaths, 1);
    for (var i = 0; i < 29; i++) {
      world.update(1 / 30, GameInput(), const Size(800, 450));
    }
    expect(world.state, PlayState.playing);
    expect(world.player.position, const Offset(20, 40));
    expect(world.deaths, 1);
  });

  test('only the door named by doorId completes the level', () {
    final world = GameWorld(
      level: _basicLevel(
        extra: const [
          EntityDefinition(
            id: 'decoy',
            kind: EntityKind.door,
            rect: Rect.fromLTWH(20, 40, 50, 60),
          ),
        ],
      ),
      audioService: audio,
    );

    world.update(1 / 60, GameInput(), const Size(800, 450));
    expect(world.state, PlayState.playing);

    world.player.position = const Offset(330, 40);
    world.update(1 / 60, GameInput(), const Size(800, 450));
    expect(world.state, PlayState.complete);
  });

  test('target triggers reveal, hide, shift, and drop entities', () {
    for (final action in <TriggerAction>[
      TriggerAction.revealTarget,
      TriggerAction.surpriseSpike,
      TriggerAction.vanishTarget,
      TriggerAction.shiftTarget,
      TriggerAction.moveDoor,
      TriggerAction.dropTarget,
    ]) {
      final targetKind = action == TriggerAction.dropTarget
          ? EntityKind.fallingPlatform
          : action == TriggerAction.revealTarget ||
                action == TriggerAction.surpriseSpike
          ? EntityKind.hiddenSpike
          : EntityKind.platform;
      final world = GameWorld(
        level: _triggerLevel(action, targetKind),
        audioService: audio,
      );
      final target = world.entities.firstWhere(
        (entity) => entity.definition.id == 'target',
      );
      final originalRect = target.rect;

      world.update(1 / 60, GameInput(), const Size(800, 450));

      switch (action) {
        case TriggerAction.revealTarget || TriggerAction.surpriseSpike:
          expect(target.visible, isTrue, reason: action.name);
        case TriggerAction.vanishTarget:
          expect(target.active, isFalse, reason: action.name);
        case TriggerAction.shiftTarget:
          expect(target.rect.left, originalRect.left + 30, reason: action.name);
        case TriggerAction.moveDoor:
          expect(
            target.rect.left,
            originalRect.left - 330,
            reason: action.name,
          );
        case TriggerAction.dropTarget:
          expect(target.triggered, isTrue, reason: action.name);
        default:
          fail('Unexpected target action $action');
      }
    }
  });

  test('state triggers reverse controls, fake victory, and kill player', () {
    final expectedStates = <TriggerAction, PlayState>{
      TriggerAction.reverseControls: PlayState.playing,
      TriggerAction.fakeVictory: PlayState.fakeVictory,
      TriggerAction.killPlayer: PlayState.dead,
    };
    for (final entry in expectedStates.entries) {
      final world = GameWorld(
        level: _triggerLevel(entry.key, EntityKind.platform),
        audioService: audio,
      );
      world.update(1 / 60, GameInput(), const Size(800, 450));
      expect(world.state, entry.value, reason: entry.key.name);
      if (entry.key == TriggerAction.reverseControls) {
        expect(world.controlsReversed, isTrue);
      }
    }
  });

  test('completing a world persists the next unlocked level', () async {
    final world = GameWorld(level: _basicLevel(), audioService: audio);
    world.player.position = const Offset(330, 40);
    world.update(1 / 60, GameInput(), const Size(800, 450));
    expect(world.state, PlayState.complete);

    await saves.unlockThroughIndex(0);
    final reloaded = SaveService();
    await reloaded.load();

    expect(reloaded.progress.unlockedLevel, 2);
    expect(reloaded.progress.completedLevels, 1);
  });
}

class _SilentAudio implements GameAudio {
  @override
  Future<void> play(GameSound sound) async {}
}

LevelDefinition _basicLevel({List<EntityDefinition> extra = const []}) {
  return LevelDefinition(
    id: 1,
    name: 'Test',
    size: const Size(400, 200),
    spawn: const Offset(20, 40),
    doorId: 'real-door',
    reverseControls: false,
    entities: [
      const EntityDefinition(
        id: 'floor',
        kind: EntityKind.platform,
        rect: Rect.fromLTWH(0, 100, 400, 100),
      ),
      const EntityDefinition(
        id: 'real-door',
        kind: EntityKind.door,
        rect: Rect.fromLTWH(330, 40, 50, 60),
      ),
      ...extra,
    ],
  );
}

LevelDefinition _triggerLevel(TriggerAction action, EntityKind targetKind) {
  return LevelDefinition(
    id: 1,
    name: action.name,
    size: const Size(500, 220),
    spawn: const Offset(20, 40),
    doorId: 'door',
    reverseControls: false,
    entities: [
      const EntityDefinition(
        id: 'floor',
        kind: EntityKind.platform,
        rect: Rect.fromLTWH(0, 100, 500, 120),
      ),
      const EntityDefinition(
        id: 'door',
        kind: EntityKind.door,
        rect: Rect.fromLTWH(440, 40, 40, 60),
      ),
      EntityDefinition(
        id: 'target',
        kind: targetKind,
        rect: const Rect.fromLTWH(250, 40, 50, 40),
        delay: 10,
      ),
      EntityDefinition(
        id: 'trigger',
        kind: EntityKind.trigger,
        rect: const Rect.fromLTWH(0, 0, 100, 100),
        triggerAction: action,
        targetId: 'target',
        moveBy: const Offset(30, 0),
      ),
    ],
  );
}
