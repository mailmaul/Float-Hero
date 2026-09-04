import 'package:flutter/material.dart';
import '../../game_state/managers/run_manager.dart';

class RunScreen extends StatefulWidget {
  final RunManager runManager;
  final VoidCallback onRunEnd;

  const RunScreen({
    super.key,
    required this.runManager,
    required this.onRunEnd,
  });

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  late RunManager runManager;

  @override
  void initState() {
    super.initState();
    runManager = widget.runManager;
    runManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    runManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
    if (!runManager.isRunActive) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onRunEnd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = runManager.runState;
    if (run == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        body: const Center(child: Text('No run data')),
      );
    }

    final heroHealthPercent = (run.heroHealth / run.heroMaxHealth).clamp(0.0, 1.0).toDouble();
    final heroHealth = run.heroHealth.toStringAsFixed(0);
    final waveNum = run.waveNumber;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('ROGUELIKE RUN'),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Hero status
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hero: ${run.selectedHero.name} (Lv${run.selectedHero.level})',
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: heroHealthPercent,
                            backgroundColor: Colors.red[900],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              heroHealthPercent > 0.5
                                  ? Colors.greenAccent
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$heroHealth/${run.heroMaxHealth.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Wave info and stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'WAVE',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$waveNum',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'GOLD',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      run.goldEarned.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'XP',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      run.xpEarned.toString(),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Enemies display
          Expanded(
            child: ListView.builder(
              itemCount: run.enemies.length,
              itemBuilder: (context, index) {
                final enemy = run.enemies[index];
                final enemyHealthPercent = (enemy.health / enemy.maxHealth).clamp(0.0, 1.0).toDouble();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enemy.name,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: enemyHealthPercent,
                            backgroundColor: Colors.red[900],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Attack button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: runManager.heroAttack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ATTACK!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
