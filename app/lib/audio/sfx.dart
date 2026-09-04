import 'package:flame_audio/flame_audio.dart';

/// Tiny 8-bit sound effects. Plays are fire-and-forget and never throw into
/// the UI (async errors — e.g. no audio device in tests — are swallowed).
/// Set [enabled] to false in tests to avoid touching the audio platform.
class Sfx {
  Sfx._();

  static bool enabled = true;

  static void _play(String file, {double volume = 1}) {
    if (!enabled) return;
    FlameAudio.play(file, volume: volume).then((_) {}, onError: (_, _) {});
  }

  static void tap() => _play('tap.wav', volume: 0.5);
  static void hit() => _play('hit.wav', volume: 0.6);
  static void buy() => _play('buy.wav', volume: 0.7);
  static void win() => _play('win.wav', volume: 0.8);
  static void lose() => _play('lose.wav', volume: 0.8);
}
