import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'fighter.dart';
import 'pixel_game.dart';

/// Flat 2D orthographic side-view scene rendered with Flame: a cheerful field
/// where the hero spars with a rival. Sprites come from the CC0 "PixelKnight"
/// sheet (48x48 frames, 4 columns x 7 rows).
class FloatHeroGame extends PixelGame {
  static const double _frame = 48;
  static const Color _sky = Color(0xFFAEE7FF);
  static const Color _grass = Color(0xFF7BD16A);
  static const Color _grassDark = Color(0xFF57B84A);
  static const Color _rivalTint = Color(0xFFFF8080);

  late final Fighter _hero;
  late final Fighter _rival;
  late final RectangleComponent _ground;
  late final RectangleComponent _grassLine;

  @override
  Color backgroundColor() => _sky;

  @override
  Future<void> onLoad() async {
    final image = await images.load('knight.png');
    final sheet = SpriteSheet(image: image, srcSize: Vector2.all(_frame));
    final idle = sheet.createAnimation(row: 0, stepTime: 0.18, to: 4);
    final swing =
        sheet.createAnimation(row: 1, stepTime: 0.08, to: 4, loop: false);

    _ground = RectangleComponent(paint: Paint()..color = _grass);
    _grassLine = RectangleComponent(paint: Paint()..color = _grassDark);
    _hero = Fighter(idleAnim: idle, swingAnim: swing);
    _rival = Fighter(
      idleAnim: idle,
      swingAnim: swing,
      flip: true,
      baseTint: _rivalTint,
    );

    addAll([_ground, _grassLine, _rival, _hero]);
    _layout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _layout();
  }

  void _layout() {
    final groundTop = size.y * 0.70;
    _ground
      ..position = Vector2(0, groundTop)
      ..size = Vector2(size.x, size.y - groundTop);
    _grassLine
      ..position = Vector2(0, groundTop)
      ..size = Vector2(size.x, (size.y * 0.02).clamp(2, 6));

    final fighter = Vector2.all(size.y * 0.5);
    _hero
      ..size = fighter
      ..position = Vector2(size.x * 0.30, groundTop + fighter.y * 0.14);
    _rival
      ..size = fighter
      ..position = Vector2(size.x * 0.70, groundTop + fighter.y * 0.14);
  }

  /// Play the hero's attack swing with juice (called on tap).
  void heroAttack({double gold = 0}) {
    if (!isLoaded) return;
    _hero.swing();
    _rival.flash();
    shake(0.16, 5);
    if (gold > 0) {
      spawnPop(
        '+${gold.toStringAsFixed(0)}',
        Vector2(_hero.position.x, _hero.position.y - _hero.size.y),
        color: const Color(0xFFFFE05A),
      );
    }
  }
}
