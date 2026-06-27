import 'dart:math' as math;
import 'dart:ui';

import '../models/level_definition.dart';
import '../services/audio_service.dart';
import 'game_entity.dart';
import 'game_input.dart';

enum PlayState { playing, paused, dead, complete, fakeVictory }

class PlayerBody {
  PlayerBody(this.spawn) : position = spawn;

  final Offset spawn;
  Offset position;
  Offset velocity = Offset.zero;
  bool grounded = false;
  bool facingRight = true;
  int jumpsUsed = 0;
  double deathTimer = 0;
  double animationTime = 0;

  static const Size size = Size(42, 54);
  Rect get rect =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

  void reset() {
    position = spawn;
    velocity = Offset.zero;
    grounded = false;
    facingRight = true;
    jumpsUsed = 0;
    deathTimer = 0;
    animationTime = 0;
  }
}

class Particle {
  Particle({
    required this.position,
    required this.velocity,
    required this.color,
  });

  Offset position;
  Offset velocity;
  Color color;
  double age = 0;
  double life = 0.65;
}

class GameWorld {
  GameWorld({required this.level, required this.audioService}) {
    _buildLevel();
  }

  final LevelDefinition level;
  final AudioService audioService;
  late PlayerBody player;
  late List<GameEntity> entities;
  final List<Particle> particles = [];
  PlayState state = PlayState.playing;
  Offset camera = Offset.zero;
  double shake = 0;
  double messageTimer = 0;
  bool controlsReversed = false;
  int deaths = 0;

  static const double _gravity = 1900;
  static const double _moveSpeed = 430;
  static const double _acceleration = 2800;
  static const double _friction = 2600;
  static const double _jumpVelocity = -720;

  void _buildLevel({bool resetDeaths = false}) {
    player = PlayerBody(level.spawn);
    entities = level.entities.map(GameEntity.fromDefinition).toList();
    controlsReversed = level.reverseControls;
    state = PlayState.playing;
    particles.clear();
    shake = 0;
    messageTimer = 0;
    camera = Offset.zero;
    if (resetDeaths) deaths = 0;
  }

  void restart({bool resetDeaths = false}) {
    _buildLevel(resetDeaths: resetDeaths);
  }

  void togglePause() {
    if (state == PlayState.playing) {
      state = PlayState.paused;
    } else if (state == PlayState.paused) {
      state = PlayState.playing;
    }
  }

  void update(double dt, GameInput input, Size viewport) {
    final cappedDt = dt.clamp(0.0, 1 / 30).toDouble();
    _updateParticles(cappedDt);
    if (shake > 0) shake = math.max(0, shake - cappedDt * 22);

    if (state == PlayState.dead) {
      player.deathTimer += cappedDt;
      if (player.deathTimer > 0.95) restart();
      _updateCamera(viewport, cappedDt);
      input.consumeJump();
      return;
    }
    if (state == PlayState.fakeVictory) {
      messageTimer -= cappedDt;
      if (messageTimer <= 0) {
        state = PlayState.playing;
      }
      _updateCamera(viewport, cappedDt);
      input.consumeJump();
      return;
    }
    if (state != PlayState.playing) {
      input.consumeJump();
      return;
    }

    for (final entity in entities) {
      entity.update(cappedDt);
    }

    _updatePlayer(cappedDt, input);
    _runTriggers();
    _checkHazards();
    _checkDoor();
    _updateCamera(viewport, cappedDt);
    input.consumeJump();
  }

  void _updatePlayer(double dt, GameInput input) {
    player.animationTime += dt;
    var horizontal = 0.0;
    if (input.left) horizontal -= 1;
    if (input.right) horizontal += 1;
    if (controlsReversed) horizontal *= -1;

    if (horizontal != 0) {
      final target = horizontal * _moveSpeed;
      final nextX = _approach(player.velocity.dx, target, _acceleration * dt);
      player.velocity = Offset(nextX, player.velocity.dy);
      player.facingRight = horizontal > 0;
    } else {
      final nextX = _approach(player.velocity.dx, 0, _friction * dt);
      player.velocity = Offset(nextX, player.velocity.dy);
    }

    if (input.jumpQueued && player.jumpsUsed < 2) {
      player.velocity = Offset(player.velocity.dx, _jumpVelocity);
      player.grounded = false;
      player.jumpsUsed++;
      audioService.play(GameSound.jump);
      _burst(player.rect.center, const Color(0xfff9f871), 8);
    }

    player.velocity = Offset(
      player.velocity.dx,
      player.velocity.dy + _gravity * dt,
    );
    _moveAndCollide(Offset(player.velocity.dx * dt, 0), horizontalAxis: true);
    _moveAndCollide(Offset(0, player.velocity.dy * dt), horizontalAxis: false);

    if (player.position.dy > level.size.height + 220) {
      killPlayer();
    }
  }

