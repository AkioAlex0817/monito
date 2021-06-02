import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await createDatabase();
    return _database;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();
    return await openDatabase(join(dbPath, 'monito_v3.db'), version: 1, onCreate: (Database database, int version) async {
      await database.execute("CREATE TABLE category("
          "cat_id TEXT(20) PRIMARY KEY NOT NULL, "
          "name TEXT(255) NOT NULL, "
          "context_free_name TEXT(255) NOT NULL"
          ")");
      await database.execute("CREATE TABLE suppliers("
          "id INTEGER(11) PRIMARY KEY NOT NULL, "
          "name TEXT(255) NOT NULL"
          ")");
      await database.execute("CREATE TABLE user_settings("
          "user_id INTEGER(11) PRIMARY KEY NOT NULL, "
          "keepa_api_key TEXT(255), "
          "price_archive_percent INTEGER(11), "
          "track_ranking INTEGER(11), "
          "low_ranking_range INTEGER(11)"
          ")");
      await database.execute("CREATE TABLE notifications("
          "id TEXT(20) PRIMARY KEY NOT NULL, "
          "expired_at INTEGER(20)"
          ")");
    });
  }

  Future<bool> insertNotification(Map<String, dynamic> item) async {
    final Database db = await database;
    try {
      await db.insert("notifications", item, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (error) {
      print("Insert notification Error: $error");
      return false;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> getExpiredNotifications(int targetTimeStamp) async {
    final Database db = await database;
    try {
      return await db.query("notifications", where: "expired_at <= ?", whereArgs: [targetTimeStamp]);
    } catch (error) {
      return [];
    }
  }

  Future<bool> removeExpiredNotifications(int targetTimeStamp) async {
    final Database db = await database;
    try {
      await db.delete("notifications", where: "expired_at <= ?", whereArgs: [targetTimeStamp]);
    } catch (error) {
      print("Remove expired notifications Error: $error");
      return false;
    }
    return true;
  }

  Future<bool> insertOrUpdateSetting(int user_id, String keepa_api_key, int price_archive_percent, int track_ranking, int low_ranking_range) async {
    final Database db = await database;
    Map<String, dynamic> item = {'user_id': user_id, 'keepa_api_key': keepa_api_key, 'price_archive_percent': price_archive_percent, 'track_ranking': track_ranking, 'low_ranking_range': low_ranking_range};
    try {
      await db.insert("user_settings", item, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (error) {
      print("User info setting db Error: $error");
      return false;
    }
    return true;
  }

  Future<bool> updateUserSetting(int member_id, Map<String, dynamic> item) async {
    final Database db = await database;
    try {
      await db.update("user_settings", item, conflictAlgorithm: ConflictAlgorithm.replace, where: "user_id = ?", whereArgs: [member_id]);
    } catch (error) {
      print("User info setting update Error: $error");
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> getUserSetting(int member_id) async {
    final Database db = await database;
    try {
      var db_res = await db.query("user_settings", where: "user_id = ?", whereArgs: [member_id]);
      if (db_res.length == 0) {
        throw new Exception("User setting Empty! => $member_id");
      }
      return db_res[0];
    } catch (error) {
      print("Get User Setting Error: $error");
      return null;
    }
  }

  Future<bool> removeUserSetting() async {
    final Database db = await database;
    try {
      await db.delete('user_settings');
    } catch (err) {
      print("Remove User Setting Error: $err");
      return false;
    }
    return true;
  }

  Future<bool> insertOrUpdateSupplier(int id, String name) async {
    final Database db = await database;
    Map<String, dynamic> item = {'id': id, 'name': name};
    try {
      await db.insert("suppliers", item, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (error) {
      print("InsertOrUpdateSupplierError: $error");
      return false;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
    final Database db = await database;
    try {
      return await db.query("suppliers");
    } catch (error) {
      print("Get All Suppliers Error: $error");
      return null;
    }
  }

  Future<Map<String, dynamic>> getSupplier(int id) async {
    final Database db = await database;
    try {
      var db_res = await db.query("suppliers", where: "id = ?", whereArgs: [id], limit: 1);
      if (db_res.length == 0) {
        throw new Exception("No Supplier $id");
      }
      return db_res[0];
    } catch (error) {
      print("Get Supplier Name Error: $error");
      return null;
    }
  }

  Future<bool> removeAllSuppliers() async {
    final Database db = await database;
    try {
      await db.delete('suppliers');
    } catch (err) {
      print("Remove all Suppliers Error: $err");
      return false;
    }
    return true;
  }

  Future<bool> removeSupplier(int id) async {
    final Database db = await database;
    try {
      await db.delete('suppliers', where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Remove supplier Error: $err");
      return false;
    }
    return true;
  }

  Future<bool> insertOrUpdateCategory(String cat_id, String name, String context_free_name) async {
    final Database db = await database;
    Map<String, dynamic> item = {'cat_id': cat_id, 'name': name, 'context_free_name': context_free_name};
    try {
      await db.insert('category', item, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (error) {
      print("InsertOrUpdateCategoryError: $error");
      return false;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final Database db = await database;
    try {
      return await db.query("category");
    } catch (error) {
      print("Get All Categories Error: $error");
      return null;
    }
  }

  Future<Map<String, dynamic>> getCategory(String cat_id) async {
    final Database db = await database;
    try {
      var db_res = await db.query("category", where: "cat_id = ?", whereArgs: [cat_id], limit: 1);
      if (db_res.length == 0) {
        throw new Exception("No item $cat_id");
      }
      return db_res[0];
    } catch (error) {
      print("Get Category Name Error: $error");
      return null;
    }
  }

  Future<bool> removeAllCategory() async {
    final Database db = await database;
    try {
      await db.delete('category');
    } catch (err) {
      print("Remove all category Error: $err");
      return false;
    }
    return true;
  }
}
