import 'dart:io';

import 'package:flutter_test_app/models/geoname.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database == null) _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, "GeoNames.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE GeoNames (
            id INTEGER PRIMARY KEY,
            name TEXT,
            countryName TEXT)''');
      },
    );
  }

  addNewGeo(GeoName geoName) async {
    final db = await database;
    var res = await db.insert("GeoNames", geoName.toJSON());
    return res;
  }

  Future<List<GeoName>> getAllGeo() async {
    final db = await database;
    // var res = await db.query("GeoNames");
    final List<Map<String, dynamic>> list = await db.query("GeoNames");

    // List<GeoName> list =
    //     res.isNotEmpty ? res.map((e) => GeoName.fromJSON(e)) : [];
    return List.generate(list.length, (index) => GeoName.fromJSON(list[index]));
  }
}
