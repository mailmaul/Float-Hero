import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/run_state.dart';
import '../models/game_hero.dart';

class RunManager extends ChangeNotifier {
  RunState? _runState;
  Timer? _combatTimer;

  static const double _heroAttackDamage = 5.0;
  static const Duration _combatTickDuration = Duration(milliseconds: 500);
  static const int maxWaves = 5;

  RunState? get runState => _runState;
  bool get isRunActive => _runState?.isActive ?? false;

  /// Start a new roguelike run.
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
    notifyListeners();
  }

  /// Generate a wave of enemies.
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

  /// Hero attacks the first alive enemy.
  void heroAttack() {
    final run = _runState;
    if (run == null || !run.isActive || run.enemies.isEmpty) return;

    final target = run.enemies.first;
    final newHealth =
        (target.health - _heroAttackDamage).clamp(0.0, target.maxHealth).toDouble();

    final updatedEnemies = List<Enemy>.from(run.enemies);
    updatedEnemies[0] = target.copyWith(health: newHealth);

    // Remove dead enemies and collect loot.
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

    var waveNumber = run.waveNumber;
    if (updatedEnemies.isEmpty) {
      if (waveNumber < maxWaves) {
        // Advance to the next wave.
        waveNumber += 1;
        updatedEnemies.addAll(_generateWave(waveNumber));
      } else {
        // Final wave cleared: victory.
        _runState = run.copyWith(
          enemies: updatedEnemies,
          goldEarned: goldEarned,
          xpEarned: xpEarned,
        );
        endRun(victory: true);
        return;
      }
    }

    _runState = run.copyWith(
      enemies: updatedEnemies,
      goldEarned: goldEarned,
      xpEarned: xpEarned,
      waveNumber: waveNumber,
    );
    notifyListeners();
  }

  /// Start auto-attack loop (enemies attack hero).
  void _startCombatLoop() {
    _combatTimer = Timer.periodic(_combatTickDuration, (_) {
      final run = _runState;
      if (run == null || !run.isActive || run.enemies.isEmpty) return;

      final totalDamage =
          run.enemies.fold<double>(0, (sum, enemy) => sum + enemy.attackDamage);
      final newHeroHealth =
          (run.heroHealth - totalDamage).clamp(0.0, run.heroMaxHealth).toDouble();

      _runState = run.copyWith(heroHealth: newHeroHealth);

      if (newHeroHealth <= 0) {
        endRun(victory: false);
      } else {
        notifyListeners();
      }
    });
  }

  /// End the run, recording whether the hero won.
  void endRun({required bool victory}) {
    final run = _runState;
    if (run == null) return;

    _combatTimer?.cancel();
    _combatTimer = null;

    _runState = run.copyWith(isActive: false, victory: victory);
    notifyListeners();
  }

  /// Get run summary for return to idle.
  Map<String, dynamic> getRunSummary() {
    final run = _runState;
    if (run == null) return {};
    return {
      'gold': run.goldEarned,
      'xp': run.xpEarned,
      'waves': run.waveNumber,
      'victory': run.victory,
    };
  }

  @override
  void dispose() {
    _combatTimer?.cancel();
    _combatTimer = null;
    super.dispose();
  }
}
