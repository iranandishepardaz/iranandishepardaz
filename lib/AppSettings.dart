import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

class AppSettings {
  static const String TableName = "AppSettings";

  static String tableCreator() {
    String sql = "CREATE TABLE " + AppSettings.TableName + "(";
    sql += "settingName TEXT, ";
    sql += "settingValue TEXT, ";
    sql += "PRIMARY KEY(settingName)";
    sql += ")";
    return sql;
  }

  static Future addDefaultSetings() async {}

  static Future<List<AppSetting>> getAllSettings(int count) async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(AppSettings.TableName,
        limit: count, orderBy: "sentAt ASC, settingName ASC");
    if (res.isNotEmpty) {
      var settings =
          res.map((settingMap) => AppSetting.fromDb(settingMap)).toList();
      return settings;
    }
    return [];
  }

  static Future<int> localSettingsCount() async {
    //var client = await AppDb.db;
    return Sqflite.firstIntValue(await AppDatabase.currentDB
        .rawQuery('SELECT COUNT(*) FROM ' + AppSettings.TableName));
  }

  static Future<void> clearAllLocalsettings() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(AppSettings.TableName);
  }

  static Future<AppSetting> getSetting(String settingName) async {
    AppSetting outPut = AppSetting(settingName: settingName, settingValue: "");
    try {
      var res = await AppDatabase.currentDB.query(
        AppSettings.TableName,
        where: '(settingName = ?)',
        whereArgs: [settingName],
      );
      if (res.isNotEmpty) {
        var settings =
            res.map((settingMap) => AppSetting.fromDb(settingMap)).toList();
        return settings.first;
      }
    } catch (e) {
      return outPut;
    }
    return outPut;
  }

/*  static double get messageFontSize {
    Future.delayed(Duration.zero, () async {
      double size = 12;
      AppSetting mFontS = await AppSettings.getSetting("messageFontSize");
      try {
        size = double.parse(mFontS.settingValue);
      } catch (e) {
        AppSetting(settingName: "messageFontSize", settingValue: "12").insert();
      
      }
    });
//return size;
  }
*/

  static Future<double> setMessageFontSize(double size) async {
    try {
      AppSetting fontSize = AppSetting(
          settingName: "messageFontSize",
          settingValue: AppParameters.messageFontSize.toString());
      await fontSize.insert();
    } catch (e) {}
    return size;
  }

  static Future<double> getMessageFontSize() async {
    double size = AppParameters.messageFontSize;
    AppSetting mFontS = await AppSettings.getSetting("messageFontSize");
    try {
      size = double.parse(mFontS.settingValue);
    } catch (e) {
      AppSetting(settingName: "messageFontSize", settingValue: size.toString())
          .insert();
    }
    return size;
  }

  static Future<double> setMessageDateFontSize(double size) async {
    try {
      AppSetting fontSize = AppSetting(
          settingName: "messageDateFontSize",
          settingValue: AppParameters.messageDateFontSize.toString());
      await fontSize.insert();
    } catch (e) {}
    return size;
  }

  static bool _nMode;
  static get nightMode => _nMode == null ? false : _nMode;
  static set nightMode(bool nMode) => _nMode = nMode;

  static bool getSomething() {
    if (_nMode == null) {
      readNightMode();
      Future.delayed(Duration(seconds: 2), () {
        return _nMode;
      });
    } else
      return _nMode;
  }

  static saveNightMode(bool nMode) async {
    _nMode = nMode;
    try {
      AppSetting tmpSetting =
          AppSetting(settingName: "nightMode", settingValue: _nMode.toString());
      tmpSetting.insert();
    } catch (e) {}
  }

  static Future<bool> readNightMode() async {
    try {
      AppSetting tmpSetting = await AppSettings.getSetting("nightMode");
      _nMode = tmpSetting.settingValue.toLowerCase() == 'true' ||
          tmpSetting.settingValue.toLowerCase() == '1';
    } catch (e) {
      AppSetting(settingName: "nightMode", settingValue: _nMode.toString())
          .insert();
    }
    return _nMode;
  }

  /* static get nMode => () async {
        if (_nMode != null) return _nMode;
        try {
          AppSetting tmpSetting = await AppSettings.getSetting("nightMode");
          _nMode = tmpSetting.settingValue.toLowerCase() == 'true' ||
              tmpSetting.settingValue.toLowerCase() == '1';
        } catch (e) {
          AppSetting(settingName: "nightMode", settingValue: _nMode.toString())
              .insert();
        }
        return _nMode;
      };

  static set nightMode(bool nMode) => () {
        _nMode = nMode;
        try {
          AppSetting tmpSetting = AppSetting(
              settingName: "nightMode", settingValue: _nMode.toString());
          tmpSetting.insert();
        } catch (e) {}
      };

  static Future<bool> getNightMode() async {
    //if (_nMode != null) return _nMode;
    try {
      AppSetting tmpSetting = await AppSettings.getSetting("nightMode");
      _nMode = tmpSetting.settingValue.toLowerCase() == 'true' ||
          tmpSetting.settingValue.toLowerCase() == '1';
    } catch (e) {
      AppSetting(settingName: "nightMode", settingValue: _nMode.toString())
          .insert();
    }
    return _nMode;
  }
*/
  static Future<double> getMessageDateFontSize() async {
    double size = AppParameters.messageDateFontSize;
    AppSetting fontSize = await AppSettings.getSetting("messageDateFontSize");
    try {
      size = double.parse(fontSize.settingValue);
    } catch (e) {
      AppSetting(
              settingName: "messageDateFontSize", settingValue: size.toString())
          .insert();
    }
    return size;
  }

