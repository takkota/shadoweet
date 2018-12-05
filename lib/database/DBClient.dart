import 'package:shadoweet/database/LocationLog.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:core';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class DBClient {
  static Database _db;

  Future<Database> get db async {
    if (_db != null)
      return _db;
    _db = await _initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  _initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "puppy.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE location_logs(id INTEGER AUTO_INCREMENT, longitude REAL, latitude REAL, time INTEGER)"
    );
  }

  // 最後の位置
  Future<LocationLog> getLatestLocationLog() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM location_logs ORDER BY time DESC LIMIT 1');
    return list.length > 0 ? LocationLog.fromMap(list[0]) : null;
  }

  // 一番古い位置
  Future<LocationLog> getOldestLog() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM location_logs ORDER BY time ASC LIMIT 1');
    return list.length > 0 ? LocationLog.fromMap(list[0]) : null;

  }

  // ログcount
  Future<int> getLogCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM location_logs'));
  }

  // 最後の位置
  Future<List<LocationLog>> getLocationLogs() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM location_logs ORDER BY time DESC');
    List<LocationLog> locations = List<LocationLog>();
    for (final location in list) {
      locations.add(LocationLog.fromMap(location));
    }
    return locations;
  }

  // 300件レコードがある場合、oldestを更新
  // 300件未満の場合、insert
  Future<int> saveLog(LocationLog locationLog) async {
    final count = await getLogCount();
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      if (count >= 300) {
        final oldestLog = await getOldestLog();
        return await txn.rawUpdate(
            'UPDATE location_logs SET latitude = ?, longitude = ?, time = ? WHERE id = ?',
            [locationLog.latitude.toString(), locationLog.latitude.toString(), locationLog.time, oldestLog.id.toString()]
        );
      } else {
        return await txn.rawInsert(
            'INSERT INTO location_logs(latitude, longitude, time) VALUES(?, ?, ?)',
            [locationLog.latitude.toString(),
            locationLog.longitude.toString(),
            DateTime
                .now()
                .millisecondsSinceEpoch
                .toString()]
        );

      }
    });
  }

}
