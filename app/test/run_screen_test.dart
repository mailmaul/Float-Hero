import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:float_hero/game_state/managers/run_manager.dart';
import 'package:float_hero/game_state/models/game_hero.dart';
import 'package:float_hero/ui/screens/run_screen.dart';
import 'package:float_hero/audio/sfx.dart';

void main() {
  testWidgets('RunScreen shows the Flame battle and ATTACK damages an enemy',
      (tester) async {
    Sfx.enabled = false;
    final run = RunManager();
    run.startRun(GameHero(
      id: 1,
      name: 'Spark',
      level: 1,
      cost: 10,
      damagePerTap: 1,
      unlocked: true,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: RunScreen(runManager: run, onRunEnd: () {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byWidgetPredicate((w) => w is GameWidget), findsOneWidget);

    final before = run.runState!.enemies.first.health;
    await tester.tap(find.text('ATTACK!'));
    await tester.pump(const Duration(milliseconds: 16));

    expect(run.runState!.enemies.first.health, lessThan(before));

    await tester.pumpWidget(const SizedBox());
    run.dispose();
  });
}
