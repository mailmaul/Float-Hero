import 'package:flutter/material.dart';
import '../../game_state/managers/economy_manager.dart';
import '../../game_state/managers/run_manager.dart';
import '../../game_state/services/persistence_service.dart';
import 'shop_screen.dart';
import 'run_screen.dart';

class IdleScreen extends StatefulWidget {
  final EconomyManager economyManager;
  final RunManager runManager;
  final PersistenceService persistenceService;

  const IdleScreen({
    super.key,
    required this.economyManager,
    required this.runManager,
    required this.persistenceService,
  });

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> {
  EconomyManager get economyManager => widget.economyManager;
  RunManager get runManager => widget.runManager;

  void _startRun() {
    if (economyManager.heroes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No heroes available!')),
      );
      return;
    }

    // Select first unlocked hero (or first hero).
    final hero = economyManager.heroes.firstWhere(
      (h) => h.unlocked,
      orElse: () => economyManager.heroes.first,
    );

    runManager.startRun(hero);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RunScreen(
          runManager: runManager,
          onRunEnd: _onRunEnd,
        ),
      ),
    );
  }

  void _onRunEnd() {
    if (!mounted) return;

    final summary = runManager.getRunSummary();
    final gold = (summary['gold'] as num?)?.toDouble() ?? 0;
    final victory = summary['victory'] as bool? ?? false;

    economyManager.addRunRewards(gold);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          victory
              ? 'Victory! Earned ${gold.toStringAsFixed(0)} Gold'
              : 'Defeated. Earned ${gold.toStringAsFixed(0)} Gold',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Float Hero'),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Income display — rebuilds only on economy changes.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListenableBuilder(
                listenable: economyManager,
                builder: (context, _) {
                  final state = economyManager.state;
                  return Column(
                    children: [
                      Text(
                        'Gold: ${state.gold.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${state.incomePerSecond.toStringAsFixed(2)}/sec',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Hero display (placeholder).
            Expanded(
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[400],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan, width: 2),
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 60,
                    color: Colors.yellow,
                  ),
                ),
              ),
            ),

            // Tap button.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                onPressed: economyManager.onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'TAP!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Action buttons.
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ShopScreen(
                            economyManager: economyManager,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'SHOP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _startRun,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'RUN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
