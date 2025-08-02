import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_constants.dart';

/// Database configuration and initialization for the local score database
class DatabaseConfig {
  static Database? _database;

  /// Get the database instance, initializing if necessary
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database with proper schema creation
  static Future<Database> _initDatabase() async {
    // Get the database path
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    // Open the database and create tables if they don't exist
    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: _configureDatabase,
    );
  }

  /// Configure database settings (enable foreign keys)
  static Future<void> _configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables on first initialization
  static Future<void> _createDatabase(Database db, int version) async {
    // Create game sessions table
    await db.execute(DatabaseConstants.createGameSessionsTable);

    // Create turn results table
    await db.execute(DatabaseConstants.createTurnResultsTable);
  }

  /// Handle database schema upgrades for future versions
  static Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database migrations here when schema changes are needed
    // For now, no migrations are required as this is version 1
  }

  /// Close the database connection
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Reset the database (for testing purposes)
  static Future<void> resetDatabase() async {
    await closeDatabase();
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);
    await deleteDatabase(path);
  }
}
