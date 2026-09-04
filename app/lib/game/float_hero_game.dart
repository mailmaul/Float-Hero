import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game_state/managers/economy_manager.dart';
import '../game_state/services/persistence_service.dart';

class FloatHeroGame extends Game {
  late EconomyManager economyManager;
  late PersistenceService persistenceService;
  bool isInitialized = false;

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  Future<void> initialize() async {
    if (isInitialized) return;

    // Initialize persistence
    persistenceService = PersistenceService();
    final save = await persistenceService.initialize();

    // Apply offline earnings
    final updatedSave = save.copyWith(
      gold: save.gold + save.calculateOfflineEarnings(),
      lastPlayTime: DateTime.now(),
    );

    // Initialize economy manager
    economyManager = EconomyManager(updatedSave);
    economyManager.startIncomeLoop();

    // Start persistence
    persistenceService.startAutoSave();

    isInitialized = true;
  }

  @override
  void render(Canvas canvas) {
    // Game rendering handled by Flutter UI layer
  }

  @override
  void update(double dt) {
    // Game logic handled by managers
  }

  @override
  void onRemove() {
    economyManager.dispose();
    persistenceService.stopAutoSave();
    super.onRemove();
  }
}
