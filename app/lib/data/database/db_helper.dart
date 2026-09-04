import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../game_state/models/game_save.dart';
import 'dart:convert';

class DatabaseHelper {
  static const String dbName = 'float_hero.db';
  static const String tableSaves = 'saves';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableSaves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        slot INTEGER NOT NULL UNIQUE,
        saveData TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<GameSave?> loadGame(int slot) async {
    final db = await database;
    final maps = await db.query(
      tableSaves,
      where: 'slot = ?',
      whereArgs: [slot],
    );

    if (maps.isEmpty) return null;

    final json = jsonDecode(maps.first['saveData'] as String);
    return GameSave.fromJson(json as Map<String, dynamic>);
  }

  Future<void> saveGame(GameSave save, int slot) async {
    final db = await database;
    final json = jsonEncode(save.toJson());

    await db.insert(
      tableSaves,
      {
        'slot': slot,
        'saveData': json,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteGame(int slot) async {
    final db = await database;
    await db.delete(
      tableSaves,
      where: 'slot = ?',
      whereArgs: [slot],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
