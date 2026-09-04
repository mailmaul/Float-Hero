import 'game_hero.dart';

class Enemy {
  final int id;
  final String name;
  final double health;
  final double maxHealth;
  final double attackDamage;
  final int goldReward;
  final int xpReward;

  Enemy({
    required this.id,
    required this.name,
    required this.health,
    required this.maxHealth,
    required this.attackDamage,
    required this.goldReward,
    required this.xpReward,
  });

  Enemy copyWith({
    double? health,
  }) {
    return Enemy(
      id: id,
      name: name,
      health: health ?? this.health,
      maxHealth: maxHealth,
      attackDamage: attackDamage,
      goldReward: goldReward,
      xpReward: xpReward,
    );
  }
}

class RunState {
  final bool isActive;
  final GameHero selectedHero;
  final double heroHealth;
  final double heroMaxHealth;
  final List<Enemy> enemies;
  final int waveNumber;
  final double goldEarned;
  final int xpEarned;
  final DateTime startTime;
  final bool victory;

  RunState({
    required this.isActive,
    required this.selectedHero,
    required this.heroHealth,
    required this.heroMaxHealth,
    required this.enemies,
    required this.waveNumber,
    required this.goldEarned,
    required this.xpEarned,
    required this.startTime,
    this.victory = false,
  });

  bool get heroAlive => heroHealth > 0;
  bool get allEnemiesDead => enemies.isEmpty;

  RunState copyWith({
    bool? isActive,
    GameHero? selectedHero,
    double? heroHealth,
    double? heroMaxHealth,
    List<Enemy>? enemies,
    int? waveNumber,
    double? goldEarned,
    int? xpEarned,
    DateTime? startTime,
    bool? victory,
  }) {
    return RunState(
      isActive: isActive ?? this.isActive,
      selectedHero: selectedHero ?? this.selectedHero,
      heroHealth: heroHealth ?? this.heroHealth,
      heroMaxHealth: heroMaxHealth ?? this.heroMaxHealth,
      enemies: enemies ?? this.enemies,
      waveNumber: waveNumber ?? this.waveNumber,
      goldEarned: goldEarned ?? this.goldEarned,
      xpEarned: xpEarned ?? this.xpEarned,
      startTime: startTime ?? this.startTime,
      victory: victory ?? this.victory,
    );
  }
}
