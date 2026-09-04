import 'package:flutter/material.dart';
import 'game_state/managers/economy_manager.dart';
import 'game_state/managers/run_manager.dart';
import 'game_state/services/persistence_service.dart';
import 'ui/screens/idle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FloatHeroApp());
}

class FloatHeroApp extends StatelessWidget {
  const FloatHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Float Hero',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GameInitializer(),
    );
  }
}

class GameInitializer extends StatefulWidget {
  const GameInitializer({super.key});

  @override
  State<GameInitializer> createState() => _GameInitializerState();
}

class _GameInitializerState extends State<GameInitializer> {
  late Future<GameManagers> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeGame();
  }

  Future<GameManagers> _initializeGame() async {
    final persistenceService = PersistenceService();
    final save = await persistenceService.initialize();

    // Apply offline earnings
    final updatedSave = save.copyWith(
      gold: save.gold + save.calculateOfflineEarnings(),
      lastPlayTime: DateTime.now(),
    );

    // Initialize economy manager
    final economyManager = EconomyManager(updatedSave);
    economyManager.startIncomeLoop();

    // Initialize run manager
    final runManager = RunManager();

    // Start persistence
    persistenceService.startAutoSave();

    return GameManagers(
      economyManager: economyManager,
      runManager: runManager,
      persistenceService: persistenceService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameManagers>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF1a1a2e),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.cyan),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading Float Hero...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final managers = snapshot.data!;

        return IdleScreen(
          economyManager: managers.economyManager,
          runManager: managers.runManager,
          persistenceService: managers.persistenceService,
        );
      },
    );
  }
}

class GameManagers {
  final EconomyManager economyManager;
  final RunManager runManager;
  final PersistenceService persistenceService;

  GameManagers({
    required this.economyManager,
    required this.runManager,
    required this.persistenceService,
  });
}
