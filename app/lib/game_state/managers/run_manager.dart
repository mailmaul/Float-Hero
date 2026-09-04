import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/run_state.dart';
import '../models/game_hero.dart';

class RunManager {
  RunState? _runState;
  final List<VoidCallback> _listeners = [];
  Timer? _combatTimer;
  static const double _heroAttackDamage = 5.0;
  static const Duration _combatTickDuration = Duration(milliseconds: 500);

  RunState? get runState => _runState;
  bool get isRunActive => _runState?.isActive ?? false;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Start a new roguelike run
  void startRun(GameHero hero) {
    final maxHealth = 50.0 + (hero.level * 5);
    _runState = RunState(
      isActive: true,
      selectedHero: hero,
      heroHealth: maxHealth,
      heroMaxHealth: maxHealth,
      enemies: _generateWave(1),
      waveNumber: 1,
      goldEarned: 0,
      xpEarned: 0,
      startTime: DateTime.now(),
    );
    _startCombatLoop();
    _notifyListeners();
  }

  /// Generate a wave of enemies
  List<Enemy> _generateWave(int waveNumber) {
    final enemyCount = 1 + (waveNumber ~/ 2);
    final baseHealth = 10.0 + (waveNumber * 5);

    return List.generate(enemyCount, (index) {
      return Enemy(
        id: index,
        name: 'Enemy ${index + 1}',
        health: baseHealth,
        maxHealth: baseHealth,
        attackDamage: 3.0 + (waveNumber * 0.5),
        goldReward: 10 + (waveNumber * 5),
        xpReward: 5 + (waveNumber * 2),
      );
    });
  }

  /// Hero attacks the first alive enemy
  void heroAttack() {
    if (_runState == null || !isRunActive) return;

    final run = _runState!;
    if (run.enemies.isEmpty) return;

    final targetIndex = 0;
    final target = run.enemies[targetIndex];
    final newHealth = (target.health - _heroAttackDamage).clamp(0.0, target.maxHealth).toDouble();

    final updatedEnemies = List<Enemy>.from(run.enemies);
    updatedEnemies[targetIndex] = target.copyWith(health: newHealth);

    // Remove dead enemies and collect loot
    var goldEarned = run.goldEarned;
    var xpEarned = run.xpEarned;

    updatedEnemies.removeWhere((enemy) {
      if (enemy.health <= 0) {
        goldEarned += enemy.goldReward;
        xpEarned += enemy.xpReward;
        return true;
      }
      return false;
    });

    // Wave completed, spawn next wave
    if (updatedEnemies.isEmpty && run.waveNumber < 5) {
      updatedEnemies.addAll(_generateWave(run.waveNumber + 1));
    }

    _runState = run.copyWith(
      enemies: updatedEnemies,
      goldEarned: goldEarned,
      xpEarned: xpEarned,
      waveNumber: updatedEnemies.isEmpty ? run.waveNumber : run.waveNumber,
    );

    _notifyListeners();
  }

  /// Start auto-attack loop (enemies attack hero)
  void _startCombatLoop() {
    _combatTimer = Timer.periodic(_combatTickDuration, (_) {
      if (_runState == null || !isRunActive) return;

      final run = _runState!;

      // Enemies attack
      if (run.enemies.isNotEmpty) {
        final totalDamage = run.enemies
            .fold<double>(0, (sum, enemy) => sum + enemy.attackDamage);

        var newHeroHealth = (run.heroHealth - totalDamage).clamp(0.0, run.heroMaxHealth).toDouble();

        _runState = run.copyWith(heroHealth: newHeroHealth);

        // Check if hero is dead
        if (newHeroHealth <= 0) {
          endRun(victory: false);
        } else {
          _notifyListeners();
        }
      }
    });
  }

  /// End the run (victory or defeat)
  void endRun({required bool victory}) {
    if (_runState == null) return;

    _combatTimer?.cancel();

    final run = _runState!;

    _runState = run.copyWith(isActive: false);
    _notifyListeners();

    // Return to idle screen (handled by calling code)
  }

  /// Get run summary for return to idle
  Map<String, dynamic> getRunSummary() {
    if (_runState == null) return {};

    return {
      'gold': _runState!.goldEarned,
      'xp': _runState!.xpEarned,
      'waves': _runState!.waveNumber,
      'victory': _runState!.allEnemiesDead,
    };
  }

  void dispose() {
    _combatTimer?.cancel();
    _listeners.clear();
  }
}
