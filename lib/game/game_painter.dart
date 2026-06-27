import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/level_definition.dart';
import 'game_entity.dart';
import 'game_world.dart';

class GamePainter extends CustomPainter {
  GamePainter(this.world);

  final GameWorld world;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);

    final scale = math.min(
      size.width / world.level.size.width,
      size.height / world.level.size.height,
    );
    final offset = Offset(
      (size.width - world.level.size.width * scale) * 0.5,
      (size.height - world.level.size.height * scale) * 0.5,
    );
    final shakeOffset = world.shake <= 0
        ? Offset.zero
        : Offset(
            math.sin(world.player.animationTime * 80) * world.shake,
            math.cos(world.player.animationTime * 74) * world.shake,
          );
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    canvas.clipRect(Offset.zero & world.level.size);
    canvas.translate(
      -world.camera.dx + shakeOffset.dx,
      -world.camera.dy + shakeOffset.dy,
    );
    _paintWorldBands(canvas);
    for (final entity in world.entities) {
      _paintEntity(canvas, entity);
    }
    _paintParticles(canvas);
    _paintPlayer(canvas);
    canvas.restore();
  }

  void _paintBackground(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff221001), Color(0xffc46a00), Color(0xffffb423)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22),
      Paint()..color = const Color(0x66430f00),
    );
  }

  void _paintWorldBands(Canvas canvas) {
    final paint = Paint()..color = const Color(0xff1a0b00);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        world.level.size.height - 18,
        world.level.size.width,
        18,
      ),
      paint,
    );
  }

  void _paintEntity(Canvas canvas, GameEntity entity) {
    if (!entity.visible ||
        !entity.active ||
        entity.kind == EntityKind.trigger) {
      return;
    }
    switch (entity.kind) {
      case EntityKind.platform:
        _drawPlatform(
          canvas,
          entity.rect,
          const Color(0xff8a4300),
          const Color(0xffffa51f),
        );
      case EntityKind.fallingPlatform:
        _drawPlatform(
          canvas,
          entity.rect,
          const Color(0xff5a2700),
          const Color(0xffffe066),
        );
      case EntityKind.disappearingPlatform:
        _drawPlatform(
          canvas,
          entity.rect,
          const Color(0xff704000),
          const Color(0xffff477e),
        );
      case EntityKind.fakePlatform:
        _drawPlatform(
          canvas,
          entity.rect,
          const Color(0xff8a4300),
          const Color(0xffffa51f),
        );
      case EntityKind.spike || EntityKind.hiddenSpike || EntityKind.movingSpike:
        _drawSpikes(canvas, entity.rect);
      case EntityKind.saw:
        _drawSaw(canvas, entity);
      case EntityKind.door:
        _drawDoor(canvas, entity.rect, real: true);
      case EntityKind.fakeDoor:
        _drawDoor(canvas, entity.rect, real: false);
      case EntityKind.trigger:
        break;
    }
  }

  void _drawPlatform(Canvas canvas, Rect rect, Color body, Color edge) {
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(r, Paint()..color = body);
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, 7),
      Paint()..color = edge,
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.bottom - 3, rect.width, 3),
      Paint()..color = const Color(0xff0b1222),
    );
  }

  void _drawSpikes(Canvas canvas, Rect rect) {
    final paint = Paint()..color = const Color(0xff070707);
    final stroke = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const count = 4;
    final width = rect.width / count;
    for (var i = 0; i < count; i++) {
      final path = Path()
        ..moveTo(rect.left + i * width, rect.bottom)
        ..lineTo(rect.left + i * width + width * 0.5, rect.top)
        ..lineTo(rect.left + (i + 1) * width, rect.bottom)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, stroke);
    }
  }

  void _drawSaw(Canvas canvas, GameEntity entity) {
    final center = entity.rect.center;
    final radius = entity.rect.width * 0.5;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(entity.rotation);
    final path = Path();
    for (var i = 0; i < 18; i++) {
      final r = i.isEven ? radius : radius * 0.72;
      final angle = i / 18 * math.pi * 2;
      final point = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xffd8e2f0));
    canvas.drawCircle(
      Offset.zero,
      radius * 0.28,
      Paint()..color = const Color(0xff0f172a),
    );
    canvas.restore();
  }

  void _drawDoor(Canvas canvas, Rect rect, {required bool real}) {
    final body = Paint()
      ..color = real ? const Color(0xff4a351f) : const Color(0xff361100);
    final trim = Paint()
      ..color = real ? const Color(0xffffc15a) : const Color(0xffff477e);
    final shade = Paint()..color = const Color(0xff0f0a05);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(26)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(22)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = trim.color,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left + 8,
        rect.top + 9,
        rect.width - 16,
        rect.height - 18,
      ),
      shade,
    );
    canvas.drawCircle(Offset(rect.right - 16, rect.center.dy), 4, trim);
  }

  void _paintPlayer(Canvas canvas) {
    final rect = world.player.rect;
    if (world.state == PlayState.dead) {
      final scale = (1 - world.player.deathTimer).clamp(0.15, 1.0);
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.scale(scale);
      _drawPlayerBody(
        canvas,
        Rect.fromCenter(
          center: Offset.zero,
          width: rect.width,
          height: rect.height,
        ),
      );
      canvas.restore();
      return;
    }
    _drawPlayerBody(canvas, rect);
  }

  void _drawPlayerBody(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = const Color(0xff050505)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final phase = math.sin(world.player.animationTime * 14);
    final dir = world.player.facingRight ? 1.0 : -1.0;
    final head = Offset(rect.center.dx, rect.top + 11);
    final bodyTop = Offset(rect.center.dx, rect.top + 24);
    final bodyBottom = Offset(rect.center.dx, rect.bottom - 17);
    canvas.drawCircle(head, 11, paint);
    canvas.drawLine(bodyTop, bodyBottom, paint);
    canvas.drawLine(
      Offset(rect.center.dx - 2 * dir, rect.top + 33),
      Offset(rect.center.dx - 14 * dir, rect.top + 43 + phase * 3),
      paint,
    );
    canvas.drawLine(
      Offset(rect.center.dx + 2 * dir, rect.top + 33),
      Offset(rect.center.dx + 13 * dir, rect.top + 43 - phase * 3),
      paint,
    );
    canvas.drawLine(
      bodyBottom,
      Offset(rect.center.dx - 11 * dir, rect.bottom - 2 + phase * 4),
      paint,
    );
    canvas.drawLine(
      bodyBottom,
      Offset(rect.center.dx + 12 * dir, rect.bottom - 2 - phase * 4),
      paint,
    );
  }

  void _paintParticles(Canvas canvas) {
    for (final p in world.particles) {
      final opacity = (1 - p.age / p.life).clamp(0.0, 1.0);
      canvas.drawCircle(
        p.position,
        4 * opacity + 1,
        Paint()..color = p.color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
