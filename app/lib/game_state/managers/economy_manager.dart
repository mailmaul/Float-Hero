import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_save.dart';
import '../models/game_hero.dart';
import '../models/upgrade.dart';
class EconomyManager {
  late GameSave _state;
  final List<VoidCallback> _listeners = [];
  Timer? _incomeTimer;

  EconomyManager(GameSave initialState) {
    _state = initialState;
  }

  // Getters
  GameSave get state => _state;
  double get gold => _state.gold;
  double get incomePerSecond => _state.incomePerSecond;
  List<GameHero> get heroes => _state.heroes;
  List<Upgrade> get upgrades => _state.upgrades;

  // State management
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

  /// Start passive income generation
  void startIncomeLoop() {
    _incomeTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _generatePassiveIncome();
    });
  }

  void stopIncomeLoop() {
    _incomeTimer?.cancel();
  }

  /// Generate passive income (called every 100ms)
  void _generatePassiveIncome() {
    final incomeTick = _state.incomePerSecond / 10; // 100ms = 1/10th second
    _state = _state.copyWith(
      gold: _state.gold + incomeTick,
      totalEarned: _state.totalEarned + incomeTick,
      lastPlayTime: DateTime.now(),
    );
    _notifyListeners();
  }

  /// Handle tap income (1.5x multiplier on passive income)
  void onTap() {
    final tapIncome = _state.incomePerSecond * 1.5;
    _state = _state.copyWith(
      gold: _state.gold + tapIncome,
      totalEarned: _state.totalEarned + tapIncome,
      lastPlayTime: DateTime.now(),
    );
    _notifyListeners();
  }

  /// Purchase a hero
  bool purchaseHero(int heroId) {
    final heroIndex = _state.heroes.indexWhere((h) => h.id == heroId);
    if (heroIndex == -1) return false;

    final hero = _state.heroes[heroIndex];
    if (_state.gold < hero.cost || hero.unlocked) return false;

    final updatedHero = hero.copyWith(unlocked: true);
    final updatedHeroes = List<GameHero>.from(_state.heroes);
    updatedHeroes[heroIndex] = updatedHero;

    // Unlock bonus: +5% income
    final newIncome = _state.incomePerSecond * 1.05;

    _state = _state.copyWith(
      gold: _state.gold - hero.cost,
      incomePerSecond: newIncome,
      heroes: updatedHeroes,
      lastPlayTime: DateTime.now(),
    );
    _notifyListeners();
    return true;
  }

  /// Purchase an upgrade level
  bool purchaseUpgrade(int upgradeId) {
    final upgradeIndex = _state.upgrades.indexWhere((u) => u.id == upgradeId);
    if (upgradeIndex == -1) return false;

    final upgrade = _state.upgrades[upgradeIndex];
    if (_state.gold < upgrade.nextCost) return false;

    final updatedUpgrade = upgrade.copyWith(
      currentLevel: upgrade.currentLevel + 1,
    );
    final updatedUpgrades = List<Upgrade>.from(_state.upgrades);
    updatedUpgrades[upgradeIndex] = updatedUpgrade;

    // Apply income multiplier
    final newIncome = _state.incomePerSecond * upgrade.multiplier;

    _state = _state.copyWith(
      gold: _state.gold - upgrade.nextCost,
      incomePerSecond: newIncome,
      upgrades: updatedUpgrades,
      lastPlayTime: DateTime.now(),
    );
    _notifyListeners();
    return true;
  }

  /// Reload game state (e.g., from database)
  void loadState(GameSave newState) {
    _state = newState;
    _notifyListeners();
  }

  /// Add offline earnings on app relaunch
  void applyOfflineEarnings() {
    final offlineEarnings = _state.calculateOfflineEarnings();
    _state = _state.copyWith(
      gold: _state.gold + offlineEarnings,
      totalEarned: _state.totalEarned + offlineEarnings,
      lastPlayTime: DateTime.now(),
    );
    _notifyListeners();
  }

  void dispose() {
    stopIncomeLoop();
    _listeners.clear();
  }
}
