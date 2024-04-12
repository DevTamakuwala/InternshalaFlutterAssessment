// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute(
      "CREATE TABLE tblFavorite(_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, product_id INTEGER, date DATETIME)",
    );
  }

  static Future<sql.Database> db() {
    return sql.openDatabase(
      'dbTest.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> addToFav(int productId) async {
    final db = await SQLHelper.db();
    final data = {'product_id': productId, "date": DateTime.now().toString()};
    final id = await db.insert("tblFavorite", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db
        .query("tblFavorite", orderBy: 'product_id', columns: ['product_id']);
  }

  // static Future<List<Map<String, dynamic>>> getItems(int productId) async{
  //   final db = await SQLHelper.db();
  //   return db.query("tblFavorite", where: "product_id = ?", whereArgs: [productId], limit: 1);
  // }

  static Future<void> deleteFromFavorite(int productId) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('tblFavorite',
          where: " product_id = ?", whereArgs: [productId]);
    } catch (err) {
      debugPrint(err as String?);
    }
  }
}
