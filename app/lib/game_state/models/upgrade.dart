class Upgrade {
  final int id;
  final String name;
  final String description;
  final int costPerLevel;
  final double multiplier; // e.g., 1.15x per level
  final int currentLevel;

  /// When true the [multiplier] is applied to tap gold; otherwise to
  /// passive income per second.
  final bool affectsTap;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.costPerLevel,
    required this.multiplier,
    this.currentLevel = 0,
    this.affectsTap = false,
  });

  int get nextCost => costPerLevel * (currentLevel + 1);

  Upgrade copyWith({
    int? id,
    String? name,
    String? description,
    int? costPerLevel,
    double? multiplier,
    int? currentLevel,
    bool? affectsTap,
  }) {
    return Upgrade(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      costPerLevel: costPerLevel ?? this.costPerLevel,
      multiplier: multiplier ?? this.multiplier,
      currentLevel: currentLevel ?? this.currentLevel,
      affectsTap: affectsTap ?? this.affectsTap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'costPerLevel': costPerLevel,
      'multiplier': multiplier,
      'currentLevel': currentLevel,
      'affectsTap': affectsTap,
    };
  }

  factory Upgrade.fromJson(Map<String, dynamic> json) {
    return Upgrade(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      costPerLevel: json['costPerLevel'] as int,
      multiplier: (json['multiplier'] as num).toDouble(),
      currentLevel: json['currentLevel'] as int? ?? 0,
      affectsTap: json['affectsTap'] as bool? ?? false,
    );
  }
}
