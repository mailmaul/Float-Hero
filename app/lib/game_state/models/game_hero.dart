class GameHero {
  final int id;
  final String name;
  final int level;
  final int cost; // Purchase cost in gold
  final double damagePerTap;
  final bool unlocked;

  GameHero({
    required this.id,
    required this.name,
    required this.level,
    required this.cost,
    required this.damagePerTap,
    this.unlocked = false,
  });

  GameHero copyWith({
    int? id,
    String? name,
    int? level,
    int? cost,
    double? damagePerTap,
    bool? unlocked,
  }) {
    return GameHero(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      cost: cost ?? this.cost,
      damagePerTap: damagePerTap ?? this.damagePerTap,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'cost': cost,
      'damagePerTap': damagePerTap,
      'unlocked': unlocked,
    };
  }

  factory GameHero.fromJson(Map<String, dynamic> json) {
    return GameHero(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as int,
      cost: json['cost'] as int,
      damagePerTap: (json['damagePerTap'] as num).toDouble(),
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }
}
