import 'dart:async';
import '../models/game_save.dart';
import '../../data/database/db_helper.dart';

/// Persists the game to the local database. The live game state is supplied
/// via a provider callback so every save writes the current progress rather
/// than a stale snapshot.
class PersistenceService {
  PersistenceService({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  final DatabaseHelper _dbHelper;
  Timer? _autoSaveTimer;
  GameSave Function()? _stateProvider;

  static const Duration _autoSaveInterval = Duration(seconds: 5);
  static const int _defaultSlot = 0;

  /// Load the persisted save, or a fresh default if none exists.
  Future<GameSave> initialize() async {
    final loaded = await _dbHelper.loadGame(_defaultSlot);
    return loaded ?? GameSave.createDefault();
  }

  /// Start the auto-save loop. [stateProvider] returns the current game state
  /// each time a save fires.
  void startAutoSave(GameSave Function() stateProvider) {
    _stateProvider = stateProvider;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) => save());
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// Persist the current state immediately. Safe to call at any time.
  Future<void> save() async {
    final provider = _stateProvider;
    if (provider == null) return;
    await _dbHelper.saveGame(
      provider().copyWith(lastSaveTime: DateTime.now()),
      _defaultSlot,
    );
  }

  /// Flush a final save and release the database.
  Future<void> dispose() async {
    stopAutoSave();
    await save();
    await _dbHelper.close();
  }
}
