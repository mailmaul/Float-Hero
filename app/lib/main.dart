import 'package:flutter/material.dart';
import 'game_state/managers/economy_manager.dart';
import 'game_state/managers/run_manager.dart';
import 'game_state/services/persistence_service.dart';
import 'ui/screens/idle_screen.dart';

void main() {
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

class _GameInitializerState extends State<GameInitializer>
    with WidgetsBindingObserver {
  late final Future<GameManagers> _initFuture;
  GameManagers? _managers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initializeGame();
  }

  Future<GameManagers> _initializeGame() async {
    final persistenceService = PersistenceService();
    final save = await persistenceService.initialize();

    final economyManager = EconomyManager(save);
    economyManager.applyOfflineEarnings();
    economyManager.startIncomeLoop();

    final runManager = RunManager();

    // Auto-save always writes the manager's live state.
    persistenceService.startAutoSave(() => economyManager.state);

    final managers = GameManagers(
      economyManager: economyManager,
      runManager: runManager,
      persistenceService: persistenceService,
    );
    _managers = managers;
    return managers;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      // Flush progress when the app leaves the foreground.
      _managers?.persistenceService.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final managers = _managers;
    if (managers != null) {
      managers.economyManager.dispose();
      managers.runManager.dispose();
      managers.persistenceService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameManagers>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1a1a2e),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading Float Hero...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF1a1a2e),
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
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
