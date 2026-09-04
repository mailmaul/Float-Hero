import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../game_state/managers/run_manager.dart';
import 'fighter.dart';
import 'pixel_game.dart';

/// Flame side-view battle that renders the [RunManager]'s live run state:
/// the hero on the left facing a row of enemies on the right. Combat logic
/// stays in [RunManager]; this is purely a view that reconciles each frame.
class RunGame extends PixelGame {
  RunGame(this.manager);

  final RunManager manager;

  static const double _frame = 48;
  static const Color _sky = Color(0xFFB9D9C9);
  static const Color _grass = Color(0xFF6FA86A);
  static const Color _grassDark = Color(0xFF4E8A4E);
  static const Color _enemyTint = Color(0xFFFF7A7A);
  static const Color _dmgColor = Color(0xFFFF5555);

  late final SpriteAnimation _idle;
  late final SpriteAnimation _swing;
  late final Fighter _hero;
  final List<_Enemy> _enemies = [];
  final List<double> _prevHp = [];
  late final RectangleComponent _ground;
  late final RectangleComponent _grassLine;
  Vector2 _fighterSize = Vector2.all(64);

  @override
  Color backgroundColor() => _sky;

  @override
  Future<void> onLoad() async {
    final image = await images.load('knight.png');
    final sheet = SpriteSheet(image: image, srcSize: Vector2.all(_frame));
    _idle = sheet.createAnimation(row: 0, stepTime: 0.18, to: 4);
    _swing = sheet.createAnimation(row: 1, stepTime: 0.08, to: 4, loop: false);

    _ground = RectangleComponent(paint: Paint()..color = _grass);
    _grassLine = RectangleComponent(paint: Paint()..color = _grassDark);
    _hero = Fighter(idleAnim: _idle, swingAnim: _swing);

    addAll([_ground, _grassLine, _hero]);
    _layout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _layout();
  }

  double get _groundTop => size.y * 0.70;

  void _layout() {
    _fighterSize = Vector2.all(size.y * 0.46);
    _ground
      ..position = Vector2(0, _groundTop)
      ..size = Vector2(size.x, size.y - _groundTop);
    _grassLine
      ..position = Vector2(0, _groundTop)
      ..size = Vector2(size.x, (size.y * 0.02).clamp(2, 6));
    _hero
      ..size = _fighterSize
      ..position = Vector2(size.x * 0.18, _groundTop + _fighterSize.y * 0.14);
    _positionEnemies();
  }

  void _positionEnemies() {
    final n = _enemies.length;
    for (var i = 0; i < n; i++) {
      final t = n == 1 ? 0.5 : i / (n - 1);
      final x = size.x * (0.55 + 0.35 * t);
      _enemies[i]
        ..size = _fighterSize
        ..position = Vector2(x, _groundTop + _fighterSize.y * 0.14);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;
    final run = manager.runState;
    if (run == null) return;
    final enemies = run.enemies;

    // Reconcile the number of enemy components to the live wave.
    if (_enemies.length != enemies.length) {
      for (final e in _enemies) {
        e.removeFromParent();
      }
      _enemies.clear();
      _prevHp.clear();
      for (var i = 0; i < enemies.length; i++) {
        final e = _Enemy(idleAnim: _idle, swingAnim: _swing, baseTint: _enemyTint)
          ..size = _fighterSize;
        _enemies.add(e);
        _prevHp.add(enemies[i].health);
        add(e);
      }
      _positionEnemies();
    }

    // Push HP into bars; spawn a damage number where health dropped.
    for (var i = 0; i < _enemies.length && i < enemies.length; i++) {
      final e = enemies[i];
      final frac =
          e.maxHealth <= 0 ? 0.0 : (e.health / e.maxHealth).clamp(0.0, 1.0);
      _enemies[i].setHp(frac.toDouble());

      final dropped = _prevHp[i] - e.health;
      if (dropped > 0.01) {
        final pos = _enemies[i].position;
        spawnPop('-${dropped.toStringAsFixed(0)}',
            Vector2(pos.x, pos.y - _fighterSize.y * 0.8),
            color: _dmgColor);
      }
      _prevHp[i] = e.health;
    }
  }

  /// Play the hero's attack swing with a little shake (called on tap/button).
  void playHeroAttack() {
    if (isLoaded) {
      _hero.swing();
      shake(0.14, 5);
    }
  }
}

/// An enemy fighter with a floating HP bar that flashes when damaged.
class _Enemy extends Fighter {
  _Enemy({
    required super.idleAnim,
    required super.swingAnim,
    required Color baseTint,
  }) : super(flip: true, baseTint: baseTint);

  late final RectangleComponent _hpBack;
  late final RectangleComponent _hpFront;
  double _hp = 1;
  bool _init = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final barWidth = size.x * 0.5;
    final barX = (size.x - barWidth) / 2;
    final barY = size.y * 0.16;
    _hpBack = RectangleComponent(
      position: Vector2(barX, barY),
      size: Vector2(barWidth, size.y * 0.04),
      paint: Paint()..color = const Color(0xFF7A1F1F),
    );
    _hpFront = RectangleComponent(
      position: Vector2(barX, barY),
      size: Vector2(barWidth, size.y * 0.04),
      paint: Paint()..color = const Color(0xFF56D06A),
    );
    addAll([_hpBack, _hpFront]);
    _init = true;
  }

  void setHp(double fraction) {
    if (!_init) {
      _hp = fraction;
      return;
    }
    if (fraction < _hp) flash();
    _hp = fraction;
    _hpFront.size = Vector2(_hpBack.size.x * fraction, _hpBack.size.y);
  }
}
