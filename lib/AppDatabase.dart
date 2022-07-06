import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'AppSettings.dart';
import 'Friends.dart';
import 'ShortMessages.dart';
import 'TempMessages.dart';
import "package:path/path.dart";
//import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'ApMeMessages.dart';

class AppDatabase {
  //static Database _database;

  static late Database currentDB;

  static Future<void> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'ApMeDatabase.db');
    currentDB = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static void _onCreate(Database db, int version) async {
    debugPrint("Database Created");
    await db.execute(Friends.tableCreator());
    debugPrint("Friends Table Created");
    await db.execute(ApMeMessages.tableCreator());
    debugPrint("Messages Table Created");
    await db.execute(TempMessages.tableCreator());
    debugPrint("TempMessages Table Created");
    await db.execute(ShortMessages.tableCreator());
    debugPrint("ShortMessages Table Created");
    await db.execute(AppSettings.tableCreator());
    debugPrint("AppSettings Table Created");
    await AppSettings.resetToDefaultSetings();
  }

  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 2 && oldVersion == 1) {
      /* db.execute(AppSettings.tableCreator());
      debugPrint("AppSettings Table Created");*/

      /*await db.execute("Drop TABLE " +ApMeMessages.TableName);
      await db.execute(ApMeMessages.tableCreator());
      debugPrint("Messages Table Updated");*/
    }
  }

/*
var status;
  Future _checkPermission() async {
    this.status = await Permission.storage.status;
    debugPrint(' storage permission status  : ${this.status}');
    if (await Permission.storage.request().isGranted) {
      _database = await initDatabase();
    }
    else 
      if (await Permission.storage.request().isUndetermined) {
        debugPrint('Undetermined permission');
      } 
      else 
        if (await Permission.storage.request().isDenied) {
          debugPrint('Permission denied');
          _checkPermission();
        } 
        else 
          if (await Permission.storage.request().isPermanentlyDenied) {
            debugPrint(' it has been permenantly denied');
          }
    return null;
  }
*/
}





















/*
OLD VERSION JUST FOR BACKUP



import 'dart:async';
import 'dart:io';

import 'AppSettings.dart';
import 'Friends.dart';
import 'ShortMessages.dart';
import 'TempMessages.dart';
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

  static Future<Database> initDatabase() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //برای تفاوت اندروید و آی او اس
    String dbPath = join(directory.path, 'ApMe.db');
    var database = await openDatabase(dbPath,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return database;
  }

/*
var status;
  Future _checkPermission() async {
    this.status = await Permission.storage.status;
    debugPrint(' storage permission status  : ${this.status}');
    if (await Permission.storage.request().isGranted) {
      _database = await initDatabase();
    }
    else 
      if (await Permission.storage.request().isUndetermined) {
        debugPrint('Undetermined permission');
      } 
      else 
        if (await Permission.storage.request().isDenied) {
          debugPrint('Permission denied');
          _checkPermission();
        } 
        else 
          if (await Permission.storage.request().isPermanentlyDenied) {
            debugPrint(' it has been permenantly denied');
          }
    return null;
  }
*/
  static void _onCreate(Database db, int version) {
    debugPrint("Database Created");
    db.execute(Friends.tableCreator());
    debugPrint("Friends Table Created");
    db.execute(ApMeMessages.tableCreator());
    debugPrint("Messages Table Created");
    db.execute(TempMessages.tableCreator());
    debugPrint("TempMessages Table Created");
    db.execute(ShortMessages.tableCreator());
    debugPrint("ShortMessages Table Created");
    db.execute(AppSettings.tableCreator());
    debugPrint("AppSettings Table Created");
    AppSettings.addDefaultSetings();
  }

  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 2 && oldVersion == 1) {
      /* db.execute(AppSettings.tableCreator());
      debugPrint("AppSettings Table Created");*/

      /*await db.execute("Drop TABLE " +ApMeMessages.TableName);
      await db.execute(ApMeMessages.tableCreator());
      debugPrint("Messages Table Updated");*/
    }
  }

  Future<Database> get db async {
    if (_database != null) return _database;
    // await _checkPermission();
    //if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }
}
*/