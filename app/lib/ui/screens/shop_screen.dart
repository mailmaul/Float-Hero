import 'package:flutter/material.dart';
import '../../game_state/managers/economy_manager.dart';
import '../../game_state/models/game_hero.dart';
import '../../game_state/models/upgrade.dart';
import '../../audio/sfx.dart';

class ShopScreen extends StatelessWidget {
  final EconomyManager economyManager;

  const ShopScreen({
    super.key,
    required this.economyManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('SHOP'),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: economyManager,
          builder: (context, _) {
            final state = economyManager.state;
            return Column(
              children: [
                // Gold display.
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Gold: ${state.gold.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Shop tabs.
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'HEROES'),
                            Tab(text: 'UPGRADES'),
                          ],
                          labelColor: Colors.cyan,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.cyan,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ListView.builder(
                                itemCount: state.heroes.length,
                                itemBuilder: (context, index) =>
                                    _buildHeroCard(context, state.heroes[index]),
                              ),
                              ListView.builder(
                                itemCount: state.upgrades.length,
                                itemBuilder: (context, index) => _buildUpgradeCard(
                                    context, state.upgrades[index]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, GameHero hero) {
    final isAffordable = economyManager.gold >= hero.cost;
    final isUnlocked = hero.unlocked;

    return Card(
      color: const Color(0xFF16213e),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Level ${hero.level}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OWNED',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isUnlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cost: ${hero.cost} Gold',
                    style: TextStyle(
                      color: isAffordable ? Colors.yellow : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isAffordable
                        ? () {
                            economyManager.purchaseHero(hero.id);
                            Sfx.buy();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Purchased ${hero.name}!'),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAffordable ? Colors.green : Colors.grey,
                    ),
                    child: const Text('BUY'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context, Upgrade upgrade) {
    final isAffordable = economyManager.gold >= upgrade.nextCost;

    return Card(
      color: const Color(0xFF16213e),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upgrade.name,
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      upgrade.description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lv ${upgrade.currentLevel}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cost: ${upgrade.nextCost} Gold',
                  style: TextStyle(
                    color: isAffordable ? Colors.yellow : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: isAffordable
                      ? () {
                          economyManager.purchaseUpgrade(upgrade.id);
                          Sfx.buy();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${upgrade.name} upgraded to Lv${upgrade.currentLevel + 1}!',
                              ),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAffordable ? Colors.green : Colors.grey,
                  ),
                  child: const Text('UPGRADE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
