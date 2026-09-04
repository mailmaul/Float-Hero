import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../game/run_game.dart';
import '../../game_state/managers/run_manager.dart';
import '../../audio/sfx.dart';

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
  RunManager get runManager => widget.runManager;
  late final RunGame _game = RunGame(runManager);
  bool _ended = false;

  static const Color _bg = Color(0xFF20323A);
  static const Color _ink = Color(0xFF3A2A1A);

  @override
  void initState() {
    super.initState();
    runManager.addListener(_onChanged);
  }

  @override
  void dispose() {
    runManager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (_ended || runManager.isRunActive) return;
    _ended = true;
    (runManager.runState?.victory ?? false) ? Sfx.win() : Sfx.lose();
    // Brief pause so the player sees the final state before returning.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) widget.onRunEnd();
    });
  }

  void _attack() {
    if (!runManager.isRunActive) return;
    runManager.heroAttack();
    _game.playHeroAttack();
    Sfx.hit();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: runManager,
      builder: (context, _) {
        final run = runManager.runState;
        if (run == null) {
          return const Scaffold(
            backgroundColor: _bg,
            body: Center(
              child: Text('No run data', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        final hpPct =
            (run.heroHealth / run.heroMaxHealth).clamp(0.0, 1.0).toDouble();

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            title: const Text('ROGUELIKE RUN'),
            backgroundColor: const Color(0xFF16213e),
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              // Hero status.
              Padding(
                padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: hpPct,
                              minHeight: 16,
                              backgroundColor: Colors.red[900],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                hpPct > 0.5 ? Colors.greenAccent : Colors.orange,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${run.heroHealth.toStringAsFixed(0)}/${run.heroMaxHealth.toStringAsFixed(0)}',
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

              // Stats row.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('WAVE', '${run.waveNumber}', Colors.cyan),
                    _stat('GOLD', run.goldEarned.toStringAsFixed(0), Colors.yellow),
                    _stat('XP', run.xpEarned.toString(), Colors.greenAccent),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Flame battle scene (tap to attack).
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: _ink, width: 3)),
                  child: ClipRect(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _attack,
                      child: GameWidget(game: _game),
                    ),
                  ),
                ),
              ),

              // Attack button.
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _attack,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05B5B),
                      border: Border.all(color: _ink, width: 3),
                      boxShadow: const [BoxShadow(color: _ink, offset: Offset(0, 5))],
                    ),
                    child: const Text(
                      'ATTACK!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
