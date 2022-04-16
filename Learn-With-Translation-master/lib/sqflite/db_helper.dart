import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:learn_with_translation/models/current_user.dart';

class DatabaseHelper {
  static const _databaseName = "current_user.db";
  static const _databaseVersion = 1;
  static const table = 'current_user_table';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnDailyGoal = 'dailygoal';
  static const columnScore = 'score';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  // return a database object from sqflite package
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
  }

  _initDatabase() async {
    // where to keep data --> path name:
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // create fields where data will be kept
    // .execute method executes the given code as parameter (e.g create table ...)
    await db.execute('''
      CREATE TABLE $table (
        $columnId TEXT NOT NULL,
        $columnName TEXT NOT NULL,
        $columnDailyGoal INTEGER NOT NULL,
        $columnScore INTEGER NOT NULL
      )
      ''');
  }

  Future<int?> insert(CurrentUser user) async {
    // instance is the object of database helper class that we wrote above.
    Database? db = await instance.database;
    return await db?.insert(table, {
      'id': user.id,
      'name': user.name,
      'dailygoal': user.dailyGoal,
      'score': user.score
    });
  }

  Future<int?> update(CurrentUser user) async {
    Database? db = await instance.database;

    // which element to update
    String id = user.toMap()['id'];

    // update element where the columnId is equal to id of the user.
    return await db
        ?.update(table, user.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int?> delete(String id) async {
    Database? db = await instance.database;
    return await db?.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // method for getting all the rows
  Future<List<Map<String, dynamic>>?> queryAllRows() async {
    Database? db = await instance.database;
    return await db?.query(table);
  }

  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    if (db != null) {
      return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $table'));
    }
  }
}
