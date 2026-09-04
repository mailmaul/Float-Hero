import 'package:flutter_test/flutter_test.dart';
import 'package:float_hero/game_state/managers/run_manager.dart';
import 'package:float_hero/game_state/models/game_hero.dart';

GameHero _hero({int level = 1}) => GameHero(
      id: 1,
      name: 'Spark',
      level: level,
      cost: 10,
      damagePerTap: 1,
      unlocked: true,
    );

void main() {
  group('RunManager', () {
    test('startRun initializes wave 1 with health scaled by level', () {
      final m = RunManager();
      m.startRun(_hero(level: 3));

      final run = m.runState!;
      expect(run.isActive, isTrue);
      expect(run.waveNumber, 1);
      expect(run.heroMaxHealth, 65.0); // 50 + 3*5
      expect(run.heroHealth, 65.0);
      expect(run.enemies, isNotEmpty);

      m.dispose(); // cancel combat timer
    });

    test('clearing a wave advances waveNumber and spawns the next wave', () {
      final m = RunManager();
      m.startRun(_hero());
      expect(m.runState!.waveNumber, 1);
      expect(m.runState!.enemies.length, 1); // wave 1 has one enemy

      // Wave 1 enemy has 15 HP; 5 damage per hit -> 3 hits to clear.
      m.heroAttack();
      m.heroAttack();
      m.heroAttack();

      expect(m.runState!.waveNumber, 2);
      expect(m.runState!.enemies.length, 2); // wave 2 has two enemies
      expect(m.isRunActive, isTrue);

      m.dispose();
    });

    test('clearing the final wave ends the run as victory', () {
      final m = RunManager();
      m.startRun(_hero());

      // Attack until the run ends. The combat (enemy) timer never fires in a
      // synchronous test, so the hero cannot die -> guaranteed victory.
      var guard = 0;
      while (m.isRunActive && guard < 1000) {
        m.heroAttack();
        guard++;
      }

      expect(m.isRunActive, isFalse);
      final summary = m.getRunSummary();
      expect(summary['victory'], isTrue);
      expect(summary['waves'], RunManager.maxWaves);
      expect((summary['gold'] as num) > 0, isTrue);

      m.dispose();
    });

    test('endRun(victory: false) records a defeat', () {
      final m = RunManager();
      m.startRun(_hero());
      m.endRun(victory: false);

      expect(m.isRunActive, isFalse);
      expect(m.getRunSummary()['victory'], isFalse);

      m.dispose();
    });

    test('heroAttack is a no-op once the run is over', () {
      final m = RunManager();
      m.startRun(_hero());
      m.endRun(victory: false);
      final goldBefore = m.runState!.goldEarned;

      m.heroAttack();
      expect(m.runState!.goldEarned, goldBefore);

      m.dispose();
    });
  });
}