/*
  static double get messageFontSize {
    AppSetting mFontS = AppSettings.getSetting("messageFontSize") as AppSetting;
    try {
      return double.parse(mFontS.settingValue);
    } catch (e) {
      AppSetting(settingName: "messageFontSize", settingValue: "12").insert();
      return 12;
    }
  }

  static set messageFontSize(double dblValue) {
    AppSetting(
            settingName: "messageFontSize", settingValue: dblValue.toString())
        .insert();
  }*/

}

class AppSetting {
  @required
  String settingName;
  @required
  String settingValue;

  AppSetting({
    this.settingName,
    this.settingValue,
  });

  Map<String, dynamic> toMapForDb() {
    return {
      'settingName': settingName,
      'settingValue': settingValue,
    };
  }

  AppSetting.fromDb(Map<String, dynamic> map)
      : settingName = map['settingName'],
        settingValue = map['settingValue'];

  Future<AppSetting> fetch(int settingName) async {
    //var client = await AppDb.db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      AppSettings.TableName,
      where: 'settingName = ? ',
      whereArgs: [settingName],
    );

    var maps = await futureMaps;
    if (maps.length != 0) {
      return AppSetting.fromDb(maps.first);
    }
    return null;
  }

  Future<int> insert() async {
    int result = 0;
    try {
      //var client = await AppDb.db;
      result = await AppDatabase.currentDB.insert(
          AppSettings.TableName, toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {}
    print("Insert Setting Result : " + result.toString());
    return result;
  }

  Future<int> update() async {
    //var client = await AppDb.db;
    print("Updating setting : from " + settingName + " = " + settingValue);
    return await AppDatabase.currentDB.update(
        AppSettings.TableName, toMapForDb(),
        where: 'settingName = ? ',
        whereArgs: [settingName],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(AppSettings.TableName,
        where: 'settingName = ? ', whereArgs: [settingName]);
  }

  Future<List<List<String>>> upload() async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "111",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      settingName.toString(),
      settingValue,
    ]);
    return records;
  }

  Future closeDb() async {
    //var client = await AppDb.db;
    await AppDatabase.currentDB.close();
  }
}
