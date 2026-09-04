import 'package:flutter/material.dart';
import '../../game_state/managers/economy_manager.dart';
import '../../game_state/managers/run_manager.dart';
import '../../game_state/services/persistence_service.dart';
import '../../game_state/models/game_hero.dart';
import 'package:flame/game.dart';
import '../../game/float_hero_game.dart';
import '../../audio/sfx.dart';
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

  final FloatHeroGame _game = FloatHeroGame();

  static const Color _ink = Color(0xFF3A2A1A);

  void _tap() {
    final before = economyManager.gold;
    economyManager.onTap();
    Sfx.tap();
    _game.heroAttack(gold: economyManager.gold - before);
  }

  Future<void> _startRun() async {
    final all = economyManager.heroes;
    if (all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No heroes available!')),
      );
      return;
    }

    // Draft: up to 3 candidates from unlocked heroes (fall back to all).
    final pool = all.where((h) => h.unlocked).toList();
    final candidates = (pool.isEmpty ? List<GameHero>.of(all) : pool)..shuffle();
    final choices = candidates.take(3).toList();

    final hero =
        choices.length == 1 ? choices.first : await _pickHero(choices);
    if (hero == null || !mounted) return;

    runManager.startRun(hero);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RunScreen(
          runManager: runManager,
          onRunEnd: _onRunEnd,
        ),
      ),
    );
  }

  Future<GameHero?> _pickHero(List<GameHero> choices) {
    return showModalBottomSheet<GameHero>(
      context: context,
      backgroundColor: const Color(0xFFF7E4B0),
      shape: const RoundedRectangleBorder(),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CHOOSE YOUR HERO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              for (final h in choices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(h),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4EC0E0),
                        border: Border.all(color: _ink, width: 3),
                        boxShadow: const [
                          BoxShadow(color: _ink, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${h.name}  Lv${h.level}',
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'DMG ${h.damagePerTap.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRunEnd() {
    if (!mounted) return;

    final summary = runManager.getRunSummary();
    final gold = (summary['gold'] as num?)?.toDouble() ?? 0;
    final victory = summary['victory'] as bool? ?? false;
    final reward = RunManager.rewardFor(gold, victory);
    economyManager.addRunRewards(reward);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          victory
              ? 'Victory! Kept ${reward.toStringAsFixed(0)} Gold'
              : 'Defeated. Kept ${reward.toStringAsFixed(0)} Gold (half)',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAEE7FF),
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD — rebuilds only on economy changes.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: ListenableBuilder(
                listenable: economyManager,
                builder: (context, _) {
                  final state = economyManager.state;
                  return _HudPanel(
                    gold: state.gold.toStringAsFixed(0),
                    income: state.incomePerSecond.toStringAsFixed(2),
                  );
                },
              ),
            ),

            // The living side-view pixel scene fills the middle.
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _ink, width: 3),
                ),
                child: ClipRect(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _tap,
                    child: GameWidget(game: _game),
                  ),
                ),
              ),
            ),

            // Controls.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _PixelButton(
                    label: 'TAP!',
                    color: const Color(0xFF4EC0E0),
                    textColor: Colors.white,
                    expand: true,
                    onTap: _tap,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PixelButton(
                          label: 'SHOP',
                          color: const Color(0xFFFFC24B),
                          textColor: _ink,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ShopScreen(
                                  economyManager: economyManager,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PixelButton(
                          label: 'RUN',
                          color: const Color(0xFFE05B5B),
                          textColor: Colors.white,
                          onTap: _startRun,
                        ),
                      ),
                    ],
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

/// Parchment stat panel with a chunky pixel border.
class _HudPanel extends StatelessWidget {
  const _HudPanel({required this.gold, required this.income});

  final String gold;
  final String income;

  static const Color _ink = Color(0xFF3A2A1A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E4B0),
        border: Border.all(color: _ink, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFB98C4A), offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 16, height: 16, color: const Color(0xFFFFD54A)),
              const SizedBox(width: 8),
              Text(
                gold,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Text(
            '+$income /sec',
            style: const TextStyle(
              color: Color(0xFF3E7A2E),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chunky, sharp-cornered retro button with a hard drop-shadow bevel.
class _PixelButton extends StatelessWidget {
  const _PixelButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.expand = false,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool expand;

  static const Color _ink = Color(0xFF3A2A1A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(vertical: expand ? 16 : 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: _ink, width: 3),
          boxShadow: const [
            BoxShadow(color: _ink, offset: Offset(0, 5)),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: expand ? 24 : 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
