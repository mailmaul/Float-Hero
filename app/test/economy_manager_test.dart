import 'package:flutter_test/flutter_test.dart';
import 'package:float_hero/game_state/managers/economy_manager.dart';
import 'package:float_hero/game_state/models/game_save.dart';
import 'package:float_hero/game_state/models/game_hero.dart';
import 'package:float_hero/game_state/models/upgrade.dart';

GameSave _save({
  double gold = 0,
  double incomePerSecond = 1.0,
  double tapMultiplier = 1.5,
  List<GameHero>? heroes,
  List<Upgrade>? upgrades,
}) {
  final now = DateTime.now();
  return GameSave(
    gold: gold,
    totalEarned: 0,
    incomePerSecond: incomePerSecond,
    tapMultiplier: tapMultiplier,
    heroes: heroes ?? const [],
    upgrades: upgrades ?? const [],
    lastSaveTime: now,
    lastPlayTime: now,
  );
}

void main() {
  group('EconomyManager', () {
    test('onTap grants incomePerSecond * tapMultiplier', () {
      final m = EconomyManager(_save(gold: 0, incomePerSecond: 4, tapMultiplier: 1.5));
      m.onTap();
      expect(m.gold, 6.0); // 4 * 1.5
      expect(m.state.totalEarned, 6.0);
    });

    test('addRunRewards adds gold and ignores non-positive amounts', () {
      final m = EconomyManager(_save(gold: 10));
      m.addRunRewards(25);
      expect(m.gold, 35);
      m.addRunRewards(0);
      m.addRunRewards(-5);
      expect(m.gold, 35);
    });

    test('income upgrade scales income only, tap upgrade scales tap only', () {
      final m = EconomyManager(_save(
        gold: 1000,
        incomePerSecond: 10,
        tapMultiplier: 1.5,
        upgrades: [
          Upgrade(
            id: 1,
            name: 'Income',
            description: '',
            costPerLevel: 5,
            multiplier: 1.15,
          ),
          Upgrade(
            id: 2,
            name: 'Tap',
            description: '',
            costPerLevel: 10,
            multiplier: 1.10,
            affectsTap: true,
          ),
        ],
      ));

      expect(m.purchaseUpgrade(1), isTrue);
      expect(m.incomePerSecond, closeTo(11.5, 1e-9)); // 10 * 1.15
      expect(m.state.tapMultiplier, 1.5); // unchanged
      expect(m.gold, 995); // -5

      expect(m.purchaseUpgrade(2), isTrue);
      expect(m.state.tapMultiplier, closeTo(1.65, 1e-9)); // 1.5 * 1.10
      expect(m.incomePerSecond, closeTo(11.5, 1e-9)); // unchanged
      expect(m.gold, 985); // -10
    });

    test('purchaseUpgrade fails when gold is insufficient', () {
      final m = EconomyManager(_save(
        gold: 1,
        upgrades: [
          Upgrade(id: 1, name: 'x', description: '', costPerLevel: 5, multiplier: 1.1),
        ],
      ));
      expect(m.purchaseUpgrade(1), isFalse);
      expect(m.gold, 1);
    });

    test('purchaseHero unlocks a locked hero, applies +5% income, deducts cost',
        () {
      final m = EconomyManager(_save(
        gold: 100,
        incomePerSecond: 10,
        heroes: [
          GameHero(id: 2, name: 'Blaze', level: 1, cost: 40, damagePerTap: 2),
        ],
      ));
      expect(m.purchaseHero(2), isTrue);
      expect(m.heroes.first.unlocked, isTrue);
      expect(m.incomePerSecond, closeTo(10.5, 1e-9));
      expect(m.gold, 60);

      // Already unlocked -> no-op.
      expect(m.purchaseHero(2), isFalse);
    });

    test('offline earnings are capped at maxOfflineSeconds', () {
      final now = DateTime.now();
      final save = GameSave(
        gold: 0,
        totalEarned: 0,
        incomePerSecond: 1.0,
        tapMultiplier: 1.5,
        heroes: const [],
        upgrades: const [],
        lastSaveTime: now,
        lastPlayTime: now.subtract(const Duration(days: 30)),
      );
      final m = EconomyManager(save);
      m.applyOfflineEarnings();
      expect(m.gold, GameSave.maxOfflineSeconds.toDouble());
    });

    test('notifies listeners on state change', () {
      final m = EconomyManager(_save(incomePerSecond: 2));
      var count = 0;
      m.addListener(() => count++);
      m.onTap();
      expect(count, 1);
    });
  });
}
