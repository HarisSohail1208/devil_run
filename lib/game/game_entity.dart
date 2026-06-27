import 'dart:math' as math;
import 'dart:ui';

import '../models/level_definition.dart';

class GameEntity {
  GameEntity.fromDefinition(this.definition)
    : rect = definition.rect,
      active = true,
      visible = definition.kind != EntityKind.hiddenSpike,
      origin = definition.rect.topLeft;

  final EntityDefinition definition;
  Rect rect;
  bool active;
  bool visible;
  bool triggered = false;
  double timer = 0;
  double rotation = 0;
  final Offset origin;

  EntityKind get kind => definition.kind;
  bool get isSolid {
    return active &&
        switch (kind) {
          EntityKind.platform ||
          EntityKind.fallingPlatform ||
          EntityKind.disappearingPlatform ||
          EntityKind.fakePlatform => true,
          _ => false,
        };
  }

  bool get isHazard {
    return active &&
        switch (kind) {
          EntityKind.spike ||
          EntityKind.hiddenSpike ||
          EntityKind.movingSpike ||
          EntityKind.saw ||
          EntityKind.fakeDoor => true,
          _ => false,
        };
  }

  bool get isDoor => active && kind == EntityKind.door;

  void update(double dt) {
    if (!active) return;
    rotation += dt * 5.2;

    if (kind == EntityKind.movingSpike || kind == EntityKind.saw) {
      final move = definition.moveBy;
      if (move != Offset.zero && definition.speed > 0) {
        timer += dt * definition.speed;
        final t = (math.sin(timer) + 1) * 0.5;
        final position = origin + move * t;
        rect = Rect.fromLTWH(position.dx, position.dy, rect.width, rect.height);
      }
    }

    if (triggered && kind == EntityKind.fallingPlatform) {
      timer += dt;
      if (timer >= definition.delay) {
        rect = rect.translate(0, 460 * dt);
      }
    }

    if (triggered && kind == EntityKind.disappearingPlatform) {
      timer += dt;
      if (timer >= definition.delay) {
        active = false;
        visible = false;
      }
    }
  }
}
