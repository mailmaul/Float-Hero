import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_save.dart';
import '../models/game_hero.dart';
import '../models/upgrade.dart';

class EconomyManager extends ChangeNotifier {
  GameSave _state;
  Timer? _incomeTimer;

  static const Duration _incomeTick = Duration(milliseconds: 100);

  EconomyManager(GameSave initialState) : _state = initialState;

  // Getters
  GameSave get state => _state;
  double get gold => _state.gold;
  double get incomePerSecond => _state.incomePerSecond;
  List<GameHero> get heroes => _state.heroes;
  List<Upgrade> get upgrades => _state.upgrades;

  /// Start passive income generation.
  void startIncomeLoop() {
    _incomeTimer ??= Timer.periodic(_incomeTick, (_) => _generatePassiveIncome());
  }

  void stopIncomeLoop() {
    _incomeTimer?.cancel();
    _incomeTimer = null;
  }

  /// Generate passive income (called every 100ms).
  void _generatePassiveIncome() {
    final incomeTick = _state.incomePerSecond / 10; // 100ms = 1/10th second
    _state = _state.copyWith(
      gold: _state.gold + incomeTick,
      totalEarned: _state.totalEarned + incomeTick,
      lastPlayTime: DateTime.now(),
    );
    notifyListeners();
  }

  /// Handle tap income (scaled by the save's tap multiplier).
  void onTap() {
    final tapIncome = _state.incomePerSecond * _state.tapMultiplier;
    _state = _state.copyWith(
      gold: _state.gold + tapIncome,
      totalEarned: _state.totalEarned + tapIncome,
      lastPlayTime: DateTime.now(),
    );
    notifyListeners();
  }

  /// Add gold rewards earned from a roguelike run.
  void addRunRewards(double gold) {
    if (gold <= 0) return;
    _state = _state.copyWith(
      gold: _state.gold + gold,
      totalEarned: _state.totalEarned + gold,
      lastPlayTime: DateTime.now(),
    );
    notifyListeners();
  }

  /// Purchase a hero.
  bool purchaseHero(int heroId) {
    final heroIndex = _state.heroes.indexWhere((h) => h.id == heroId);
    if (heroIndex == -1) return false;

    final hero = _state.heroes[heroIndex];
    if (_state.gold < hero.cost || hero.unlocked) return false;

    final updatedHeroes = List<GameHero>.from(_state.heroes);
    updatedHeroes[heroIndex] = hero.copyWith(unlocked: true);

    // Unlock bonus: +5% income
    _state = _state.copyWith(
      gold: _state.gold - hero.cost,
      incomePerSecond: _state.incomePerSecond * 1.05,
      heroes: updatedHeroes,
      lastPlayTime: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  /// Purchase an upgrade level.
  bool purchaseUpgrade(int upgradeId) {
    final upgradeIndex = _state.upgrades.indexWhere((u) => u.id == upgradeId);
    if (upgradeIndex == -1) return false;

    final upgrade = _state.upgrades[upgradeIndex];
    if (_state.gold < upgrade.nextCost) return false;

    final updatedUpgrades = List<Upgrade>.from(_state.upgrades);
    updatedUpgrades[upgradeIndex] = upgrade.copyWith(
      currentLevel: upgrade.currentLevel + 1,
    );

    _state = _state.copyWith(
      gold: _state.gold - upgrade.nextCost,
      // Tap upgrades scale tap gold; the rest scale passive income.
      incomePerSecond: upgrade.affectsTap
          ? _state.incomePerSecond
          : _state.incomePerSecond * upgrade.multiplier,
      tapMultiplier: upgrade.affectsTap
          ? _state.tapMultiplier * upgrade.multiplier
          : _state.tapMultiplier,
      upgrades: updatedUpgrades,
      lastPlayTime: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  /// Replace game state (e.g., reloaded from the database).
  void loadState(GameSave newState) {
    _state = newState;
    notifyListeners();
  }

  /// Add offline earnings on app relaunch.
  void applyOfflineEarnings() {
    final offlineEarnings = _state.calculateOfflineEarnings();
    if (offlineEarnings <= 0) return;
    _state = _state.copyWith(
      gold: _state.gold + offlineEarnings,
      totalEarned: _state.totalEarned + offlineEarnings,
      lastPlayTime: DateTime.now(),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    stopIncomeLoop();
    super.dispose();
  }
}
