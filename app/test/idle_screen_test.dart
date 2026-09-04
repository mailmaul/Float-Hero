import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:float_hero/game_state/managers/economy_manager.dart';
import 'package:float_hero/game_state/managers/run_manager.dart';
import 'package:float_hero/game_state/models/game_save.dart';
import 'package:float_hero/game_state/services/persistence_service.dart';
import 'package:float_hero/ui/screens/idle_screen.dart';
import 'package:float_hero/audio/sfx.dart';

void main() {
  testWidgets('IdleScreen embeds the Flame scene and TAP grants gold',
      (tester) async {
    Sfx.enabled = false;
    final economy = EconomyManager(GameSave.createDefault()); // income loop off
    final run = RunManager();

    await tester.pumpWidget(
      MaterialApp(
        home: IdleScreen(
          economyManager: economy,
          runManager: run,
          persistenceService: PersistenceService(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byWidgetPredicate((w) => w is GameWidget), findsOneWidget);
    expect(economy.gold, 0);

    await tester.tap(find.text('TAP!'));
    await tester.pump(const Duration(milliseconds: 16));

    // Default income 1.0 * tapMultiplier 1.5.
    expect(economy.gold, closeTo(1.5, 1e-9));

    await tester.pumpWidget(const SizedBox());
    economy.dispose();
    run.dispose();
  });
}
