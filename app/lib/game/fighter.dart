import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A side-view pixel fighter: idle loop that plays a one-shot swing on demand
/// and can flash white when hit. Crisp pixels (no anti-aliasing / linear
/// filtering). Optionally horizontally flipped and colour-tinted.
class Fighter extends SpriteAnimationComponent {
  Fighter({
    required this.idleAnim,
    required this.swingAnim,
    this.flip = false,
    this.baseTint,
    super.size,
    super.position,
  }) : super(animation: idleAnim, anchor: Anchor.bottomCenter) {
    _applyPaint();
  }

  final SpriteAnimation idleAnim;
  final SpriteAnimation swingAnim;
  final bool flip;
  final Color? baseTint;

  double _flash = 0;

  static const Color _white = Color(0xFFFFFFFF);

  void _applyPaint({bool hit = false}) {
    paint
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;
    if (hit) {
      paint.colorFilter = const ColorFilter.mode(_white, BlendMode.srcATop);
    } else if (baseTint != null) {
      paint.colorFilter = ColorFilter.mode(baseTint!, BlendMode.modulate);
    } else {
      paint.colorFilter = null;
    }
  }

  @override
  Future<void> onLoad() async {
    if (flip) flipHorizontally();
  }

  /// Play the one-shot attack swing, then return to idle.
  void swing() {
    animation = swingAnim;
    animationTicker
      ?..reset()
      ..onComplete = () => animation = idleAnim;
  }

  /// Briefly flash white to signal a hit.
  void flash() {
    _flash = 0.12;
    _applyPaint(hit: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flash > 0) {
      _flash -= dt;
      if (_flash <= 0) _applyPaint();
    }
  }
}