  void _moveAndCollide(Offset movement, {required bool horizontalAxis}) {
    player.position += movement;
    var playerRect = player.rect;
    for (final entity in entities.where(
      (entity) => entity.isSolid && entity.visible,
    )) {
      if (!playerRect.overlaps(entity.rect)) continue;
      if (entity.kind == EntityKind.fakePlatform) {
        entity.active = false;
        entity.visible = false;
        continue;
      }
      if (entity.kind == EntityKind.fallingPlatform ||
          entity.kind == EntityKind.disappearingPlatform) {
        entity.triggered = true;
      }

      if (horizontalAxis) {
        if (movement.dx > 0) {
          player.position = Offset(
            entity.rect.left - PlayerBody.size.width,
            player.position.dy,
          );
        } else if (movement.dx < 0) {
          player.position = Offset(entity.rect.right, player.position.dy);
        }
        player.velocity = Offset(0, player.velocity.dy);
      } else {
        if (movement.dy > 0) {
          player.position = Offset(
            player.position.dx,
            entity.rect.top - PlayerBody.size.height,
          );
          player.velocity = Offset(player.velocity.dx, 0);
          player.grounded = true;
          player.jumpsUsed = 0;
        } else if (movement.dy < 0) {
          player.position = Offset(player.position.dx, entity.rect.bottom);
          player.velocity = Offset(player.velocity.dx, 0);
        }
      }
      playerRect = player.rect;
    }

    if (!horizontalAxis && movement.dy > 0) {
      final foot = player.rect.translate(0, 2);
      player.grounded = entities.any(
        (entity) =>
            entity.isSolid && entity.visible && foot.overlaps(entity.rect),
      );
      if (!player.grounded && player.jumpsUsed == 0) player.jumpsUsed = 1;
    }
    player.position = Offset(
      player.position.dx.clamp(0, level.size.width - PlayerBody.size.width),
      player.position.dy,
    );
  }

  void _runTriggers() {
    final rect = player.rect;
    for (final trigger in entities.where(
      (entity) => entity.kind == EntityKind.trigger && entity.active,
    )) {
      if (!rect.overlaps(trigger.rect)) continue;
      if (trigger.triggered && trigger.definition.once) continue;
      trigger.triggered = true;
      switch (trigger.definition.triggerAction) {
        case TriggerAction.vanishTarget:
          _withTarget(trigger, (target) {
            target.active = false;
            target.visible = false;
            _burst(target.rect.center, const Color(0xffff477e), 12);
          });
        case TriggerAction.moveDoor:
          _withTarget(trigger, (target) {
            target.rect = target.rect.translate(-330, 0);
            _burst(target.rect.center, const Color(0xff00f5d4), 16);
          });
        case TriggerAction.revealTarget || TriggerAction.surpriseSpike:
          _withTarget(trigger, (target) {
            target.visible = true;
            target.active = true;
            _burst(target.rect.center, const Color(0xffff477e), 12);
          });
        case TriggerAction.reverseControls:
          controlsReversed = !controlsReversed;
          _burst(player.rect.center, const Color(0xff9b5de5), 14);
        case TriggerAction.fakeVictory:
          state = PlayState.fakeVictory;
          messageTimer = 1.25;
          audioService.play(GameSound.win);
        case TriggerAction.dropTarget:
          _withTarget(trigger, (target) {
            target.triggered = true;
            target.active = true;
            target.visible = true;
            _burst(target.rect.center, const Color(0xffffbe0b), 14);
          });
        case TriggerAction.shiftTarget:
          _withTarget(trigger, (target) {
            final shift = trigger.definition.moveBy == Offset.zero
                ? const Offset(-260, 0)
                : trigger.definition.moveBy;
            target.rect = target.rect.translate(shift.dx, shift.dy);
            _burst(target.rect.center, const Color(0xff00c2ff), 16);
          });
        case TriggerAction.killPlayer:
          killPlayer();
        case null:
          break;
      }
    }
  }

  void _withTarget(
    GameEntity trigger,
    void Function(GameEntity target) action,
  ) {
    final id = trigger.definition.targetId;
    if (id == null) return;
    for (final target in entities) {
      if (target.definition.id == id) {
        action(target);
        return;
      }
    }
  }

  void _checkHazards() {
    final hurtBox = player.rect.deflate(7);
    for (final hazard in entities.where(
      (entity) => entity.isHazard && entity.visible,
    )) {
      if (hurtBox.overlaps(hazard.rect.deflate(5))) {
        killPlayer();
        return;
      }
    }
  }

  void _checkDoor() {
    for (final door in entities.where((entity) => entity.isDoor)) {
      if (player.rect.overlaps(door.rect.deflate(4))) {
        state = PlayState.complete;
        audioService.play(GameSound.win);
        _burst(player.rect.center, const Color(0xff00f5d4), 26);
        return;
      }
    }
  }

  void killPlayer() {
    if (state == PlayState.dead || state == PlayState.complete) return;
    state = PlayState.dead;
    deaths++;
    player.deathTimer = 0;
    shake = 15;
    audioService.play(GameSound.death);
    _burst(player.rect.center, const Color(0xffff477e), 28);
  }

  void _updateCamera(Size viewport, double dt) {
    camera = Offset.zero;
  }

  void _burst(Offset origin, Color color, int count) {
    final random = math.Random();
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 120 + random.nextDouble() * 320;
      particles.add(
        Particle(
          position: origin,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
        ),
      );
    }
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.age += dt;
      p.velocity = Offset(p.velocity.dx, p.velocity.dy + 900 * dt);
      p.position += p.velocity * dt;
    }
    particles.removeWhere((p) => p.age >= p.life);
  }

  double _approach(double current, double target, double amount) {
    if (current < target) return math.min(current + amount, target);
    if (current > target) return math.max(current - amount, target);
    return target;
  }
}
