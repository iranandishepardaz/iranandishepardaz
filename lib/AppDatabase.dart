import 'dart:async';
import 'dart:io';

import 'package:ap_me/Friends.dart';
import 'package:ap_me/TempMessages.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'ApMeMessages.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  static Database _database;

  AppDatabase._();

  factory AppDatabase() {
    return _instance;
  }

  Future<Database> initDatabase() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //برای تفاوت اندروید و آی او اس
    String dbPath = join(directory.path, 'ApMe.db');
    var database = openDatabase(dbPath,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return database;
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
  void _onCreate(Database db, int version) {
    print("Database Created");
    db.execute(Friends.tableCreator());
    print("Friends Table Created");
    db.execute(ApMeMessages.tableCreator());
    print("Messages Table Created");
    db.execute(TempMessages.tableCreator());
    print("TempMessages Table Created");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    /*  if (newVersion == 2 && oldVersion ==1) {
      await db.execute("Drop TABLE " +ApMeMessages.TableName);
      await db.execute(ApMeMessages.tableCreator());
      print("Messages Table Updated");
    }
   */
  }

  Future<Database> get db async {
    if (_database != null) return _database;
    // await _checkPermission();
    //if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }
}
