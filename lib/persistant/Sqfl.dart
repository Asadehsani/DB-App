
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> creatTables(sql.Database database) async {
    await database.execute("""CRATE TABLE itemes(
    id INTEGER PRIMARY KEY AUTOINCREMENT NO NULL,
    title TEXT,
    description TEXT,    
    createdAt TIMESTAMP NOT NULL DEFEAULT CURRENT_TIMESTAMP)
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbestech.ab',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        print('...creatin a table');
        await creatTables(database);
      },
    );
  }

  static Future<int> createItem(String title, String? description) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'description': description};
    final id = await db.insert(
        'items',
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
