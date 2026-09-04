import 'dart:async';
import '../models/game_save.dart';
import '../../data/database/db_helper.dart';

class PersistenceService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Timer? _autoSaveTimer;
  GameSave? _currentSave;
  static const int _autoSaveIntervalSeconds = 5;
  static const int _defaultSlot = 0;

  /// Initialize persistence and load game
  Future<GameSave> initialize() async {
    final loaded = await _dbHelper.loadGame(_defaultSlot);
    _currentSave = loaded ?? GameSave.createDefault();
    return _currentSave!;
  }

  /// Get current save state
  GameSave? get currentSave => _currentSave;

  /// Start auto-save loop (call every 5 seconds)
  void startAutoSave() {
    _autoSaveTimer = Timer.periodic(
      Duration(seconds: _autoSaveIntervalSeconds),
      (_) => _autoSave(),
    );
  }

  /// Stop auto-save loop
  void stopAutoSave() {
    _autoSaveTimer?.cancel();
  }

  /// Internal auto-save
  Future<void> _autoSave() async {
    if (_currentSave != null) {
      await _dbHelper.saveGame(
        _currentSave!.copyWith(lastSaveTime: DateTime.now()),
        _defaultSlot,
      );
    }
  }

  /// Manual save
  Future<void> manualSave(GameSave save) async {
    _currentSave = save;
    await _dbHelper.saveGame(
      save.copyWith(lastSaveTime: DateTime.now()),
      _defaultSlot,
    );
  }

  /// Cleanup
  Future<void> dispose() async {
    stopAutoSave();
    await _autoSave(); // Final save
    await _dbHelper.close();
  }
}
