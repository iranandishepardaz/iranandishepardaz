import 'dart:async';
import 'dart:io';

import 'ApMeMessages.dart';
import 'AppSettings.dart';
import 'Friends.dart';
import 'ShortMessages.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'TempMessages.dart';

class AppDatabase {
  static Database _database;

  static Database currentDB;

  /*static Future<Database?> initDatabase() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //برای تفاوت اندروید و آی او اس
    String dbPath = join(directory.path, 'ApControllerDB.db');
    currentDB = await openDatabase(dbPath,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return currentDB;
  }
*/

  static Future<void> checkDatabase() async {
    if (AppDatabase.currentDB == null) {
      Directory directory =
          await getApplicationDocumentsDirectory(); //برای تفاوت اندروید و آی او اس
      String dbPath = join(directory.path, 'ApMeDatabase.db');
      currentDB = await openDatabase(dbPath,
          version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    }
  }

/*
  static Future<Database?> get db async {
    if (_database != null) return _database;
    // await _checkPermission();
    //if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }
*/
  static void _onCreate(Database db, int version) async {
    print("Database Created");
    await db.execute(Friends.tableCreator());
    print("Friends Table Created");
    await db.execute(ApMeMessages.tableCreator());
    print("Messages Table Created");
    await db.execute(TempMessages.tableCreator());
    print("TempMessages Table Created");
    await db.execute(ShortMessages.tableCreator());
    print("ShortMessages Table Created");
    await db.execute(AppSettings.tableCreator());
    print("AppSettings Table Created");
    await AppSettings.resetToDefaultSetings();
  }

  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 2 && oldVersion == 1) {
      /* db.execute(AppSettings.tableCreator());
      print("AppSettings Table Created");*/

      /*await db.execute("Drop TABLE " +ApMeMessages.TableName);
      await db.execute(ApMeMessages.tableCreator());
      print("Messages Table Updated");*/
    }
  }

/*
var status;
  Future _checkPermission() async {
    this.status = await Permission.storage.status;
    print(' storage permission status  : ${this.status}');
    if (await Permission.storage.request().isGranted) {
      _database = await initDatabase();
    }
    else 
      if (await Permission.storage.request().isUndetermined) {
        print('Undetermined permission');
      } 
      else 
        if (await Permission.storage.request().isDenied) {
          print('Permission denied');
          _checkPermission();
        } 
        else 
          if (await Permission.storage.request().isPermanentlyDenied) {
            print(' it has been permenantly denied');
          }
    return null;
  }
*/
}
