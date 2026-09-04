import 'game_hero.dart';
import 'upgrade.dart';

class GameSave {
  final double gold;
  final double totalEarned;
  final double incomePerSecond;
  final List<GameHero> heroes;
  final List<Upgrade> upgrades;
  final DateTime lastSaveTime;
  final DateTime lastPlayTime;

  GameSave({
    required this.gold,
    required this.totalEarned,
    required this.incomePerSecond,
    required this.heroes,
    required this.upgrades,
    required this.lastSaveTime,
    required this.lastPlayTime,
  });

  /// Calculate offline earnings based on time elapsed
  double calculateOfflineEarnings() {
    final now = DateTime.now();
    final elapsedSeconds = now.difference(lastPlayTime).inSeconds;
    return incomePerSecond * elapsedSeconds;
  }

  GameSave copyWith({
    double? gold,
    double? totalEarned,
    double? incomePerSecond,
    List<GameHero>? heroes,
    List<Upgrade>? upgrades,
    DateTime? lastSaveTime,
    DateTime? lastPlayTime,
  }) {
    return GameSave(
      gold: gold ?? this.gold,
      totalEarned: totalEarned ?? this.totalEarned,
      incomePerSecond: incomePerSecond ?? this.incomePerSecond,
      heroes: heroes ?? this.heroes,
      upgrades: upgrades ?? this.upgrades,
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
      lastPlayTime: lastPlayTime ?? this.lastPlayTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gold': gold,
      'totalEarned': totalEarned,
      'incomePerSecond': incomePerSecond,
      'heroes': heroes.map((h) => h.toJson()).toList(),
      'upgrades': upgrades.map((u) => u.toJson()).toList(),
      'lastSaveTime': lastSaveTime.toIso8601String(),
      'lastPlayTime': lastPlayTime.toIso8601String(),
    };
  }

  factory GameSave.fromJson(Map<String, dynamic> json) {
    return GameSave(
      gold: (json['gold'] as num).toDouble(),
      totalEarned: (json['totalEarned'] as num).toDouble(),
      incomePerSecond: (json['incomePerSecond'] as num).toDouble(),
      heroes: (json['heroes'] as List<dynamic>)
          .map((h) => GameHero.fromJson(h as Map<String, dynamic>))
          .toList(),
      upgrades: (json['upgrades'] as List<dynamic>)
          .map((u) => Upgrade.fromJson(u as Map<String, dynamic>))
          .toList(),
      lastSaveTime: DateTime.parse(json['lastSaveTime'] as String),
      lastPlayTime: DateTime.parse(json['lastPlayTime'] as String),
    );
  }

  static GameSave createDefault() {
    final now = DateTime.now();
    return GameSave(
      gold: 0,
      totalEarned: 0,
      incomePerSecond: 1.0,
      heroes: [
        GameHero(
          id: 1,
          name: 'Spark',
          level: 1,
          cost: 10,
          damagePerTap: 1.0,
          unlocked: true,
        ),
      ],
      upgrades: [
        Upgrade(
          id: 1,
          name: 'Income Multiplier',
          description: 'Increase \$/sec by 15%',
          costPerLevel: 5,
          multiplier: 1.15,
        ),
        Upgrade(
          id: 2,
          name: 'Tap Power',
          description: 'Increase tap damage by 10%',
          costPerLevel: 10,
          multiplier: 1.10,
        ),
      ],
      lastSaveTime: now,
      lastPlayTime: now,
    );
  }
}
