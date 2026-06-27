import 'dart:convert';
import 'dart:ui';

enum EntityKind {
  platform,
  fallingPlatform,
  disappearingPlatform,
  fakePlatform,
  spike,
  hiddenSpike,
  movingSpike,
  saw,
  door,
  fakeDoor,
  trigger,
}

enum TriggerAction {
  vanishTarget,
  moveDoor,
  revealTarget,
  reverseControls,
  fakeVictory,
  surpriseSpike,
  dropTarget,
  shiftTarget,
  killPlayer,
}

class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.name,
    required this.size,
    required this.spawn,
    required this.doorId,
    required this.reverseControls,
    required this.entities,
  });

  final int id;
  final String name;
  final Size size;
  final Offset spawn;
  final String doorId;
  final bool reverseControls;
  final List<EntityDefinition> entities;

  factory LevelDefinition.fromJsonText(String text) {
    final map = jsonDecode(text) as Map<String, dynamic>;
    final size = map['size'] as Map<String, dynamic>;
    final spawn = map['spawn'] as Map<String, dynamic>;
    return LevelDefinition(
      id: map['id'] as int,
      name: map['name'] as String,
      size: Size((size['w'] as num).toDouble(), (size['h'] as num).toDouble()),
      spawn: Offset(
        (spawn['x'] as num).toDouble(),
        (spawn['y'] as num).toDouble(),
      ),
      doorId: map['doorId'] as String,
      reverseControls: map['reverseControls'] as bool? ?? false,
      entities: (map['entities'] as List<dynamic>)
          .map((item) => EntityDefinition.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class EntityDefinition {
  const EntityDefinition({
    required this.id,
    required this.kind,
    required this.rect,
    this.moveBy = Offset.zero,
    this.speed = 0,
    this.delay = 0,
    this.triggerAction,
    this.targetId,
    this.once = true,
  });

  final String id;
  final EntityKind kind;
  final Rect rect;
  final Offset moveBy;
  final double speed;
  final double delay;
  final TriggerAction? triggerAction;
  final String? targetId;
  final bool once;

  factory EntityDefinition.fromMap(Map<String, dynamic> map) {
    final rect = map['rect'] as Map<String, dynamic>;
    final moveBy = map['moveBy'] as Map<String, dynamic>?;
    return EntityDefinition(
      id: map['id'] as String,
      kind: EntityKind.values.byName(map['kind'] as String),
      rect: Rect.fromLTWH(
        (rect['x'] as num).toDouble(),
        (rect['y'] as num).toDouble(),
        (rect['w'] as num).toDouble(),
        (rect['h'] as num).toDouble(),
      ),
      moveBy: moveBy == null
          ? Offset.zero
          : Offset(
              (moveBy['x'] as num).toDouble(),
              (moveBy['y'] as num).toDouble(),
            ),
      speed: (map['speed'] as num?)?.toDouble() ?? 0,
      delay: (map['delay'] as num?)?.toDouble() ?? 0,
      triggerAction: map['triggerAction'] == null
          ? null
          : TriggerAction.values.byName(map['triggerAction'] as String),
      targetId: map['targetId'] as String?,
      once: map['once'] as bool? ?? true,
    );
  }
}
