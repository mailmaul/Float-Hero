import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// Base for the pixel scenes: adds a screen-shake and floating "pop" numbers
/// (damage / gold) shared by the home and battle games.
abstract class PixelGame extends FlameGame {
  final math.Random _rng = math.Random();
  double _shake = 0;
  double _shakeMag = 0;

  /// Trigger a screen shake for [duration] seconds at [magnitude] pixels.
  void shake([double duration = 0.18, double magnitude = 6]) {
    _shake = duration;
    _shakeMag = magnitude;
  }

  /// Spawn a floating text that drifts up and removes itself.
  void spawnPop(String text, Vector2 position,
      {Color color = const Color(0xFFFFFFFF), double rise = 42}) {
    final pop = TextComponent(
      text: text,
      position: position.clone(),
      anchor: Anchor.center,
      priority: 100,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: (size.y * 0.055).clamp(10, 28),
          fontWeight: FontWeight.w900,
          shadows: const [Shadow(color: Color(0xFF000000), offset: Offset(1, 1))],
        ),
      ),
    );
    pop.add(MoveByEffect(Vector2(0, -rise), EffectController(duration: 0.7)));
    pop.add(RemoveEffect(delay: 0.72));
    add(pop);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shake > 0) _shake = math.max(0, _shake - dt);
  }

  @override
  void render(Canvas canvas) {
    if (_shake > 0) {
      final dx = (_rng.nextDouble() * 2 - 1) * _shakeMag;
      final dy = (_rng.nextDouble() * 2 - 1) * _shakeMag;
      canvas.save();
      canvas.translate(dx, dy);
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}
