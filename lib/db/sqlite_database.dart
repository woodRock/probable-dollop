/// Groceries Database - sqlite_database.dart
/// ============================================
/// An SQLite database that allows for persistent storage of grocery lists.
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock/model/grocery.dart';

class GroceriesDatabase {
  static final GroceriesDatabase instance = GroceriesDatabase._init();
  static Database? _database;
  GroceriesDatabase._init();

  /// Retrieve an instance of the database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('groceries_db');
    return _database!;
  }

  /// Intialize the SQLite database.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Create a SQLite database.
  Future _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE GROCERIES (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          icon TEXT NOT NULL,
          name TEXT NOT NULL,
          price REAL NOT NULL
        );
    ''');
  }

  /// Drop the table database from SQLite.
  Future<void> refreshGroceryTable() async {
    final db = await instance.database;
    await db.execute('''
        DROP TABLE GROCERIES;
    ''');
    // Recreate the table.
    _createDB(db, 1);
  }

  /// A function that inserts a grocery into the database.
  Future<void> insertGrocery(Grocery grocery) async {
    final db = await instance.database;
    final id = await db.insert(
      'groceries',
      grocery.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// A function that retrieves all the groceries from the groceries table.
  Future<List<Grocery>> groceries() async {
    // Get a reference to the database.
    final db = await instance.database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('groceries');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Grocery(
        id: maps[i]['id'],
        icon: maps[i]['icon'],
        name: maps[i]['name'],
        price: maps[i]['price'],
      );
    });
  }

  /// A method that updates a grocery in the database.
  Future<void> updateGrocery(Grocery grocery) async {
    // Get a reference to the database.
    final db = await instance.database;

    // Update the given Dog.
    await db.update(
      'groceries',
      grocery.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [grocery.id],
    );
  }

  /// A method that deletes a grocery from the database
  Future<void> deleteGrocery(int id) async {
    // Get a reference to the database.
    final db = await instance.database;

    // Remove the Grocery from the database.
    await db.delete(
      'groceries',
      // Use a `where` clause to delete a specific grocery.
      where: 'id = ?',
      // Pass the Grocery's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

}