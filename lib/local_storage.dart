import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;

  LocalStorage._internal();

  Database? _database;

  Future<Database> _initDatabase() async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'aquarium.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE settings(id INTEGER PRIMARY KEY AUTOINCREMENT, fishCount INTEGER, speed REAL, color INTEGER)',
        );
      },
      version: 1,
    );

    return _database!;
  }

  Future<void> saveSettings(int fishCount, double speed, int color) async {
    final db = await _initDatabase();
    await db.delete('settings'); // Clear existing settings
    await db.insert('settings', {
      'fishCount': fishCount,
      'speed': speed,
      'color': color,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('settings');
    if (maps.isNotEmpty) {
      return maps.last; 
    }
    return null; 
  }
}
